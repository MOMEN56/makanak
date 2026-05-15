import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/shared/widgets/confirming_card_widget.dart';
import 'package:makanak/features/cart/presentation/views/widgets/confirming_order_row_widget.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.itemsTotal,
    required this.shippingPrice,
    required this.orderTotal,
    this.primaryColor = AppColors.primaryColor,
  });

  final int itemsTotal;
  final int shippingPrice;
  final int orderTotal;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return ConfirmingCard(
      primaryColor: primaryColor,
      child: Column(
        children: [
          ConfirmingOrderRow(
            label: AppStrings.productsTotal,
            value: '$itemsTotal ${AppStrings.currency}',
          ),
          const Gap(12),
          ConfirmingOrderRow(
            label: AppStrings.deliveryPrice,
            value: '$shippingPrice ${AppStrings.currency}',
          ),
          const Gap(12),
          const Divider(height: 1, color: AppColors.searchFieldBackground),
          const Gap(12),
          ConfirmingOrderRow(
            label: AppStrings.orderTotal,
            value: '$orderTotal ${AppStrings.currency}',
            isTotal: true,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }
}
