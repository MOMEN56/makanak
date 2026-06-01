import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_cubit.dart';
import 'package:makanak/features/shop/presentation/views/shop_navigation_view.dart';
import 'package:makanak/features/shop/presentation/views/widgets/products_view_body.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/keyboard_dismiss_on_tap.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({
    super.key,
    required this.shopModel,
    this.bottomContentPadding = 0,
    this.onCartRequested,
    this.onFullScreenNetworkStateChanged,
    this.initialNavigationIndex = 0,
  });

  static const String routeName = 'products_list';

  final ShopModel shopModel;
  final double bottomContentPadding;
  final VoidCallback? onCartRequested;
  final ValueChanged<bool>? onFullScreenNetworkStateChanged;
  final int initialNavigationIndex;

  bool get _isInsideShopNavigation => onCartRequested != null;

  @override
  Widget build(BuildContext context) {
    if (!_isInsideShopNavigation) {
      return ShopNavigationView(
        shopModel: shopModel,
        initialIndex: initialNavigationIndex,
      );
    }

    return BlocProvider(
      create: (_) => getIt<ProductsCubit>()..fetchProducts(shopModel.id ?? ''),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: KeyboardDismissOnTap(
          child: ProductsViewBody(
            shopModel: shopModel,
            bottomContentPadding: bottomContentPadding,
            onCartRequested: onCartRequested,
            onFullScreenNetworkStateChanged: onFullScreenNetworkStateChanged,
          ),
        ),
      ),
    );
  }
}
