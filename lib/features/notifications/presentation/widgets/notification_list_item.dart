import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/core/services/services.dart';
import 'package:makanak/features/notifications/data/models/app_notification_model.dart';
import 'package:makanak/features/notifications/presentation/notifications_strings.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
    this.wrapWithSurface = true,
    this.onTap,
    this.onOrderActionTap,
  });

  final AppNotificationModel notification;
  final bool wrapWithSurface;
  final VoidCallback? onTap;
  final VoidCallback? onOrderActionTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppResponsive.radius(context, 14));
    final primaryTap =
        onTap ?? (_canOpenPrimaryDestination ? _handlePrimaryTap : null);
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: primaryTap,
        borderRadius: radius,
        child: Padding(
          padding: AppResponsive.all(context, 10),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: _buildContent(context),
          ),
        ),
      ),
    );

    if (!wrapWithSurface) {
      return child;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkColor.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!notification.isOrderStatusNotification) {
      return _NotificationTextContent(notification: notification);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _NotificationTextContent(notification: notification)),
        const Gap(8),
        TextButton(
          onPressed: onOrderActionTap ?? onTap ?? _openOrderDestination,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          child: Text(
            NotificationsStrings.viewOrder,
            style: TextStyles.medium12.copyWith(
              color: AppColors.primaryDarkColor,
            ),
          ),
        ),
      ],
    );
  }

  bool get _canOpenPrimaryDestination {
    if (notification.isOrderStatusNotification) {
      return true;
    }

    if (_isOffersDestination) {
      // TODO(makanak): route offer notifications to the offers screen once
      // that screen exists in the app.
      return false;
    }

    return false;
  }

  bool get _isOffersDestination =>
      notification.screen?.trim().toLowerCase() == 'offers';

  void _handlePrimaryTap() {
    if (notification.isOrderStatusNotification) {
      _openOrderDestination();
    }
  }

  void _openOrderDestination() {
    getIt<PushNotificationService>().openNotificationDestination(
      notification.data,
      resetStack: false,
    );
  }
}

class _NotificationTextContent extends StatelessWidget {
  const _NotificationTextContent({required this.notification});

  final AppNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationTypeIcon(notification: notification),
            const Gap(8),
            Expanded(
              child: Text(
                notification.title,
                style: TextStyles.semiBold14.copyWith(
                  color: AppColors.primaryDarkColor,
                ),
              ),
            ),
          ],
        ),
        const Gap(8),
        Text(
          notification.body,
          style: TextStyles.regular14.copyWith(
            fontSize: AppResponsive.text(context, 13),
            color: AppColors.shopCategoryColor,
            height: 1.4,
          ),
        ),
        const Gap(8),
        Text(
          notification.formattedTime,
          style: TextStyles.medium10.copyWith(
            color: AppColors.lightGrey,
            fontSize: AppResponsive.text(context, 10),
          ),
        ),
      ],
    );
  }
}

class _NotificationTypeIcon extends StatelessWidget {
  const _NotificationTypeIcon({required this.notification});

  final AppNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppResponsive.width(context, 32),
      height: AppResponsive.width(context, 32),
      decoration: BoxDecoration(
        color: AppColors.shopCategoryIconBackground,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, 10)),
      ),
      child: Icon(
        _resolveIcon(),
        color: AppColors.primaryDarkColor,
        size: AppResponsive.width(context, 16),
      ),
    );
  }

  IconData _resolveIcon() {
    if (notification.isOrderStatusNotification) {
      return Icons.local_shipping_outlined;
    }

    if (notification.isOffer) {
      return Icons.local_offer_outlined;
    }

    if (notification.type == 'general') {
      return Icons.notifications_none_rounded;
    }

    return Icons.campaign_outlined;
  }
}
