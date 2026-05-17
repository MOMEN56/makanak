import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/cart_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class CartNavigationTab extends StatelessWidget {
  const CartNavigationTab({super.key, this.shopModel, this.onBack});

  final ShopModel? shopModel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final cartArguments =
        shopModel == null
            ? null
            : CartViewArguments(
              product: null,
              quantity: 1,
              primaryColor: AppColors.primaryColor,
              shopModel: shopModel,
            );

    return CartView(
      cartArguments: cartArguments,
      bottomContentPadding:
          AppSpacing.buttonBottomExtraGapWithLiquidGlassNavigation,
      onBack: onBack,
    );
  }
}
