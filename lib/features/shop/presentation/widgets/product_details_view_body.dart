import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/presentation/widgets/product_details_image.dart';
import 'package:makanak/shared/widgets/quantity_selector.dart';

class ProductDetailsViewBody extends StatelessWidget {
  const ProductDetailsViewBody({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          ProductDetailsImage(imageUrl: product.imageUrl),
          const Gap(24),
          Text(
            product.name,
            style: TextStyles.Bold24.copyWith(
              color: AppColors.primaryDarkColor,
            ),
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.price,
                  style: TextStyles.bold16.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const QuantitySelector(),
            ],
          ),
          const Gap(20),
          Text(
            product.desc,
            style: TextStyles.regular14.copyWith(
              color: AppColors.shopCategoryColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
