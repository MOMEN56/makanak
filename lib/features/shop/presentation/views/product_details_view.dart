import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/presentation/views/widgets/product_details_view_body.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class ProductDetailsView extends StatelessWidget {
  const ProductDetailsView({
    super.key,
    required this.product,
    required this.primaryColor,
    this.shopModel,
    this.initialQuantity = 1,
    this.onCartRequested,
    this.onProductAdded,
  });

  static const String routeName = 'product_details';

  final ProductModel product;
  final Color primaryColor;
  final ShopModel? shopModel;
  final int initialQuantity;
  final VoidCallback? onCartRequested;
  final VoidCallback? onProductAdded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ProductDetailsViewBody(
        product: product,
        primaryColor: primaryColor,
        shopModel: shopModel,
        initialQuantity: initialQuantity,
        onCartRequested: onCartRequested,
        onProductAdded: onProductAdded,
      ),
    );
  }
}

class ProductDetailsViewArguments {
  const ProductDetailsViewArguments({
    required this.product,
    required this.primaryColor,
    this.shopModel,
    this.initialQuantity = 1,
    this.onCartRequested,
    this.onProductAdded,
  });

  final ProductModel product;
  final Color primaryColor;
  final ShopModel? shopModel;
  final int initialQuantity;
  final VoidCallback? onCartRequested;
  final VoidCallback? onProductAdded;
}
