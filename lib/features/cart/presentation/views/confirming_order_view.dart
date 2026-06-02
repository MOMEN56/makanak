import 'package:flutter/material.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/widgets/confirming_order_view_body.dart';

class ConfirmingOrderView extends StatelessWidget {
  const ConfirmingOrderView({
    super.key,
    this.cartArguments,
    this.bottomContentPadding = 0,
  });

  static const String routeName = 'confirming_order';

  final CartViewArguments? cartArguments;
  final double bottomContentPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConfirmingOrderViewBody(
        cartArguments: cartArguments,
        bottomContentPadding: bottomContentPadding,
        showAddressStep: false,
      ),
    );
  }
}
