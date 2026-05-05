import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/bottom_navigation_item.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/cart_navigation_tab.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/liquid_glass_bottom_navigation.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/order_history/presentation/views/order_history_view.dart';
import 'package:makanak/features/profile/presentation/views/profile_view.dart';
import 'package:makanak/features/shop/presentation/views/products_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class ShopNavigationView extends StatefulWidget {
  const ShopNavigationView({super.key, required this.shopModel});

  final ShopModel shopModel;

  @override
  State<ShopNavigationView> createState() => _ShopNavigationViewState();
}

class _ShopNavigationViewState extends State<ShopNavigationView> {
  int _currentIndex = 0;
  int _cartAnimationTrigger = 0;

  static const _items = [
    BottomNavigationItemData(icon: Icons.home_rounded, label: 'الرئيسية'),
    BottomNavigationItemData(icon: Icons.shopping_cart_rounded, label: 'السلة'),
    BottomNavigationItemData(
      icon: Icons.receipt_long_rounded,
      label: 'سجل الطلبات',
    ),
    BottomNavigationItemData(icon: Icons.person_rounded, label: 'الحساب'),
  ];

  @override
  void initState() {
    super.initState();
    final cartCubit = getIt<CartCubit>();
    cartCubit.clearProductFromOtherShop(widget.shopModel.id);
    unawaited(cartCubit.restoreSavedCart(shopId: widget.shopModel.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartCubit>.value(
      value: getIt<CartCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.greyBackground,
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  ProductsView(
                    shopModel: widget.shopModel,
                    bottomContentPadding:
                        AppSpacing
                            .buttonBottomExtraGapWithLiquidGlassNavigation,
                    onCartRequested: () => _selectTab(1),
                    onProductAdded: _animateCartTab,
                  ),
                  CartNavigationTab(onBack: () => _selectTab(0)),
                  const OrderHistoryView(),
                  const ProfileView(),
                ],
              ),
            ),

            PositionedDirectional(
              start: 20,
              end: 20,
              bottom: 25,
              child: BlocSelector<CartCubit, CartState, int>(
                selector: (state) => state.product == null ? 0 : state.quantity,
                builder: (context, cartCount) {
                  return LiquidGlassBottomNavigation(
                    currentIndex: _currentIndex,
                    items: _items,
                    cartAnimationTrigger: _cartAnimationTrigger,
                    cartBadgeCount: cartCount,
                    onItemSelected: _selectTab,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _animateCartTab() {
    setState(() {
      _cartAnimationTrigger++;
    });
  }
}
