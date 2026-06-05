import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/bottom_navigation_item.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/cart_navigation_tab.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/liquid_glass_bottom_navigation.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit_registry.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/order_history/presentation/views/order_history_view.dart';
import 'package:makanak/features/profile/presentation/views/profile_view.dart';
import 'package:makanak/features/shop/presentation/views/products_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class ShopNavigationView extends StatefulWidget {
  const ShopNavigationView({
    super.key,
    required this.shopModel,
    this.initialIndex = homeTabIndex,
  });

  static const homeTabIndex = 0;
  static const cartTabIndex = 1;
  static const orderHistoryTabIndex = 2;

  final ShopModel shopModel;
  final int initialIndex;

  @override
  State<ShopNavigationView> createState() => _ShopNavigationViewState();
}

class _ShopNavigationViewState extends State<ShopNavigationView> {
  int _currentIndex = 0;
  int _cartAnimationTrigger = 0;
  late final CartCubit _cartCubit;
  late final StreamSubscription<CartState> _cartSubscription;
  int _lastCartItemCount = 0;
  bool _isRestoringCart = true;
  bool _isShowingProductsNoInternet = false;
  bool _isShowingOrderHistoryNoInternet = false;

  static const _items = [
    BottomNavigationItemData(icon: Icons.home_rounded, label: AppStrings.home),
    BottomNavigationItemData(
      icon: Icons.shopping_cart_rounded,
      label: AppStrings.cart,
    ),
    BottomNavigationItemData(
      icon: Icons.receipt_long_rounded,
      label: AppStrings.orderHistory,
    ),
    BottomNavigationItemData(
      icon: Icons.person_rounded,
      label: AppStrings.account,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = _validatedInitialIndex(widget.initialIndex);
    _cartCubit = getIt<CartCubitRegistry>().forUser(
      requireAuthenticatedUserId(),
    );
    _cartCubit.clearProductFromOtherShop(widget.shopModel.id);
    _lastCartItemCount = _cartCubit.state.itemCount;
    _cartSubscription = _cartCubit.stream.listen(_handleCartStateChanged);
    unawaited(_restoreSavedCart());
  }

  Future<void> _restoreSavedCart() async {
    await _cartCubit.restoreSavedCart(shopId: widget.shopModel.id);
    if (!mounted) return;

    _lastCartItemCount = _cartCubit.state.itemCount;
    _isRestoringCart = false;
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowBottomNavigation = switch (_currentIndex) {
      0 => !_isShowingProductsNoInternet,
      1 => true,
      2 => !_isShowingOrderHistoryNoInternet,
      3 => true,
      _ => true,
    };

    return MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>.value(value: _cartCubit),
        BlocProvider<AddressCubit>(create: (_) => getIt<AddressCubit>()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.greyBackground,
        resizeToAvoidBottomInset: false,
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
                    onFullScreenNetworkStateChanged:
                        _handleProductsNoInternetStateChanged,
                  ),
                  CartNavigationTab(
                    shopModel: widget.shopModel,
                    onBack: () => _selectTab(0),
                  ),
                  OrderHistoryView(
                    onFullScreenNetworkStateChanged:
                        _handleOrderHistoryNoInternetStateChanged,
                  ),
                  const ProfileView(
                    addAddressBottomPadding:
                        AppSpacing.buttonBottomExtraGapWithLiquidGlassNavigation,
                  ),
                ],
              ),
            ),
            if (shouldShowBottomNavigation)
              PositionedDirectional(
                start: 20,
                end: 20,
                bottom: 25,
                child: BlocSelector<CartCubit, CartState, int>(
                  selector: (state) => state.itemCount,
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

    if (index == 1) {
      unawaited(_cartCubit.refreshCartAvailability(shopId: widget.shopModel.id));
    }
  }

  void _animateCartTab() {
    setState(() {
      _cartAnimationTrigger++;
    });
  }

  void _handleCartStateChanged(CartState state) {
    final nextItemCount = state.itemCount;
    if (!_isRestoringCart &&
        _currentIndex != 1 &&
        nextItemCount > _lastCartItemCount &&
        mounted) {
      _animateCartTab();
    }

    _lastCartItemCount = nextItemCount;
  }

  void _handleProductsNoInternetStateChanged(bool isShowing) {
    if (!mounted || _isShowingProductsNoInternet == isShowing) {
      return;
    }

    setState(() {
      _isShowingProductsNoInternet = isShowing;
    });
  }

  void _handleOrderHistoryNoInternetStateChanged(bool isShowing) {
    if (!mounted || _isShowingOrderHistoryNoInternet == isShowing) {
      return;
    }

    setState(() {
      _isShowingOrderHistoryNoInternet = isShowing;
    });
  }

  int _validatedInitialIndex(int index) {
    if (index < 0 || index >= _items.length) {
      return ShopNavigationView.homeTabIndex;
    }

    return index;
  }

  @override
  void dispose() {
    _cartSubscription.cancel();
    super.dispose();
  }
}


