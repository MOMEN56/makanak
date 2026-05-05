import 'package:flutter/material.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';

class CartRouteArgumentsBuilder {
  const CartRouteArgumentsBuilder._();

  static CartViewArguments? fromState({
    required CartState state,
    required Color primaryColor,
    CartViewArguments? fallback,
  }) {
    final product = state.product ?? fallback?.product;
    if (product == null) return fallback;

    return CartViewArguments(
      product: product,
      quantity: state.quantity,
      primaryColor: primaryColor,
      shopModel: fallback?.shopModel,
      shippingPrice: state.shippingPrice,
    );
  }
}
