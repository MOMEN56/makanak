import 'package:equatable/equatable.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';

sealed class CartState extends Equatable {
  const CartState({
    this.product,
    this.quantity = 1,
    this.shippingPrice = 35,
  });

  final ProductModel? product;
  final int quantity;
  final int shippingPrice;

  int get itemsSubtotal => product == null ? 0 : product!.price * quantity;
  int get orderTotal => itemsSubtotal + shippingPrice;

  @override
  List<Object?> get props => [product, quantity, shippingPrice];
}

class CartInitial extends CartState {
  const CartInitial({
    super.product,
    super.quantity,
    super.shippingPrice,
  });
}

class CartLoading extends CartState {
  const CartLoading({
    super.product,
    super.quantity,
    super.shippingPrice,
  });
}

class CartOrderSubmitted extends CartState {
  const CartOrderSubmitted({
    super.product,
    super.quantity,
    super.shippingPrice,
  });
}

class CartError extends CartState {
  const CartError(
    this.message, {
    super.product,
    super.quantity,
    super.shippingPrice,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
