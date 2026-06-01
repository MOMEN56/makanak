import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class ShopClosedNoticeBanner extends StatelessWidget {
  const ShopClosedNoticeBanner({
    super.key,
    required this.workingHours,
  });

  final String workingHours;

  @override
  Widget build(BuildContext context) {
    final normalizedWorkingHours = workingHours.trim();
    final detailsText =
        normalizedWorkingHours.isEmpty
            ? AppStrings.shopWorkingHoursUnavailable
            : normalizedWorkingHours;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.searchFieldBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.searchFieldGrey.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store_mall_directory_outlined,
              color: AppColors.searchFieldGrey,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.shopClosedNow,
                  style: TextStyles.bold16.copyWith(
                    color: AppColors.shopNameColor,
                  ),
                ),
                const Gap(4),
                Text(
                  AppStrings.shopWorkingHoursLabel,
                  style: TextStyles.semiBold14.copyWith(
                    color: AppColors.shopNameColor,
                  ),
                ),
                const Gap(2),
                Text(
                  detailsText,
                  style: TextStyles.regular14.copyWith(
                    color: AppColors.shopCategoryColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
