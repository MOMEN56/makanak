import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._cartRepository, {required String userId})
    : _userId = userId,
      super(CartInitial());

  final CartRepository _cartRepository;
  final String _userId;

  Future<void> restoreSavedCart({String? shopId}) async {
    final savedCart = await CartLocalStorage.loadProducts(userId: _userId);
    final shopCart = _mergeCartItems(
      _cartItemsForShop(savedCart, shopId),
      _cartItemsForShop(state.items, shopId),
    );
    if (shopCart.isEmpty || isClosed) return;

    emit(
      CartInitial(items: shopCart, shippingPrice: shopCart.first.shippingPrice),
    );
  }

  void addProduct(CartViewArguments arguments) {
    final incomingProduct = arguments.product;
    if (incomingProduct == null) return;

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
        shippingPrice: arguments.shippingPrice,
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

  void initializeCart(CartViewArguments? arguments) {
    if (arguments == null) return;

    final incomingProduct = arguments.product;
    final incomingProductId = incomingProduct?.id;
    if (incomingProduct == null ||
        incomingProductId == null ||
        incomingProductId.isEmpty ||
        state.items.any((item) => item.product.id == incomingProductId)) {
      return;
    }

    emit(
      CartInitial(
        items: [
          ...state.items,
          CartLocalData(
            product: incomingProduct,
            quantity: arguments.quantity < 1 ? 1 : arguments.quantity,
            shippingPrice: arguments.shippingPrice,
          ),
        ],
        shippingPrice: arguments.shippingPrice,
      ),
    );
  }

  Future<void> createOrder({required String addressId}) async {
    final product = state.product;
    final productId = product?.id;
    if (product == null || productId == null || productId.isEmpty) {
      emit(_errorFromState(AppStrings.invalidProduct));
      return;
    }

    if (addressId.isEmpty) {
      emit(_errorFromState(AppStrings.invalidAddress));
      return;
    }

    emit(_loadingFromState());
    final result = await _cartRepository.createOrder(
      shopId: product.shopId,
      productId: productId,
      addressId: addressId,
      quantity: state.quantity,
      itemsTotal: state.itemsSubtotal,
      shippingPrice: state.shippingPrice,
    );
    if (isClosed) return;

    result.fold((failure) => emit(_errorFromState(failure.message)), (_) {
      unawaited(
        CartLocalStorage.removeProduct(userId: _userId, productId: productId),
      );
      emit(
        CartOrderSubmitted(
          items: state.items,
          shippingPrice: state.shippingPrice,
        ),
      );
    });
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

    emit(CartInitial(items: updatedItems, shippingPrice: state.shippingPrice));

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

    emit(CartInitial(items: updatedItems, shippingPrice: state.shippingPrice));

    unawaited(
      CartLocalStorage.removeProduct(userId: _userId, productId: productId),
    );
  }

  void clearProductFromOtherShop(String? shopId) {
    if (shopId == null || shopId.isEmpty) return;
    final shopItems = _cartItemsForShop(state.items, shopId);
    if (shopItems.length == state.items.length) return;

    emit(CartInitial(items: shopItems, shippingPrice: state.shippingPrice));
  }

  CartLoading _loadingFromState() {
    return CartLoading(items: state.items, shippingPrice: state.shippingPrice);
  }

  CartError _errorFromState(String message) {
    return CartError(
      message,
      items: state.items,
      shippingPrice: state.shippingPrice,
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
}
