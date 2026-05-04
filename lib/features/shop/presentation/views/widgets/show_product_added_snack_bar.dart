import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/cart_view.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';

void showProductAddedSnackBar({
  required BuildContext context,
  required ProductModel product,
  required Color shopColor,
  ShopModel? shopModel,
  int quantity = 1,
}) {
  final quantityText = quantity > 1 ? ' $quantity' : '';

  AppSnackBar.show(
    context: context,
    message: AppStrings.productAddedToCart(product.name, quantityText),
    badgeText: AppStrings.cart,
    backgroundColor: shopColor,
    onBadgeTap: () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
