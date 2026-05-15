import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';

class OrderDetailsHeader extends StatelessWidget {
  const OrderDetailsHeader({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.maybePop(context),
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryDarkColor,
                size: 20,
              ),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.orderDetails,
                style: TextStyles.bold20.copyWith(
                  color: AppColors.primaryDarkColor,
                ),
              ),
              const Gap(2),
              Text(
                AppStrings.orderNumberLabel(order.id),
                style: TextStyles.medium12.copyWith(
                  color: AppColors.shopCategoryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
