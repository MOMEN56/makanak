import 'package:flutter/material.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_view_body.dart';

class CartView extends StatelessWidget {
  const CartView({super.key, this.cartArguments});

  static const String routeName = 'cart';

  final CartViewArguments? cartArguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CartViewBody(cartArguments: cartArguments));
  }
}
