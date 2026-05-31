import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/shared/widgets/confirming_card_widget.dart';
import 'package:makanak/features/order_history/data/models/order_item_model.dart';
import 'package:makanak/shared/widgets/network_image_with_placeholder.dart';

class OrderDetailsProductCard extends StatelessWidget {
  const OrderDetailsProductCard({super.key, required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    return ConfirmingCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetworkImageWithPlaceholder(
            imageUrl: item.product.imageUrl,
            height: 92,
            width: 92,
            cacheWidth: 220,
            placeholderColor: AppColors.searchFieldBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name.isEmpty
                      ? AppStrings.product
                      : item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.bold16.copyWith(
                    color: AppColors.shopNameColor,
                  ),
                ),
                const Gap(12),
                _ProductLineRow(
                  label: AppStrings.orderUnitPrice,
                  value: AppStrings.priceInEgyptianPounds(item.unitPrice),
                ),
                const Gap(8),
                _ProductLineRow(
                  label: AppStrings.orderQuantityLabel,
                  value: item.quantity.toString(),
                ),
                const Gap(8),
                _ProductLineRow(
                  label: AppStrings.orderProductTotal,
                  value: AppStrings.priceInEgyptianPounds(item.totalPrice),
                  highlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductLineRow extends StatelessWidget {
  const _ProductLineRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.medium12.copyWith(
              color: AppColors.shopCategoryColor,
            ),
          ),
        ),
        const Gap(12),
        Flexible(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: (highlight ? TextStyles.bold16 : TextStyles.semiBold14)
                .copyWith(
                  color:
                      highlight
                          ? AppColors.primaryColor
                          : AppColors.primaryDarkColor,
                ),
          ),
        ),
      ],
    );
  }
}
