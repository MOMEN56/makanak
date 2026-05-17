import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class OrderDeliveryStatusStepsRow extends StatelessWidget {
  const OrderDeliveryStatusStepsRow({
    super.key,
    required this.steps,
    required this.currentStepIndex,
    required this.isCancelled,
  });

  final List<OrderDeliveryStepData> steps;
  final int currentStepIndex;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        steps.length,
        (index) => OrderDeliveryStatusStepItem(
          step: steps[index],
          index: index,
          stepsCount: steps.length,
          currentStepIndex: currentStepIndex,
          isCancelled: isCancelled,
        ),
      ),
    );
  }
}

class OrderDeliveryStatusStepItem extends StatelessWidget {
  const OrderDeliveryStatusStepItem({
    super.key,
    required this.step,
    required this.index,
    required this.stepsCount,
    required this.currentStepIndex,
    required this.isCancelled,
  });

  final OrderDeliveryStepData step;
  final int index;
  final int stepsCount;
  final int currentStepIndex;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    final isCompleted = !isCancelled && currentStepIndex > index;
    final isCurrent = !isCancelled && currentStepIndex == index;
    final circleSize = AppResponsive.width(context, 42);
    final connectorInset = circleSize / 2 + AppResponsive.width(context, 6);
    final connectorColor = AppColors.searchFieldBackground;
    final leadingConnectorColor =
        !isCancelled && index < currentStepIndex
            ? AppColors.primaryColor
            : connectorColor;
    final trailingConnectorColor =
        !isCancelled && index > 0 && index - 1 < currentStepIndex
            ? AppColors.primaryColor
            : connectorColor;
    final visualStyle = OrderDeliveryStepVisualStyle.resolve(
      isCompleted: isCompleted,
      isCurrent: isCurrent,
    );

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.spacing(context, 4),
        ),
        child: Column(
          children: [
            SizedBox(
              height: circleSize,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (index < stepsCount - 1)
                    Positioned(
                      left: 0,
                      right: connectorInset,
                      top: (circleSize / 2) - 1,
                      child: Container(height: 2, color: leadingConnectorColor),
                    ),
                  if (index > 0)
                    Positioned(
                      left: connectorInset,
                      right: 0,
                      top: (circleSize / 2) - 1,
                      child: Container(
                        height: 2,
                        color: trailingConnectorColor,
                      ),
                    ),
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: visualStyle.backgroundColor,
                      shape: BoxShape.circle,
                      border:
                          isCurrent
                              ? Border.all(color: AppColors.white, width: 2)
                              : null,
                      boxShadow: visualStyle.boxShadow,
                    ),
                    child: Icon(
                      step.icon,
                      size: AppResponsive.width(context, 20),
                      color: visualStyle.iconColor,
                    ),
                  ),
                ],
              ),
            ),
            Gap(AppResponsive.spacing(context, 10)),
            Text(
              step.status,
              textAlign: TextAlign.center,
              style: TextStyles.medium12.copyWith(
                fontSize: AppResponsive.text(context, 11),
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color:
                    isCurrent || isCompleted
                        ? AppColors.primaryDarkColor
                        : AppColors.shopCategoryColor.withValues(alpha: 0.72),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDeliveryStepData {
  const OrderDeliveryStepData({required this.status, required this.icon});

  final String status;
  final IconData icon;
}

class OrderDeliveryStepVisualStyle {
  const OrderDeliveryStepVisualStyle({
    required this.backgroundColor,
    required this.iconColor,
    this.boxShadow = const [],
  });

  final Color backgroundColor;
  final Color iconColor;
  final List<BoxShadow> boxShadow;

  factory OrderDeliveryStepVisualStyle.resolve({
    required bool isCompleted,
    required bool isCurrent,
  }) {
    if (isCurrent) {
      return OrderDeliveryStepVisualStyle(
        backgroundColor: AppColors.primaryDarkColor,
        iconColor: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      );
    }

    if (isCompleted) {
      return const OrderDeliveryStepVisualStyle(
        backgroundColor: AppColors.primaryColor,
        iconColor: AppColors.white,
      );
    }

    return const OrderDeliveryStepVisualStyle(
      backgroundColor: AppColors.searchFieldBackground,
      iconColor: AppColors.lightGrey,
    );
  }
}
