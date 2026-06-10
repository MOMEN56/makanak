import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/custom_button.dart';
import 'package:makanak/shared/widgets/network_image_with_placeholder.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({super.key, required this.shop, this.onShopTap});

  final ShopModel shop;
  final VoidCallback? onShopTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.greyBackground,
                      child: NetworkImageWithPlaceholder(
                        imageUrl: shop.imageUrl,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        cacheWidth: 700,
                        placeholderIcon: Icons.storefront_outlined,
                        placeholderColor: AppColors.greyBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    if (!shop.isOpen)
                      ColoredBox(
                        color: AppColors.searchFieldGrey.withValues(
                          alpha: 0.58,
                        ),
                        child: Center(
                          child: Text(
                            AppStrings.shopClosedLabel,
                            style: TextStyles.bold20.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const Gap(16),

            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.shopCategoryIconBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_restaurant_sharp,
                      size: 22.5,
                      color: AppColors.shopCategoryIconColor,
                    ),
                  ),
                ),

                const Gap(12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.bold16.copyWith(
                          color: AppColors.shopNameColor,
                        ),
                      ),
                      Text(
                        shop.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.medium12.copyWith(
                          color: AppColors.shopCategoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Gap(16),

            CustomButton(
              hint: AppStrings.shopCardAction,
              onTap: onShopTap,
              preventRapidTaps: true,
            ),
          ],
        ),
      ),
    );
  }
}
