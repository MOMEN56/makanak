import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/core/utils/order_status_presenter.dart';

class OrderDeliveryStatusCancelledSection extends StatelessWidget {
  const OrderDeliveryStatusCancelledSection({
    super.key,
    required this.title,
    required this.body,
    required this.color,
    required this.backgroundColor,
  });

  final String title;
  final String body;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CancelledStatusBanner(color: color, backgroundColor: backgroundColor),
        Gap(AppResponsive.spacing(context, 12)),
        _CancellationReasonCard(
          title: title,
          body: body,
          color: color,
          backgroundColor: backgroundColor,
        ),
      ],
    );
  }
}

class _CancelledStatusBanner extends StatelessWidget {
  const _CancelledStatusBanner({
    required this.color,
    required this.backgroundColor,
  });

  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.spacing(context, 12),
        vertical: AppResponsive.spacing(context, 10),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, 12)),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cancel_rounded,
            size: AppResponsive.width(context, 20),
            color: color,
          ),
          Gap(AppResponsive.spacing(context, 8)),
          Expanded(
            child: Text(
              OrderStatusPresenter.rejectedKey,
              style: TextStyles.bold16.copyWith(
                fontSize: AppResponsive.text(context, 15),
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancellationReasonCard extends StatelessWidget {
  const _CancellationReasonCard({
    required this.title,
    required this.body,
    required this.color,
    required this.backgroundColor,
  });

  final String title;
  final String body;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppResponsive.spacing(context, 14)),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, 14)),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.bold16.copyWith(
              fontSize: AppResponsive.text(context, 15),
              color: color,
            ),
          ),
          Gap(AppResponsive.spacing(context, 8)),
          Text(
            body,
            style: TextStyles.medium12.copyWith(
              fontSize: AppResponsive.text(context, 12),
              color: AppColors.shopCategoryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
