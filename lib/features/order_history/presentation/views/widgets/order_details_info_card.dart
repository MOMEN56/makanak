import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/core/utils/order_status_presenter.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';
import 'package:makanak/shared/widgets/confirming_card_widget.dart';

class OrderDetailsInfoCard extends StatelessWidget {
  const OrderDetailsInfoCard({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return ConfirmingCard(
      child: Column(
        children: [
          _OrderDetailsInfoRow(
            label: AppStrings.orderDate,
            value: _formatOrderDate(context, order.createdAt),
          ),
          const Gap(12),
          _OrderDetailsInfoRow(
            label: AppStrings.orderStatus,
            value: OrderStatusPresenter.label(order.status),
          ),
          const Gap(12),
          _OrderDetailsInfoRow(
            label: AppStrings.orderItemsLabel,
            value: AppStrings.orderItemsCount(order.totalItemsCount),
          ),
        ],
      ),
    );
  }

  String _formatOrderDate(BuildContext context, DateTime? value) {
    if (value == null) return AppStrings.orderDateUnavailable;

    final materialLocalizations = MaterialLocalizations.of(context);
    final timeOfDay = TimeOfDay.fromDateTime(value);

    return '${materialLocalizations.formatMediumDate(value)} - '
        '${_formatOrderTime(materialLocalizations, timeOfDay)}';
  }

  String _formatOrderTime(
    MaterialLocalizations materialLocalizations,
    TimeOfDay timeOfDay,
  ) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = _formatTwoDigits(materialLocalizations, timeOfDay.minute);
    final periodLabel =
        timeOfDay.period == DayPeriod.am
            ? materialLocalizations.anteMeridiemAbbreviation
            : materialLocalizations.postMeridiemAbbreviation;
    final suffix = periodLabel.isEmpty ? '' : ' $periodLabel';

    return '${materialLocalizations.formatDecimal(hour)}:$minute$suffix';
  }

  String _formatTwoDigits(
    MaterialLocalizations materialLocalizations,
    int value,
  ) {
    final formattedValue = materialLocalizations.formatDecimal(value);
    if (value >= 10) return formattedValue;

    return '${materialLocalizations.formatDecimal(0)}$formattedValue';
  }
}

class _OrderDetailsInfoRow extends StatelessWidget {
  const _OrderDetailsInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyles.semiBold14.copyWith(
              color: AppColors.shopCategoryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyles.semiBold14.copyWith(
              color: AppColors.primaryDarkColor,
            ),
          ),
        ),
      ],
    );
  }
}
