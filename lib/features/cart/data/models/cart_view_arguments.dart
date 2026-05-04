import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class CartViewArguments {
  const CartViewArguments({
    required this.product,
    required this.quantity,
    required this.primaryColor,
    this.shopModel,
    this.shippingPrice = 35,
  });

  static const defaultPrimaryColor = AppColors.primaryColor;

  final ProductModel? product;
  final int quantity;
  final Color primaryColor;
  final ShopModel? shopModel;
  final int shippingPrice;

  CartViewArguments copyWith({
    ProductModel? product,
    int? quantity,
    Color? primaryColor,
    ShopModel? shopModel,
    int? shippingPrice,
  }) {
    return CartViewArguments(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      primaryColor: primaryColor ?? this.primaryColor,
      shopModel: shopModel ?? this.shopModel,
      shippingPrice: shippingPrice ?? this.shippingPrice,
    );
  }
}
