import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/presentation/widgets/product_details_view_body.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class ProductDetailsView extends StatelessWidget {
  const ProductDetailsView({
    super.key,
    required this.product,
    required this.primaryColor,
  });

  final ProductModel product;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ProductDetailsViewBody(
        product: product,
        primaryColor: primaryColor,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: CustomButton(
          hint: '\u0627\u0636\u0641 \u0644\u0644\u0633\u0644\u0629',
          onTap: () {},
          hasShadowEffect: true,
          color: primaryColor,
        ),
      ),
    );
  }
}
