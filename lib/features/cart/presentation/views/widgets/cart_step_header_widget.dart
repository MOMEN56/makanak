import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class CartStepHeaderWidget extends StatelessWidget {
  const CartStepHeaderWidget({
    super.key,
    required this.title,
    required this.onBack,
    this.primaryColor = AppColors.primaryColor,
  });

  final String title;
  final VoidCallback onBack;
  final Color primaryColor;

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
            title,
            textAlign: TextAlign.center,
            style: TextStyles.bold24.copyWith(color: AppColors.shopNameColor),
          ),
        ),
        const SizedBox(width: 58),
      ],
    );
  }
}
