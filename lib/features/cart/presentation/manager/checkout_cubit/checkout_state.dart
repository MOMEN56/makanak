import 'package:equatable/equatable.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => const [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(
    this.message, {
    required this.failureId,
    this.syncedItems,
    this.syncedShopId,
  });

  final String message;
  final int failureId;
  final List<CartLocalData>? syncedItems;
  final String? syncedShopId;

  @override
  List<Object?> get props => [message, failureId, syncedItems, syncedShopId];
}

class CheckoutSubmitted extends CheckoutState {
  const CheckoutSubmitted({required this.shopId, required this.shippingPrice});

  final String shopId;
  final int shippingPrice;

  @override
  List<Object?> get props => [shopId, shippingPrice];
}
