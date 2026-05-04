import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class CartHeaderWidget extends StatelessWidget {
  const CartHeaderWidget({
    super.key,
    this.primaryColor = AppColors.primaryColor,
    this.itemCount = 0,
    this.onBack,
  });

  final Color primaryColor;
  final int itemCount;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final darkerPrimaryColor = AppColors.darkerShade(primaryColor);

    return Row(
      children: [
        Material(
          color: primaryColor.withValues(alpha: 0.10),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBack,
            child: SizedBox(
              height: 44,
              width: 44,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: darkerPrimaryColor,
                size: 18,
              ),
            ),
          ),
        ),
        const Gap(14),
        Expanded(
          child: Text(
            AppStrings.cartTitle,
            style: TextStyles.bold16.copyWith(color: AppColors.shopNameColor),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$itemCount ${AppStrings.product}',
            style: TextStyles.semiBold14.copyWith(color: darkerPrimaryColor),
          ),
        ),
      ],
    );
  }
}
