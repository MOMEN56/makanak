import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class ConfirmingOrderRow extends StatelessWidget {
  const ConfirmingOrderRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.primaryColor = AppColors.primaryColor,
  });

  final String label;
  final String value;
  final bool isTotal;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final style = isTotal ? TextStyles.bold16 : TextStyles.semiBold14;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: style.copyWith(
              color:
                  isTotal
                      ? AppColors.shopNameColor
                      : AppColors.shopCategoryColor,
            ),
          ),
        ),
        Text(
          value,
          style: style.copyWith(
            color:
                isTotal
                    ? AppColors.darkerShade(primaryColor)
                    : AppColors.lightGrey,
          ),
        ),
      ],
    );
  }
}
