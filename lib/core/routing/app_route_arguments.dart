import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class ShopRouteData extends Equatable {
  const ShopRouteData({
    required this.shopId,
    required this.shopName,
    required this.shopCategory,
    this.ownerId,
    this.logoUrl,
    this.isActive = true,
    this.isVisible = true,
    this.isOpen = true,
    this.workingHours = '',
  });

  factory ShopRouteData.fromModel(ShopModel shop) {
    return ShopRouteData(
      shopId: shop.id?.trim() ?? '',
      shopName: shop.name.trim(),
      shopCategory: shop.category.trim(),
      ownerId: shop.ownerId?.trim(),
      logoUrl: shop.logoUrl?.trim(),
      isActive: shop.isActive,
      isVisible: shop.isVisible,
      isOpen: shop.isOpen,
      workingHours: shop.workingHours.trim(),
    );
  }

  final String shopId;
  final String shopName;
  final String shopCategory;
  final String? ownerId;
  final String? logoUrl;
  final bool isActive;
  final bool isVisible;
  final bool isOpen;
  final String workingHours;

  bool get hasValidDisplayData =>
      shopId.isNotEmpty && shopName.isNotEmpty && shopCategory.isNotEmpty;

  ShopModel toModel() {
    return ShopModel(
      id: shopId,
      ownerId: ownerId,
      name: shopName,
      logoUrl: logoUrl,
      category: shopCategory,
      isActive: isActive,
      isVisible: isVisible,
      isOpen: isOpen,
      workingHours: workingHours,
    );
  }

  @override
  List<Object?> get props => [
    shopId,
    shopName,
    shopCategory,
    ownerId,
    logoUrl,
    isActive,
    isVisible,
    isOpen,
    workingHours,
  ];
}

class ProductRouteData extends Equatable {
  const ProductRouteData({
    required this.productId,
    required this.shopId,
    required this.name,
    required this.price,
    this.description = '',
    this.imageUrl = '',
    this.inStock = true,
    this.stockQuantity = 0,
    this.isVisible = true,
  });

  factory ProductRouteData.fromModel(ProductModel product) {
    return ProductRouteData(
      productId: product.id?.trim() ?? '',
      shopId: product.shopId.trim(),
      name: product.name.trim(),
      description: product.description?.trim() ?? '',
      imageUrl: product.imageUrl.trim(),
      price: product.price,
      inStock: product.inStock,
      stockQuantity: product.stockQuantity,
      isVisible: product.isVisible,
    );
  }

  final String productId;
  final String shopId;
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final bool inStock;
  final int stockQuantity;
  final bool isVisible;

  bool get hasValidDisplayData =>
      productId.isNotEmpty &&
      shopId.isNotEmpty &&
      name.isNotEmpty &&
      price >= 0;

  ProductModel toModel() {
    return ProductModel(
      id: productId,
      shopId: shopId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      price: price,
      inStock: inStock,
      stockQuantity: stockQuantity,
      isVisible: isVisible,
    );
  }

  @override
  List<Object?> get props => [
    productId,
    shopId,
    name,
    description,
    imageUrl,
    price,
    inStock,
    stockQuantity,
    isVisible,
  ];
}

class ProductsRouteArguments extends Equatable {
  const ProductsRouteArguments({
    required this.shop,
    this.initialNavigationIndex = 0,
  });

  factory ProductsRouteArguments.fromShop(
    ShopModel shop, {
    int initialNavigationIndex = 0,
  }) {
    return ProductsRouteArguments(
      shop: ShopRouteData.fromModel(shop),
      initialNavigationIndex: initialNavigationIndex,
    );
  }

  final ShopRouteData shop;
  final int initialNavigationIndex;

  bool get isValid => shop.hasValidDisplayData && initialNavigationIndex >= 0;

  @override
  List<Object?> get props => [shop, initialNavigationIndex];
}

enum ProductDetailsRouteResult { openCart }

class ProductDetailsRouteArguments extends Equatable {
  const ProductDetailsRouteArguments({
    required this.product,
    required this.primaryColor,
    this.shop,
    this.initialQuantity = 1,
    this.returnToCartTab = false,
  });

  factory ProductDetailsRouteArguments.fromModels({
    required ProductModel product,
    required Color primaryColor,
    ShopModel? shopModel,
    int initialQuantity = 1,
    bool returnToCartTab = false,
  }) {
    return ProductDetailsRouteArguments(
      product: ProductRouteData.fromModel(product),
      primaryColor: primaryColor,
      shop: shopModel == null ? null : ShopRouteData.fromModel(shopModel),
      initialQuantity: initialQuantity < 1 ? 1 : initialQuantity,
      returnToCartTab: returnToCartTab,
    );
  }

  final ProductRouteData product;
  final Color primaryColor;
  final ShopRouteData? shop;
  final int initialQuantity;
  final bool returnToCartTab;

  bool get isValid =>
      product.hasValidDisplayData &&
      (shop == null || shop!.hasValidDisplayData) &&
      initialQuantity >= 1;

  @override
  List<Object?> get props => [
    product,
    primaryColor,
    shop,
    initialQuantity,
    returnToCartTab,
  ];
}

class OrderDetailsRouteArguments extends Equatable {
  const OrderDetailsRouteArguments({required this.orderId});

  final String orderId;

  bool get isValid => orderId.trim().isNotEmpty;

  @override
  List<Object?> get props => [orderId];
}
