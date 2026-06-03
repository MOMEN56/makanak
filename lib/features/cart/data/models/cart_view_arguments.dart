import 'package:flutter/material.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class CartViewArguments {
  factory CartViewArguments({
    required ProductModel? product,
    required int quantity,
    required Color primaryColor,
    ShopModel? shopModel,
    int? shippingPrice,
  }) {
    final resolvedShippingPrice = _resolveShippingPrice(
      shippingPrice: shippingPrice,
      shopModel: shopModel,
    );

    return CartViewArguments._(
      productData: product == null ? null : ProductRouteData.fromModel(product),
      quantity: quantity,
      primaryColor: primaryColor,
      shopData: shopModel == null ? null : ShopRouteData.fromModel(shopModel),
      shippingPrice: resolvedShippingPrice,
    );
  }

  const CartViewArguments._({
    required ProductRouteData? productData,
    required this.quantity,
    required this.primaryColor,
    ShopRouteData? shopData,
    this.shippingPrice = 0,
  }) : _productData = productData,
       _shopData = shopData;

  static const defaultPrimaryColor = AppColors.primaryColor;

  final ProductRouteData? _productData;
  final int quantity;
  final Color primaryColor;
  final ShopRouteData? _shopData;
  final int shippingPrice;

  ProductModel? get product => _productData?.toModel();
  ShopModel? get shopModel => _shopData?.toModel();

  String? get shopId {
    final routeShopId = _shopData?.shopId.trim() ?? '';
    if (routeShopId.isNotEmpty) {
      return routeShopId;
    }

    final productShopId = _productData?.shopId.trim() ?? '';
    if (productShopId.isNotEmpty) {
      return productShopId;
    }

    return null;
  }

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

  static int _resolveShippingPrice({
    required int? shippingPrice,
    required ShopModel? shopModel,
  }) {
    final resolvedPrice = shippingPrice ?? shopModel?.shippingPrice ?? 0;
    return resolvedPrice < 0 ? 0 : resolvedPrice;
  }
}