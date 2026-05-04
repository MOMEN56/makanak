import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/shared/widgets/network_image_with_placeholder.dart';
import 'package:makanak/shared/widgets/quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.primaryColor,
    this.onRemove,
    this.onQuantityChanged,
  });

  final ProductModel product;
  final int quantity;
  final Color primaryColor;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkerShade(primaryColor).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                NetworkImageWithPlaceholder(
                  imageUrl: product.imageUrl,
                  height: 74,
                  width: 74,
                  cacheWidth: 160,
                  borderRadius: BorderRadius.circular(8),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              softWrap: true,
                              style: TextStyles.bold16.copyWith(
                                color: AppColors.shopNameColor,
                              ),
                            ),
                          ),
                          Material(
                            color: AppColors.searchFieldBackground,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: onRemove,
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                height: 28,
                                width: 28,
                                child: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.shopNameColor,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.priceText,
                                  style: TextStyles.semiBold14.copyWith(
                                    color: AppColors.darkerShade(primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(10),
                          QuantitySelector(
                            initialQuantity: quantity,
                            buttonSize: 24,
                            iconSize: 16,
                            valueWidth: 30,
                            color: primaryColor,
                            onChanged: onQuantityChanged,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(6),
        ],
      ),
    );
  }
}
