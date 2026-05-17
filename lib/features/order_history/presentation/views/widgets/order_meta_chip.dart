import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/core/utils/order_status_presenter.dart';

class OrderMetaChip extends StatelessWidget {
  const OrderMetaChip({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.greyBackground,
    this.foregroundColor = AppColors.shopCategoryColor,
    this.maxTextWidth,
    this.compact = true,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final double? maxTextWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxTextWidth ?? double.infinity),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (compact ? TextStyles.medium8 : TextStyles.medium12).copyWith(
            color: foregroundColor,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
    this.maxTextWidth,
  });

  final String status;
  final bool compact;
  final double? maxTextWidth;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = OrderStatusPresenter.normalize(status);
    final style = _resolveStyle(normalizedStatus);

    return OrderMetaChip(
      label: OrderStatusPresenter.label(status),
      backgroundColor: style.backgroundColor,
      foregroundColor: style.textColor,
      maxTextWidth: maxTextWidth,
      compact: compact,
    );
  }

  _OrderStatusStyle _resolveStyle(String normalizedStatus) {
    switch (normalizedStatus) {
      case OrderStatusPresenter.deliveredKey:
        return const _OrderStatusStyle(
          backgroundColor: Color(0xffEAF8EF),
          textColor: Color(0xff2F8F4E),
        );
      case OrderStatusPresenter.preparingKey:
        return const _OrderStatusStyle(
          backgroundColor: Color(0xffEEF4FF),
          textColor: Color(0xff2D5BBA),
        );
      case OrderStatusPresenter.outForDeliveryKey:
        return const _OrderStatusStyle(
          backgroundColor: Color(0xffFFF5E5),
          textColor: Color(0xffC77A12),
        );
      case OrderStatusPresenter.rejectedKey:
        return const _OrderStatusStyle(
          backgroundColor: Color(0xffFFF0F0),
          textColor: Color(0xffD85B5B),
        );
      case OrderStatusPresenter.pendingKey:
      default:
        return const _OrderStatusStyle(
          backgroundColor: AppColors.searchFieldBackground,
          textColor: AppColors.primaryDarkColor,
        );
    }
  }
}

class _OrderStatusStyle {
  const _OrderStatusStyle({
    required this.backgroundColor,
    required this.textColor,
  });

  final Color backgroundColor;
  final Color textColor;
}
