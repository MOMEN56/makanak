import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/notifications/data/models/app_notification_model.dart';
import 'package:makanak/features/notifications/data/repos/notifications_repository.dart';
import 'package:makanak/features/notifications/presentation/notifications_strings.dart';
import 'package:makanak/features/notifications/presentation/views/notifications_history_view.dart';
import 'package:makanak/features/notifications/presentation/widgets/notification_list_item.dart';
import 'package:makanak/shared/widgets/confirming_card_widget.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';

class LatestNotificationCard extends StatelessWidget {
  const LatestNotificationCard({super.key, required this.repository});

  final NotificationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: StreamBuilder<List<AppNotificationModel>>(
        stream: repository.watchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const ConfirmingCard(
              child: SizedBox(height: 72, child: CustomLoadingIndicator()),
            );
          }

          if (snapshot.hasError && !snapshot.hasData) {
            return const ConfirmingCard(
              child: _EmptyLatestNotificationState(
                message: NotificationsStrings.loadError,
              ),
            );
          }

          final notifications = snapshot.data ?? const <AppNotificationModel>[];
          final latestNotification =
              notifications.isEmpty ? null : notifications.first;

          return ConfirmingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        NotificationsStrings.latestNotification,
                        style: TextStyles.bold16.copyWith(
                          color: AppColors.primaryDarkColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          () => Navigator.pushNamed(
                            context,
                            NotificationsHistoryView.routeName,
                          ),
                      child: Text(
                        NotificationsStrings.viewNotifications,
                        style: TextStyles.semiBold14.copyWith(
                          color: AppColors.primaryDarkColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                if (latestNotification == null)
                  _EmptyLatestNotificationState()
                else
                  NotificationListItem(
                    notification: latestNotification,
                    wrapWithSurface: false,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyLatestNotificationState extends StatelessWidget {
  const _EmptyLatestNotificationState({
    this.message = NotificationsStrings.noNotificationsYet,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppResponsive.symmetric(context, vertical: 8),
      child: Row(
        children: [
          Container(
            width: AppResponsive.width(context, 40),
            height: AppResponsive.width(context, 40),
            decoration: BoxDecoration(
              color: AppColors.shopCategoryIconBackground,
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, 12),
              ),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primaryDarkColor,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              message,
              style: TextStyles.regular14.copyWith(
                color: AppColors.shopCategoryColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
