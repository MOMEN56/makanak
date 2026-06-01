import 'package:flutter/material.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_view_body.dart';

class CartView extends StatelessWidget {
  const CartView({
    super.key,
    this.cartArguments,
    this.bottomContentPadding = 0,
    this.onBack,
    this.onContinueRequested,
  });

  static const String routeName = 'cart';

  final CartViewArguments? cartArguments;
  final double bottomContentPadding;
  final VoidCallback? onBack;
  final void Function(CartViewArguments? routeArguments, bool hasSavedAddress)?
  onContinueRequested;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CartViewBody(
        cartArguments: cartArguments,
        bottomContentPadding: bottomContentPadding,
        onBack: onBack,
        onContinueRequested: onContinueRequested,
      ),
    );
  }
}
