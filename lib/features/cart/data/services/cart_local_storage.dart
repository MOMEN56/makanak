import 'dart:convert';

import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartLocalStorage {
  const CartLocalStorage._();

  static const _cartKey = 'cart_product_data';

  static Future<void> saveProduct({
    required ProductModel product,
    required int quantity,
    required int shippingPrice,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'product': product.toJson(),
      'quantity': quantity,
      'shipping_price': shippingPrice,
    };

    await prefs.setString(_cartKey, jsonEncode(data));
  }

  static Future<CartLocalData?> loadProduct() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_cartKey);
    if (value == null || value.isEmpty) return null;

    try {
      final data = jsonDecode(value) as Map<String, dynamic>;
      final productData = data['product'] as Map<String, dynamic>;
      return CartLocalData(
        product: ProductModel.fromJson(productData),
        quantity: data['quantity'] as int? ?? 1,
        shippingPrice: data['shipping_price'] as int? ?? 35,
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
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
}
