import 'dart:convert';

import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartLocalStorage {
  const CartLocalStorage._();

  static const _legacyCartKey = 'cart_product_data';
  static const _defaultQuantity = 1;
  static const _defaultShippingPrice = 35;

  static Future<void> _operationQueue = Future.value();

  static Future<void> saveProduct({
    required String userId,
    required ProductModel product,
    required int quantity,
    required int shippingPrice,
  }) {
    return addProduct(
      userId: userId,
      product: product,
      quantity: quantity,
      shippingPrice: shippingPrice,
    );
  }

  static Future<void> addProduct({
    required String userId,
    required ProductModel product,
    required int quantity,
    required int shippingPrice,
  }) {
    return _runQueued(() async {
      final prefs = await SharedPreferences.getInstance();
      await _removeLegacyCart(prefs);

      final cart = await _readCart(prefs, userId);
      final existingIndex = cart.indexWhere(
        (item) => item.product.id == product.id,
      );
      final item = CartLocalData(
        product: product,
        quantity: _safeQuantity(quantity),
        shippingPrice: shippingPrice,
      );

      if (existingIndex == -1) {
        cart.add(item);
      } else {
        cart[existingIndex] = item;
      }

      await _writeCart(prefs, userId, cart);
    });
  }

  static Future<List<CartLocalData>> loadProducts({required String userId}) {
    return loadCart(userId: userId);
  }

  static Future<List<CartLocalData>> loadCart({required String userId}) {
    return _runQueued(() async {
      final prefs = await SharedPreferences.getInstance();
      await _removeLegacyCart(prefs);
      return _readCart(prefs, userId);
    });
  }

  static Future<CartLocalData?> loadProduct({required String userId}) async {
    final cart = await loadCart(userId: userId);
    if (cart.isEmpty) return null;

    return cart.first;
  }

  static Future<void> updateProductQuantity({
    required String userId,
    required String productId,
    required int quantity,
    int? shippingPrice,
  }) {
    return _runQueued(() async {
      final prefs = await SharedPreferences.getInstance();
      await _removeLegacyCart(prefs);

      final cart = await _readCart(prefs, userId);
      final existingIndex = cart.indexWhere(
        (item) => item.product.id == productId,
      );
      if (existingIndex == -1) return;

      final item = cart[existingIndex];
      cart[existingIndex] = CartLocalData(
        product: item.product,
        quantity: _safeQuantity(quantity),
        shippingPrice: shippingPrice ?? item.shippingPrice,
      );

      await _writeCart(prefs, userId, cart);
    });
  }

  static Future<void> removeProduct({
    required String userId,
    required String productId,
  }) {
    return _runQueued(() async {
      final prefs = await SharedPreferences.getInstance();
      await _removeLegacyCart(prefs);

      final cart = await _readCart(prefs, userId);
      cart.removeWhere((item) => item.product.id == productId);
      await _writeCart(prefs, userId, cart);
    });
  }

  static Future<void> clearCart({required String userId}) {
    return _runQueued(() async {
      final prefs = await SharedPreferences.getInstance();
      await _removeLegacyCart(prefs);
      await _clearCart(prefs, userId);
    });
  }

  static Future<void> clear({required String userId}) {
    return clearCart(userId: userId);
  }

  static Future<void> clearLegacyCart() {
    return _runQueued(() async {
      final prefs = await SharedPreferences.getInstance();
      await _removeLegacyCart(prefs);
    });
  }

  static Future<T> _runQueued<T>(Future<T> Function() operation) {
    final nextOperation = _operationQueue.then((_) => operation());
    _operationQueue = nextOperation.then<void>((_) {}, onError: (_) {});

    return nextOperation;
  }

  static Future<List<CartLocalData>> _readCart(
    SharedPreferences prefs,
    String userId,
  ) async {
    final key = _cartKeyForUser(userId);
    final value = prefs.getString(key);
    if (value == null || value.isEmpty) return [];

    try {
      return _decodeCart(value);
    } catch (_) {
      await _clearCart(prefs, userId);
      return [];
    }
  }

  static List<CartLocalData> _decodeCart(String value) {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      return decoded
          .map(
            (item) => _cartLocalDataFromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    if (decoded is Map) {
      return [_cartLocalDataFromJson(Map<String, dynamic>.from(decoded))];
    }

    throw const FormatException('Invalid cart data.');
  }

  static CartLocalData _cartLocalDataFromJson(Map<String, dynamic> data) {
    final productData = data['product'];
    if (productData is! Map) {
      throw const FormatException('Invalid cart product data.');
    }

    return CartLocalData(
      product: ProductModel.fromJson(Map<String, dynamic>.from(productData)),
      quantity: _readInt(data['quantity'], defaultValue: _defaultQuantity),
      shippingPrice: _readInt(
        data['shipping_price'] ?? data['shippingPrice'],
        defaultValue: _defaultShippingPrice,
      ),
    );
  }

  static Future<void> _writeCart(
    SharedPreferences prefs,
    String userId,
    List<CartLocalData> cart,
  ) async {
    final key = _cartKeyForUser(userId);
    if (cart.isEmpty) {
      await prefs.remove(key);
      return;
    }

    final data = cart.map((item) => item.toJson()).toList();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<void> _clearCart(SharedPreferences prefs, String userId) async {
    await prefs.remove(_cartKeyForUser(userId));
  }

  static Future<void> _removeLegacyCart(SharedPreferences prefs) async {
    await prefs.remove(_legacyCartKey);
  }

  static String _cartKeyForUser(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User id cannot be empty.');
    }

    return '${_legacyCartKey}_$normalizedUserId';
  }

  static int _safeQuantity(int quantity) {
    return quantity < _defaultQuantity ? _defaultQuantity : quantity;
  }

  static int _readInt(Object? value, {required int defaultValue}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }
}

class CartLocalData {
  const CartLocalData({
    required this.product,
    required this.quantity,
    required this.shippingPrice,
  });

  final ProductModel product;
  final int quantity;
  final int shippingPrice;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'shipping_price': shippingPrice,
    };
  }
}
