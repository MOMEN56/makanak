import 'package:flutter/material.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/cart_view.dart';
import 'package:makanak/features/shop/presentation/views/products_view.dart';
import 'package:makanak/features/shop/presentation/views/shop_navigation_view.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';

void showProductAddedSnackBar({
  required BuildContext context,
  required ProductModel product,
  required Color shopColor,
  ShopModel? shopModel,
  int quantity = 1,
  VoidCallback? onCartTap,
}) {
  final quantityText = quantity > 1 ? ' $quantity' : '';

  AppSnackBar.show(
    context: context,
    message: AppStrings.productAddedToCart(product.name, quantityText),
    badgeText: AppStrings.cart,
    backgroundColor: shopColor,
    onBadgeTap: () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (onCartTap != null) {
        onCartTap();
        return;
      }

      if (shopModel != null) {
        Navigator.pushReplacementNamed(
          context,
          ProductsView.routeName,
          arguments: ProductsRouteArguments.fromShop(
            shopModel,
            initialNavigationIndex: ShopNavigationView.cartTabIndex,
          ),
        );
        return;
      }

      Navigator.pushNamed(
        context,
        CartView.routeName,
        arguments: CartViewArguments(
          product: product,
          quantity: quantity,
          primaryColor: shopColor,
          shopModel: shopModel,
        ),
      );
    },
  );
}
