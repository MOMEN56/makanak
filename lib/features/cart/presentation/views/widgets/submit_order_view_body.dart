import 'dart:async';

import 'package:flutter/material.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/order_history/presentation/views/order_history_view.dart';
import 'package:makanak/features/shop/presentation/views/products_view.dart';
import 'package:makanak/features/shop/presentation/views/shop_navigation_view.dart';
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

  ProductsRouteArguments? get _productsRouteArguments {
    final shopModel = widget.cartArguments?.shopModel;
    if (shopModel == null) return null;

    final arguments = ProductsRouteArguments.fromShop(shopModel);
    return arguments.isValid ? arguments : null;
  }

  @override
  void initState() {
    super.initState();
    _checkTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _showCheck = true);
    });
    _redirectTimer = Timer(
      const Duration(seconds: 5),
      _goToScreenAfterConfirmingOrder,
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _goToScreenAfterConfirmingOrder() {
    if (!mounted || _didNavigate) return;
    _didNavigate = true;
    _redirectTimer?.cancel();

    Navigator.pushNamedAndRemoveUntil(
      context,
      _productsRouteArguments == null
          ? ShopsView.routeName
          : ProductsView.routeName,
      (route) => false,
      arguments: _productsRouteArguments,
    );
  }

  void _goToOrderHistory() {
    if (!mounted || _didNavigate) return;

    _didNavigate = true;
    _redirectTimer?.cancel();

    Navigator.pushNamedAndRemoveUntil(
      context,
      _productsRouteArguments == null
          ? OrderHistoryView.routeName
          : ProductsView.routeName,
      (route) => false,
      arguments:
          _productsRouteArguments == null
              ? null
              : ProductsRouteArguments(
                shop: _productsRouteArguments!.shop,
                initialNavigationIndex: ShopNavigationView.orderHistoryTabIndex,
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _primaryColor;

    return SafeArea(
      child: Padding(
        padding: AppResponsive.all(context, AppSpacing.screenEdge),
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
              onTap: _goToOrderHistory,
              hasShadowEffect: true,
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
