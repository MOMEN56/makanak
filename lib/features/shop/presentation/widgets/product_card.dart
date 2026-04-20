import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/presentation/widgets/add_button.dart';
import 'package:makanak/shared/widgets/network_image_with_placeholder.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAdd,
  });

  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: NetworkImageWithPlaceholder(
                  imageUrl: product.imageUrl,
                  width: double.infinity,
                  cacheWidth: 400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.bold16.copyWith(
                      color: AppColors.shopNameColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.priceText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.semiBold14.copyWith(
                            color: AppColors.primaryDarkColor,
                          ),
                        ),
                      ),
                      AddButton(onTap: onAdd),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
