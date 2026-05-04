import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/presentation/views/widgets/product_details_view_body.dart';
import 'package:makanak/features/shop/presentation/views/widgets/show_product_added_snack_bar.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({
    super.key,
    required this.product,
    required this.primaryColor,
    this.shopModel,
    this.initialQuantity = 1,
  });

  final ProductModel product;
  final Color primaryColor;
  final ShopModel? shopModel;
  final int initialQuantity;

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _showAddedSnackBar() {
    showProductAddedSnackBar(
      context: context,
      product: widget.product,
      shopColor: widget.primaryColor,
      shopModel: widget.shopModel,
      quantity: _quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ProductDetailsViewBody(
        product: widget.product,
        primaryColor: widget.primaryColor,
        initialQuantity: widget.initialQuantity,
        onQuantityChanged: (quantity) => _quantity = quantity,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: CustomButton(
          hint: '\u0627\u0636\u0641 \u0644\u0644\u0633\u0644\u0629',
          onTap: _showAddedSnackBar,
          hasShadowEffect: true,
          color: widget.primaryColor,
        ),
      ),
    );
  }
}
