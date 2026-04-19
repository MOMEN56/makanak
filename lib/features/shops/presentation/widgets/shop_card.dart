import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    required this.shop,
    this.onShopTap,
  });

  final ShopModel shop;
  final VoidCallback? onShopTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  shop.imageUrl,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
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
                  child: Center(
                    child: Icon(
                      shop.categoryIcon,
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
            CustomButton(hint: 'تسوق', onTap: onShopTap),
          ],
        ),
      ),
    );
  }
}
