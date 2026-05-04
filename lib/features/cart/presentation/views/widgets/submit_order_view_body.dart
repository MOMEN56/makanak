import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/shop/presentation/views/products_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/presentation/views/shops_view.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class SubmitOrderViewBody extends StatefulWidget {
  const SubmitOrderViewBody({super.key, this.cartArguments});

  final CartViewArguments? cartArguments;

  @override
  State<SubmitOrderViewBody> createState() => _SubmitOrderViewBodyState();
}

class _SubmitOrderViewBodyState extends State<SubmitOrderViewBody> {
  Timer? _checkTimer;
  Timer? _redirectTimer;
  bool _showCheck = false;
  bool _didNavigate = false;

  Color get _primaryColor {
    return widget.cartArguments?.primaryColor ?? AppColors.primaryColor;
  }

  ShopModel? get _shopModel => widget.cartArguments?.shopModel;

  @override
  void initState() {
    super.initState();
    _checkTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _showCheck = true);
    });
    _redirectTimer = Timer(const Duration(seconds: 6), _goToShopProducts);
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _goToShopProducts() {
    if (!mounted || _didNavigate) return;
    _didNavigate = true;
    _redirectTimer?.cancel();

    final shopModel = _shopModel;
    if (shopModel == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        ShopsView.routeName,
        (route) => false,
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      ProductsView.routeName,
      (route) => false,
      arguments: shopModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _primaryColor;

    return SafeArea(
      child: Padding(
        padding: AppResponsive.all(context, 20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AnimatedScale(
                  scale: _showCheck ? 1 : 0.92,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedOpacity(
                      opacity: _showCheck ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: 88,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            CustomButton(
              hint: AppStrings.trackOrder,
              onTap: _goToShopProducts,
              hasShadowEffect: true,
              color: primaryColor,
            ),
            const Gap(12),
          ],
        ),
      ),
    );
  }
}
