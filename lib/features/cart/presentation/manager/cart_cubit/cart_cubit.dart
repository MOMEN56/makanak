import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/cart/domain/entities/create_order_item.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/domain/entities/product_availability_extension.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(
    this._cartRepository,
    this._productsRepo,
    this._shopsRepo, {required String userId})
    : _userId = userId,
      super(CartInitial());

  final CartRepository _cartRepository;
  final ProductsRepo _productsRepo;
  final ShopsRepo _shopsRepo;
  final String _userId;
  String? _lastRestoredShopId;
  bool _isInitialized = false;
  bool _isCreatingOrder = false;

  Future<void> restoreSavedCart({String? shopId}) async {
    if (_isInitialized && _lastRestoredShopId == shopId) return;
    _isInitialized = true;
    _lastRestoredShopId = shopId;

    final savedCart = await CartLocalStorage.loadProducts(userId: _userId);
    final shopCart = _mergeCartItems(
      _cartItemsForShop(savedCart, shopId),
      _cartItemsForShop(state.items, shopId),
    );
    if (isClosed) return;

    emit(
      CartInitial(items: shopCart, shippingPrice: _shippingPriceFor(shopCart)),
    );
    if (shopCart.isEmpty) return;

    await refreshCartAvailability(shopId: shopId);
  }

  Future<void> refreshCartAvailability({String? shopId}) async {
    final syncResult = await _syncCartItems(
      sourceItems: _cartItemsForShop(state.items, shopId),
      shopId: shopId,
    );
    if (!syncResult.didFetchLatestProducts) return;

    await _applySyncedItems(
      items: syncResult.availableItems,
      shopId: syncResult.shopId,
    );
  }

  void addProduct(CartViewArguments arguments) {
    final incomingProduct = arguments.product;
    if (incomingProduct == null || incomingProduct.isUnavailableForPurchase) {
      return;
    }

    final incomingProductId = incomingProduct.id;
    if (incomingProductId == null || incomingProductId.isEmpty) return;

    final currentItems = List<CartLocalData>.of(state.items);
    final existingIndex = currentItems.indexWhere(
      (item) => item.product.id == incomingProductId,
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

    final shopValidation = await _validateLatestShop(
      normalizedShopId,
      fetchFailureMessage: AppStrings.productAvailabilityCheckFailed,
    );
    if (!shopValidation.isValid) {
      return _addProductFailure(
        message: shopValidation.message,
        status: shopValidation.addToCartStatus,
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

        addProduct(arguments.copyWith(product: latestProduct));
        return AddProductToCartResult.added(latestProduct);
      },
    );
  }

  Future<String?> networkMessageBeforeCheckout({String? shopId}) async {
    final normalizedShopId = shopId?.trim();
    final resolvedShopId =
        normalizedShopId != null && normalizedShopId.isNotEmpty
            ? normalizedShopId
            : _shopIdForItems(state.items);

    if (resolvedShopId == null || resolvedShopId.isEmpty) {
      return null;
    }

    final result = await _shopsRepo.fetchShopById(resolvedShopId);
    return result.fold(
      (failure) => failure.isNetwork ? failure.message : null,
      (_) => null,
    );
  }

  void initializeCart(CartViewArguments? arguments) {
    if (arguments == null) return;

    final incomingProduct = arguments.product;
    final incomingProductId = incomingProduct?.id;
    if (incomingProduct == null ||
        incomingProduct.isUnavailableForPurchase ||
        incomingProductId == null ||
        incomingProductId.isEmpty ||
        state.items.any((item) => item.product.id == incomingProductId)) {
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

  Future<void> createOrder({required String addressId}) async {
    if (_isCreatingOrder) return;

    final currentItems = state.items;
    if (currentItems.isEmpty) {
      emit(_errorFromItems(currentItems, AppStrings.invalidProduct));
      return;
    }

    final shopId = _shopIdForItems(currentItems);
    if (shopId == null) {
      emit(_errorFromItems(currentItems, AppStrings.invalidProduct));
      return;
    }

    if (addressId.isEmpty) {
      emit(_errorFromItems(currentItems, AppStrings.invalidAddress));
      return;
    }

    _isCreatingOrder = true;
    try {
      final shopValidation = await _validateLatestShop(
        shopId,
        fetchFailureMessage: AppStrings.cartAvailabilityCheckFailed,
      );
      if (!shopValidation.isValid) {
        emit(_errorFromItems(currentItems, shopValidation.message));
        return;
      }

      final preSubmitSync = await _syncCartItems(
        sourceItems: currentItems,
        shopId: shopId,
      );
      if (preSubmitSync.syncFailed) {
        emit(
          _errorFromItems(
            currentItems,
            preSubmitSync.failureMessage ??
                AppStrings.cartAvailabilityCheckFailed,
          ),
        );
        return;
      }

      var itemsToSubmit = currentItems;

      if (preSubmitSync.didFetchLatestProducts) {
        itemsToSubmit = preSubmitSync.availableItems;
        await _applySyncedItems(
          items: itemsToSubmit,
          shopId: preSubmitSync.shopId,
        );
        if (isClosed) return;

        if (preSubmitSync.removedItems.isNotEmpty) {
          emit(
            _errorFromItems(
              itemsToSubmit,
              _messageForRemovedItems(preSubmitSync.removedItems),
            ),
          );
          return;
        }
      }

      final validatedShopId = _shopIdForItems(itemsToSubmit);
      final orderItems = _buildOrderItems(itemsToSubmit);
      final hasMixedShops =
          validatedShopId == null ||
          itemsToSubmit.any((item) => item.product.shopId != validatedShopId);

      if (validatedShopId == null ||
          hasMixedShops ||
          orderItems.length != itemsToSubmit.length) {
        emit(_errorFromItems(itemsToSubmit, AppStrings.invalidProduct));
        return;
      }

      emit(_loadingFromItems(itemsToSubmit));
      final result = await _cartRepository.createOrder(
        shopId: validatedShopId,
        addressId: addressId,
        shippingPrice: _shippingPriceFor(itemsToSubmit),
        items: orderItems,
      );
      if (isClosed) return;

      await result.fold<Future<void>>(
        (failure) async {
          if (_isShopStateFailureMessage(failure.message)) {
            emit(_errorFromItems(itemsToSubmit, failure.message));
            return;
          }

          final postFailureSync = await _syncCartItems(
            sourceItems: itemsToSubmit,
            shopId: validatedShopId,
          );
          if (postFailureSync.syncFailed) {
            emit(
              _errorFromItems(
                itemsToSubmit,
                postFailureSync.failureMessage ??
                    AppStrings.cartAvailabilityCheckFailed,
              ),
            );
            return;
          }

          if (postFailureSync.didFetchLatestProducts) {
            itemsToSubmit = postFailureSync.availableItems;
            await _applySyncedItems(
              items: itemsToSubmit,
              shopId: postFailureSync.shopId,
            );
            if (isClosed) return;

            if (postFailureSync.removedItems.isNotEmpty) {
              emit(
                _errorFromItems(
                  itemsToSubmit,
                  _messageForRemovedItems(postFailureSync.removedItems),
                ),
              );
              return;
            }
          }

          emit(_errorFromItems(itemsToSubmit, failure.message));
        },
        (_) async {
          final submittedShippingPrice = _shippingPriceFor(itemsToSubmit);
          await _persistShopItems(items: const [], shopId: validatedShopId);
          if (isClosed) return;

          _isInitialized = false;

          emit(CartOrderSubmitted(shippingPrice: submittedShippingPrice));
        },
      );
    } finally {
      _isCreatingOrder = false;
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (productId.isEmpty) return;

    final safeQuantity = quantity < 1 ? 1 : quantity;
    var shippingPrice = state.shippingPrice;
    final updatedItems =
        state.items.map((item) {
          if (item.product.id != productId) return item;

          shippingPrice = item.shippingPrice;
          return CartLocalData(
            product: item.product,
            quantity: safeQuantity,
            shippingPrice: item.shippingPrice,
          );
        }).toList();

    emit(
      CartInitial(
        items: updatedItems,
        shippingPrice: _shippingPriceFor(updatedItems),
      ),
    );

    unawaited(
      CartLocalStorage.updateProductQuantity(
        userId: _userId,
        productId: productId,
        quantity: safeQuantity,
        shippingPrice: shippingPrice,
      ),
    );
  }

  void removeItem(String productId) {
    if (productId.isEmpty) return;
    final updatedItems =
        state.items.where((item) => item.product.id != productId).toList();

    emit(
      CartInitial(
        items: updatedItems,
        shippingPrice: _shippingPriceFor(updatedItems),
      ),
    );

    unawaited(
      CartLocalStorage.removeProduct(userId: _userId, productId: productId),
    );
  }

  void clearProductFromOtherShop(String? shopId) {
    if (shopId == null || shopId.isEmpty) return;
    final shopItems = _cartItemsForShop(state.items, shopId);
    if (shopItems.length == state.items.length) return;

    emit(
      CartInitial(
        items: shopItems,
        shippingPrice: _shippingPriceFor(shopItems),
      ),
    );
  }

  CartLoading _loadingFromItems(List<CartLocalData> items) {
    return CartLoading(items: items, shippingPrice: _shippingPriceFor(items));
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

  Future<_ShopValidationResult> _validateLatestShop(
    String shopId, {
    required String fetchFailureMessage,
  }) async {
    final result = await _shopsRepo.fetchShopById(shopId);
    return result.fold(
      (failure) => _ShopValidationResult.failure(
        message: failure.isNetwork ? failure.message : fetchFailureMessage,
        addToCartStatus: AddProductToCartStatus.verificationFailed,
      ),
      (shop) {
        if (shop == null || !shop.isActive || !shop.isVisible) {
          return const _ShopValidationResult.failure(
            message: AppStrings.shopUnavailableNow,
            addToCartStatus: AddProductToCartStatus.unavailable,
          );
        }

        if (!shop.isOpen) {
          return const _ShopValidationResult.failure(
            message: AppStrings.shopClosedNow,
            addToCartStatus: AddProductToCartStatus.shopClosed,
          );
        }

        return const _ShopValidationResult.valid();
      },
    );
  }

  Future<void> _applySyncedItems({
    required List<CartLocalData> items,
    String? shopId,
  }) async {
    await _persistShopItems(items: items, shopId: shopId);
    if (isClosed) return;

    emit(CartInitial(items: items, shippingPrice: _shippingPriceFor(items)));
  }

  Future<void> _persistShopItems({
    required List<CartLocalData> items,
    String? shopId,
  }) async {
    final resolvedShopId = shopId ?? _shopIdForItems(items);
    if (resolvedShopId == null || resolvedShopId.isEmpty) {
      await CartLocalStorage.replaceCart(userId: _userId, items: items);
      return;
    }

    final fullCart = await CartLocalStorage.loadProducts(userId: _userId);
    final otherShopItems =
        fullCart
            .where((item) => item.product.shopId != resolvedShopId)
            .toList();
    await CartLocalStorage.replaceCart(
      userId: _userId,
      items: [...otherShopItems, ...items],
    );
  }

  Future<_CartSyncResult> _syncCartItems({
    required List<CartLocalData> sourceItems,
    String? shopId,
  }) async {
    final resolvedShopId = shopId ?? _shopIdForItems(sourceItems);
    if (sourceItems.isEmpty) {
      return _CartSyncResult(
        shopId: resolvedShopId,
        availableItems: const [],
        removedItems: const [],
        didFetchLatestProducts: true,
        syncFailed: false,
      );
    }

    if (resolvedShopId == null || resolvedShopId.isEmpty) {
      return _CartSyncResult(
        shopId: resolvedShopId,
        availableItems: sourceItems,
        removedItems: const [],
        didFetchLatestProducts: false,
        syncFailed: true,
      );
    }

    final productIds = sourceItems
        .map((item) => item.product.id?.trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (productIds.length != sourceItems.length) {
      return _CartSyncResult(
        shopId: resolvedShopId,
        availableItems: const [],
        removedItems: sourceItems
            .map(
              (item) => _RemovedCartItem(
                productName: _productNameFrom(item.product),
                reason: _RemovedCartItemReason.unavailable,
              ),
            )
            .toList(growable: false),
        didFetchLatestProducts: true,
        syncFailed: false,
      );
    }

    final result = await _productsRepo.fetchProductsByIds(
      shopId: resolvedShopId,
      productIds: productIds,
    );
    return result.fold(
      (failure) => _CartSyncResult(
        shopId: resolvedShopId,
        availableItems: sourceItems,
        removedItems: const [],
        didFetchLatestProducts: false,
        syncFailed: true,
        failureMessage: failure.isNetwork ? failure.message : null,
      ),
      (products) {
        final productsById = <String, ProductModel>{
          for (final product in products)
            if ((product.id ?? '').trim().isNotEmpty)
              product.id!.trim(): product,
        };
        final availableItems = <CartLocalData>[];
        final removedItems = <_RemovedCartItem>[];

        for (final item in sourceItems) {
          final productId = item.product.id?.trim() ?? '';
          final latestProduct = productsById[productId];
          final productName = _productNameFrom(latestProduct ?? item.product);

          if (latestProduct == null || latestProduct.isHiddenFromCustomers) {
            removedItems.add(
              _RemovedCartItem(
                productName: productName,
                reason: _RemovedCartItemReason.unavailable,
              ),
            );
            continue;
          }

          if (latestProduct.isOutOfStock) {
            removedItems.add(
              _RemovedCartItem(
                productName: productName,
                reason: _RemovedCartItemReason.outOfStock,
              ),
            );
            continue;
          }

          availableItems.add(
            CartLocalData(
              product: latestProduct,
              quantity: item.quantity,
              shippingPrice: item.shippingPrice,
            ),
          );
        }

        return _CartSyncResult(
          shopId: resolvedShopId,
          availableItems: availableItems,
          removedItems: removedItems,
          didFetchLatestProducts: true,
          syncFailed: false,
        );
      },
    );
  }

  List<CartLocalData> _cartItemsForShop(
    List<CartLocalData> cart,
    String? shopId,
  ) {
    if (shopId == null || shopId.isEmpty) return cart;

    return cart.where((item) => item.product.shopId == shopId).toList();
  }

  List<CartLocalData> _mergeCartItems(
    List<CartLocalData> savedItems,
    List<CartLocalData> currentItems,
  ) {
    final mergedItems = List<CartLocalData>.of(savedItems);

    for (final currentItem in currentItems) {
      final productId = currentItem.product.id;
      final existingIndex = mergedItems.indexWhere(
        (item) => item.product.id == productId,
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

  String? _shopIdForItems(List<CartLocalData> items) {
    if (items.isEmpty) return null;

    final shopId = items.first.product.shopId.trim();
    return shopId.isEmpty ? null : shopId;
  }

  List<CreateOrderItem> _buildOrderItems(List<CartLocalData> items) {
    return items
        .map(
          (item) => CreateOrderItem(
            productId: item.product.id ?? '',
            quantity: item.quantity,
          ),
        )
        .where((item) => item.productId.trim().isNotEmpty)
        .toList(growable: false);
  }

  String _messageForRemovedItems(List<_RemovedCartItem> removedItems) {
    if (removedItems.length == 1) {
      final removedItem = removedItems.first;
      return switch (removedItem.reason) {
        _RemovedCartItemReason.outOfStock =>
          AppStrings.outOfStockProductRemovedFromCart(removedItem.productName),
        _RemovedCartItemReason.unavailable =>
          AppStrings.unavailableProductRemovedFromCart(removedItem.productName),
      };
    }

    final allOutOfStock = removedItems.every(
      (item) => item.reason == _RemovedCartItemReason.outOfStock,
    );
    if (allOutOfStock) {
      return AppStrings.outOfStockProductsRemovedFromCart;
    }

    return AppStrings.unavailableProductsRemovedFromCart;
  }

  String _productNameFrom(ProductModel product) {
    final productName = product.name.trim();
    if (productName.isNotEmpty) {
      return productName;
    }

    return AppStrings.product;
  }

  bool _isShopStateFailureMessage(String message) {
    return message == AppStrings.shopClosedNow ||
        message == AppStrings.shopUnavailableNow;
  }
}

class _CartSyncResult {
  const _CartSyncResult({
    required this.shopId,
    required this.availableItems,
    required this.removedItems,
    required this.didFetchLatestProducts,
    this.syncFailed = false,
    this.failureMessage,
  });

  final String? shopId;
  final List<CartLocalData> availableItems;
  final List<_RemovedCartItem> removedItems;
  final bool didFetchLatestProducts;
  final bool syncFailed;
  final String? failureMessage;
}

class _RemovedCartItem {
  const _RemovedCartItem({required this.productName, required this.reason});

  final String productName;
  final _RemovedCartItemReason reason;
}

enum _RemovedCartItemReason { outOfStock, unavailable }

enum AddProductToCartStatus {
  added,
  invalidProduct,
  shopClosed,
  unavailable,
  outOfStock,
  verificationFailed,
}

class _ShopValidationResult {
  const _ShopValidationResult._({
    required this.isValid,
    required this.message,
    required this.addToCartStatus,
  });

  const _ShopValidationResult.valid()
    : this._(
        isValid: true,
        message: '',
        addToCartStatus: AddProductToCartStatus.added,
      );

  const _ShopValidationResult.failure({
    required String message,
    required AddProductToCartStatus addToCartStatus,
  }) : this._(
         isValid: false,
         message: message,
         addToCartStatus: addToCartStatus,
       );

  final bool isValid;
  final String message;
  final AddProductToCartStatus addToCartStatus;
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





