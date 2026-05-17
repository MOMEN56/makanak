import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/core/utils/order_status_presenter.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_delivery_status_cancelled_section.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_delivery_status_steps_row.dart';
import 'package:makanak/shared/widgets/confirming_card_widget.dart';

class OrderDeliveryStatusStepper extends StatelessWidget {
  const OrderDeliveryStatusStepper({
    super.key,
    required this.currentStatus,
    this.cancellationReason,
  });

  static const String _cancellationReasonTitle = 'سبب الإلغاء';
  static const String _unknownCancellationReason = 'لم يتم توضيح سبب الإلغاء';
  static const Color _cancelledColor = Color(0xffD85B5B);
  static const Color _cancelledBackgroundColor = Color(0xffFFF0F0);

  static const List<OrderDeliveryStepData> _deliverySteps = [
    OrderDeliveryStepData(
      status: OrderStatusPresenter.pendingKey,
      icon: Icons.hourglass_empty_rounded,
    ),
    OrderDeliveryStepData(
      status: OrderStatusPresenter.preparingKey,
      icon: Icons.inventory_2_outlined,
    ),
    OrderDeliveryStepData(
      status: OrderStatusPresenter.outForDeliveryKey,
      icon: Icons.delivery_dining_rounded,
    ),
    OrderDeliveryStepData(
      status: OrderStatusPresenter.deliveredKey,
      icon: Icons.check_circle_rounded,
    ),
  ];

  final String currentStatus;
  final String? cancellationReason;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = normalizeStatus(currentStatus);
    final isCancelled = normalizedStatus == OrderStatusPresenter.rejectedKey;
    final currentStepIndex = _resolveCurrentStepIndex(normalizedStatus);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ConfirmingCard(
        primaryColor: isCancelled ? _cancelledColor : AppColors.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCancelled
                      ? Icons.cancel_rounded
                      : Icons.local_shipping_rounded,
                  size: AppResponsive.width(context, 22),
                  color:
                      isCancelled
                          ? _cancelledColor
                          : AppColors.primaryDarkColor,
                ),
                Gap(AppResponsive.spacing(context, 8)),
                Expanded(
                  child: Text(
                    AppStrings.trackOrder,
                    style: TextStyles.bold16.copyWith(
                      color:
                          isCancelled
                              ? _cancelledColor
                              : AppColors.primaryDarkColor,
                      fontSize: AppResponsive.text(context, 16),
                    ),
                  ),
                ),
              ],
            ),
            Gap(AppResponsive.spacing(context, 18)),
            OrderDeliveryStatusStepsRow(
              steps: _deliverySteps,
              currentStepIndex: currentStepIndex,
              isCancelled: isCancelled,
            ),
            if (isCancelled) ...[
              Gap(AppResponsive.spacing(context, 18)),
              OrderDeliveryStatusCancelledSection(
                title: _cancellationReasonTitle,
                body: _resolvedCancellationReason(),
                color: _cancelledColor,
                backgroundColor: _cancelledBackgroundColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String normalizeStatus(String status) {
    final normalized = status.trim();

    switch (normalized) {
      case 'pending':
      case 'قيد المراجعة':
      case 'تحت المراجعة':
        return OrderStatusPresenter.pendingKey;
      case 'accepted':
      case 'تم القبول ويتم التحضير':
      case 'يتم تحضيره':
        return OrderStatusPresenter.preparingKey;
      case 'out_for_delivery':
      case 'خرج للتوصيل':
        return OrderStatusPresenter.outForDeliveryKey;
      case 'delivered':
      case 'تم التوصيل':
      case 'تم توصيله':
        return OrderStatusPresenter.deliveredKey;
      case 'rejected':
      case 'تم رفض':
      case 'تم الرفض':
      case 'ملغي':
        return OrderStatusPresenter.rejectedKey;
      default:
        return normalized;
    }
  }

  int _resolveCurrentStepIndex(String normalizedStatus) {
    return _deliverySteps.indexWhere((step) => step.status == normalizedStatus);
  }

  String _resolvedCancellationReason() {
    final reason = cancellationReason?.trim() ?? '';
    return reason.isEmpty ? _unknownCancellationReason : reason;
  }
}
