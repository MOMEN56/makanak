import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/presentation/views/widgets/product_details_view_body.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({
    super.key,
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

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ProductDetailsViewBody(
        product: widget.product,
        primaryColor: widget.primaryColor,
        shopModel: widget.shopModel,
        initialQuantity: widget.initialQuantity,
        onCartRequested: widget.onCartRequested,
        onProductAdded: widget.onProductAdded,
      ),
    );
  }
}
