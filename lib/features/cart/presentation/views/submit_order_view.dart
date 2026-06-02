import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/widgets/submit_order_view_body.dart';

class SubmitOrderView extends StatelessWidget {
  const SubmitOrderView({
    super.key,
    this.cartArguments,
    this.bottomContentPadding = 0,
  });

  static const String routeName = 'submit_order';

  final CartViewArguments? cartArguments;
  final double bottomContentPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SubmitOrderViewBody(
        cartArguments: cartArguments,
        bottomContentPadding: bottomContentPadding,
      ),
    );
  }
}
