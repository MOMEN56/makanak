import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/cart/services/cart_availability_service.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/domain/entities/product_availability_extension.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(
    this._productsRepo,
    this._cartAvailabilityService, {
    required String userId,
  }) : _userId = userId,
       super(CartInitial());

  final ProductsRepo _productsRepo;
  final CartAvailabilityService _cartAvailabilityService;
  final String _userId;
  String? _lastRestoredShopId;
  bool _isInitialized = false;

  Future<void> restoreSavedCart({String? shopId}) async {
    final normalizedShopId = shopId?.trim();
    if (_isInitialized && _lastRestoredShopId == normalizedShopId) return;
    _isInitialized = true;
    _lastRestoredShopId = normalizedShopId;

    final savedCart = await CartLocalStorage.loadProducts(userId: _userId);
    final shopCart = _mergeCartItems(
      _cartItemsForShop(savedCart, normalizedShopId),
      _cartItemsForShop(state.items, normalizedShopId),
    );
    if (isClosed) return;

    emit(
      CartInitial(items: shopCart, shippingPrice: _shippingPriceFor(shopCart)),
    );
    if (shopCart.isEmpty) return;

    await refreshCartAvailability(shopId: normalizedShopId);
  }

  Future<void> refreshCartAvailability({String? shopId}) async {
    final normalizedShopId = shopId?.trim();
    final syncResult = await _cartAvailabilityService.syncItems(
      sourceItems: _cartItemsForShop(state.items, normalizedShopId),
      shopId: normalizedShopId,
    );
    if (!syncResult.didFetchLatestProducts) return;

    await applySyncedItems(
      items: syncResult.availableItems,
      shopId: syncResult.shopId,
    );
  }

  void addProduct(CartViewArguments arguments) {
    final incomingProduct = arguments.product;
    if (incomingProduct == null || incomingProduct.isUnavailableForPurchase) {
      return;
    }

    final incomingProductId = incomingProduct.id?.trim();
    if (incomingProductId == null || incomingProductId.isEmpty) return;

    final currentItems = List<CartLocalData>.of(state.items);
    final existingIndex = currentItems.indexWhere(
      (item) => item.product.id?.trim() == incomingProductId,
    );
    final existingQuantity =
        existingIndex == -1 ? 0 : currentItems[existingIndex].quantity;
    final updatedQuantity = existingQuantity + arguments.quantity;
    final safeQuantity = updatedQuantity < 1 ? 1 : updatedQuantity;
    final updatedItem = CartLocalData(
      product: incomingProduct,
      quantity: safeQuantity,
      shippingPrice: arguments.shippingPrice,
    );

    if (existingIndex == -1) {
      currentItems.add(updatedItem);
    } else {
      currentItems[existingIndex] = updatedItem;
    }

    emit(
      CartInitial(
        items: currentItems,
        shippingPrice: _shippingPriceFor(currentItems),
      ),
    );

    unawaited(
      CartLocalStorage.saveProduct(
        userId: _userId,
        product: incomingProduct,
        quantity: safeQuantity,
        shippingPrice: arguments.shippingPrice,
      ),
    );
  }

  Future<AddProductToCartResult> addProductSafely(
    CartViewArguments arguments,
  ) async {
    final incomingProduct = arguments.product;
    if (incomingProduct == null) {
      return _addProductFailure(
        message: AppStrings.invalidProduct,
        status: AddProductToCartStatus.invalidProduct,
      );
    }

    final productId = (incomingProduct.id ?? '').trim();
    final normalizedShopId =
        (arguments.shopId ?? incomingProduct.shopId).trim();
    if (productId.isEmpty || normalizedShopId.isEmpty) {
      return _addProductFailure(
        message: AppStrings.invalidProduct,
        status: AddProductToCartStatus.invalidProduct,
      );
    }

    final shopValidation = await _cartAvailabilityService.validateShop(
      normalizedShopId,
      fetchFailureMessage: AppStrings.productAvailabilityCheckFailed,
    );
    if (!shopValidation.isValid) {
      return _addProductFailure(
        message: shopValidation.message,
        status: _mapAddToCartStatus(shopValidation.status),
      );
    }

    final result = await _productsRepo.fetchProductByShopAndId(
      shopId: normalizedShopId,
      productId: productId,
    );

    return result.fold(
      (failure) => _addProductFailure(
        message: failure.message,
        status: AddProductToCartStatus.verificationFailed,
      ),
      (latestProduct) {
        final latestProductId = (latestProduct?.id ?? '').trim();
        final latestShopId = latestProduct?.shopId.trim() ?? '';

        if (latestProduct == null ||
            latestProductId.isEmpty ||
            latestShopId != normalizedShopId ||
            latestProduct.isHiddenFromCustomers) {
          return _addProductFailure(
            message: AppStrings.productUnavailableNow,
            status: AddProductToCartStatus.unavailable,
          );
        }

        if (latestProduct.isOutOfStock) {
          return _addProductFailure(
            message: AppStrings.productUnavailableNow,
            status: AddProductToCartStatus.outOfStock,
          );
        }

        addProduct(
          arguments.copyWith(
            product: latestProduct,
            shippingPrice: shopValidation.shippingPrice,
          ),
        );
        return AddProductToCartResult.added(latestProduct);
      },
    );
  }

  void initializeCart(CartViewArguments? arguments) {
    if (arguments == null) return;

    final incomingProduct = arguments.product;
    final incomingProductId = incomingProduct?.id?.trim();
    if (incomingProduct == null ||
        incomingProduct.isUnavailableForPurchase ||
        incomingProductId == null ||
        incomingProductId.isEmpty ||
        state.items.any(
          (item) => item.product.id?.trim() == incomingProductId,
        )) {
      return;
    }

    final updatedItems = [
      ...state.items,
      CartLocalData(
        product: incomingProduct,
        quantity: arguments.quantity < 1 ? 1 : arguments.quantity,
        shippingPrice: arguments.shippingPrice,
      ),
    ];

    emit(
      CartInitial(
        items: updatedItems,
        shippingPrice: _shippingPriceFor(updatedItems),
      ),
    );
  }

  void updateQuantity(String productId, int quantity) {
    final normalizedProductId = productId.trim();
    if (normalizedProductId.isEmpty) return;

    final existingIndex = state.items.indexWhere(
      (item) => item.product.id?.trim() == normalizedProductId,
    );
    if (existingIndex == -1) return;

    final safeQuantity = quantity < 1 ? 1 : quantity;
    final shippingPrice = state.items[existingIndex].shippingPrice;
    final updatedItems = List<CartLocalData>.of(state.items);
    updatedItems[existingIndex] = CartLocalData(
      product: updatedItems[existingIndex].product,
      quantity: safeQuantity,
      shippingPrice: shippingPrice,
    );

    emit(
      CartInitial(
        items: updatedItems,
        shippingPrice: _shippingPriceFor(updatedItems),
      ),
    );

    unawaited(
      CartLocalStorage.updateProductQuantity(
        userId: _userId,
        productId: normalizedProductId,
        quantity: safeQuantity,
        shippingPrice: shippingPrice,
      ),
    );
  }

  void removeItem(String productId) {
    final normalizedProductId = productId.trim();
    if (normalizedProductId.isEmpty) return;

    final hasMatchingItem = state.items.any(
      (item) => item.product.id?.trim() == normalizedProductId,
    );
    if (!hasMatchingItem) return;

    final updatedItems =
        state.items
            .where((item) => item.product.id?.trim() != normalizedProductId)
            .toList();

    emit(
      CartInitial(
        items: updatedItems,
        shippingPrice: _shippingPriceFor(updatedItems),
      ),
    );

    unawaited(
      CartLocalStorage.removeProduct(
        userId: _userId,
        productId: normalizedProductId,
      ),
    );
  }

  void clearProductFromOtherShop(String? shopId) {
    final normalizedShopId = shopId?.trim();
    if (normalizedShopId == null || normalizedShopId.isEmpty) return;

    final shopItems = _cartItemsForShop(state.items, normalizedShopId);
    if (shopItems.length == state.items.length) return;

    emit(
      CartInitial(
        items: shopItems,
        shippingPrice: _shippingPriceFor(shopItems),
      ),
    );

    unawaited(_persistShopItems(items: shopItems, shopId: normalizedShopId));
  }

  Future<void> applySyncedItems({
    required List<CartLocalData> items,
    String? shopId,
  }) async {
    await _persistShopItems(items: items, shopId: shopId);
    if (isClosed) return;

    emit(CartInitial(items: items, shippingPrice: _shippingPriceFor(items)));
  }

  Future<void> clearItemsForShop({
    required String shopId,
    required int shippingPrice,
  }) async {
    final normalizedShopId = shopId.trim();
    if (normalizedShopId.isEmpty) return;

    await _persistShopItems(items: const [], shopId: normalizedShopId);
    if (isClosed) return;

    _isInitialized = false;
    _lastRestoredShopId = null;

    emit(CartInitial(items: const [], shippingPrice: shippingPrice));
  }

  CartError _errorFromItems(List<CartLocalData> items, String message) {
    return CartError(
      message,
      items: items,
      shippingPrice: _shippingPriceFor(items),
    );
  }

  AddProductToCartResult _addProductFailure({
    required String message,
    required AddProductToCartStatus status,
  }) {
    emit(_errorFromItems(state.items, message));
    return AddProductToCartResult.failure(status: status, message: message);
  }

  Future<void> _persistShopItems({
    required List<CartLocalData> items,
    String? shopId,
  }) async {
    final resolvedShopId = _cartAvailabilityService.resolveShopId(
      items: items,
      shopId: shopId,
    );
    if (resolvedShopId == null || resolvedShopId.isEmpty) {
      await CartLocalStorage.replaceCart(userId: _userId, items: items);
      return;
    }

    final fullCart = await CartLocalStorage.loadProducts(userId: _userId);
    final otherShopItems =
        fullCart
            .where((item) => item.product.shopId.trim() != resolvedShopId)
            .toList();
    await CartLocalStorage.replaceCart(
      userId: _userId,
      items: [...otherShopItems, ...items],
    );
  }

  List<CartLocalData> _cartItemsForShop(
    List<CartLocalData> cart,
    String? shopId,
  ) {
    final normalizedShopId = shopId?.trim();
    if (normalizedShopId == null || normalizedShopId.isEmpty) return cart;

    return cart
        .where((item) => item.product.shopId.trim() == normalizedShopId)
        .toList();
  }

  List<CartLocalData> _mergeCartItems(
    List<CartLocalData> savedItems,
    List<CartLocalData> currentItems,
  ) {
    final mergedItems = List<CartLocalData>.of(savedItems);

    for (final currentItem in currentItems) {
      final productId = currentItem.product.id?.trim();
      final existingIndex = mergedItems.indexWhere(
        (item) => item.product.id?.trim() == productId,
      );

      if (existingIndex == -1) {
        mergedItems.add(currentItem);
      } else {
        mergedItems[existingIndex] = currentItem;
      }
    }

    return mergedItems;
  }

  int _shippingPriceFor(List<CartLocalData> items) {
    if (items.isEmpty) return state.shippingPrice;
    return items.first.shippingPrice;
  }

  AddProductToCartStatus _mapAddToCartStatus(CartShopValidationStatus status) {
    return switch (status) {
      CartShopValidationStatus.valid => AddProductToCartStatus.added,
      CartShopValidationStatus.shopClosed => AddProductToCartStatus.shopClosed,
      CartShopValidationStatus.unavailable =>
        AddProductToCartStatus.unavailable,
      CartShopValidationStatus.verificationFailed =>
        AddProductToCartStatus.verificationFailed,
    };
  }
}

enum AddProductToCartStatus {
  added,
  invalidProduct,
  shopClosed,
  unavailable,
  outOfStock,
  verificationFailed,
}

class AddProductToCartResult {
  const AddProductToCartResult._({
    required this.status,
    this.product,
    this.message,
  });

  factory AddProductToCartResult.added(ProductModel product) {
    return AddProductToCartResult._(
      status: AddProductToCartStatus.added,
      product: product,
    );
  }

  factory AddProductToCartResult.failure({
    required AddProductToCartStatus status,
    required String message,
  }) {
    return AddProductToCartResult._(status: status, message: message);
  }

  final AddProductToCartStatus status;
  final ProductModel? product;
  final String? message;

  bool get wasAdded => status == AddProductToCartStatus.added;
  bool get wasBlockedByClosedShop =>
      status == AddProductToCartStatus.shopClosed;
}
