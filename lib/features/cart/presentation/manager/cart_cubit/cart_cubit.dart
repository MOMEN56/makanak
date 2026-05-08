import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._cartRepository) : super(const CartInitial());

  final CartRepository _cartRepository;

  Future<void> restoreSavedCart({String? shopId}) async {
    final savedCart = await CartLocalStorage.loadProduct();
    if (savedCart == null || isClosed) return;

    if (shopId != null &&
        shopId.isNotEmpty &&
        savedCart.product.shopId != shopId) {
      await CartLocalStorage.clear();
      return;
    }

    emit(
      CartInitial(
        product: savedCart.product,
        quantity: savedCart.quantity < 1 ? 1 : savedCart.quantity,
        shippingPrice: savedCart.shippingPrice,
      ),
    );
  }

  void addProduct(CartViewArguments arguments) {
    final currentProduct = state.product;
    final incomingProduct = arguments.product;
    if (incomingProduct == null) return;

    final currentProductId = currentProduct?.id;
    final incomingProductId = incomingProduct.id;
    final isSameProduct =
        currentProductId != null &&
        currentProductId.isNotEmpty &&
        currentProductId == incomingProductId;
    final updatedQuantity =
        isSameProduct ? state.quantity + arguments.quantity : arguments.quantity;
    final safeQuantity = updatedQuantity < 1 ? 1 : updatedQuantity;

    emit(
      CartInitial(
        product: incomingProduct,
        quantity: safeQuantity,
        shippingPrice: arguments.shippingPrice,
      ),
    );

    unawaited(
      CartLocalStorage.saveProduct(
        product: incomingProduct,
        quantity: safeQuantity,
        shippingPrice: arguments.shippingPrice,
      ),
    );
  }

  void initializeCart(CartViewArguments? arguments) {
    if (arguments == null) return;

    final currentProductId = state.product?.id;
    final incomingProductId = arguments.product?.id;
    final isSameInitializedProduct =
        currentProductId != null &&
        currentProductId.isNotEmpty &&
        currentProductId == incomingProductId;

    if (isSameInitializedProduct) {
      emit(
        CartInitial(
          product: state.product,
          quantity: arguments.quantity,
          shippingPrice: arguments.shippingPrice,
        ),
      );
      return;
    }

    emit(
      CartInitial(
        product: arguments.product,
        quantity: arguments.quantity,
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
      unawaited(CartLocalStorage.clear());
      emit(
        CartOrderSubmitted(
          product: state.product,
          quantity: state.quantity,
          shippingPrice: state.shippingPrice,
        ),
      );
    });
  }

  void updateQuantity(int quantity) {
    final safeQuantity = quantity < 1 ? 1 : quantity;
    emit(
      CartInitial(
        product: state.product,
        quantity: safeQuantity,
        shippingPrice: state.shippingPrice,
      ),
    );

    final product = state.product;
    if (product != null) {
      unawaited(
        CartLocalStorage.saveProduct(
          product: product,
          quantity: safeQuantity,
          shippingPrice: state.shippingPrice,
        ),
      );
    }
  }

  void removeItem() {
    emit(CartInitial(shippingPrice: state.shippingPrice));
    unawaited(CartLocalStorage.clear());
  }

  void clearProductFromOtherShop(String? shopId) {
    if (shopId == null || shopId.isEmpty) return;
    final product = state.product;
    if (product == null || product.shopId == shopId) return;

    removeItem();
  }

  CartLoading _loadingFromState() {
    return CartLoading(
      product: state.product,
      quantity: state.quantity,
      shippingPrice: state.shippingPrice,
    );
  }

  CartError _errorFromState(String message) {
    return CartError(
      message,
      product: state.product,
      quantity: state.quantity,
      shippingPrice: state.shippingPrice,
    );
  }
}
