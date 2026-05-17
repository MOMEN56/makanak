import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class EmptyOrderHistoryState extends StatelessWidget {
  const EmptyOrderHistoryState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.searchFieldBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primaryDarkColor,
              size: 30,
            ),
          ),
          const Gap(16),
          Text(
            AppStrings.orderHistoryEmpty,
            textAlign: TextAlign.center,
            style: TextStyles.bold20.copyWith(
              color: AppColors.shopCategoryColor,
            ),
          ),
        ],
      ),
    );
  }
}
