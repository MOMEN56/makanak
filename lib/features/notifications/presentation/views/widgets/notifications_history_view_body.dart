import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/services/services.dart';
import 'package:makanak/features/notifications/data/models/app_notification_model.dart';
import 'package:makanak/features/notifications/data/repos/notifications_repository.dart';
import 'package:makanak/features/notifications/presentation/notifications_strings.dart';
import 'package:makanak/features/notifications/presentation/widgets/notification_list_item.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class NotificationsHistoryViewBody extends StatefulWidget {
  const NotificationsHistoryViewBody({super.key});

  @override
  State<NotificationsHistoryViewBody> createState() =>
      _NotificationsHistoryViewBodyState();
}

class _NotificationsHistoryViewBodyState
    extends State<NotificationsHistoryViewBody> {
  late final NotificationsRepository _repository;

  List<AppNotificationModel> _notifications = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = getIt<NotificationsRepository>();
    unawaited(_loadNotifications());
  }

  Future<void> _loadNotifications({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final notifications = await _repository.fetchNotifications();
      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = notifications;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      if (_notifications.isNotEmpty) {
        setState(() {
          _isLoading = false;
        });
        _showRefreshError();
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = NotificationsStrings.loadError;
      });
    }
  }

  Future<void> _handleNotificationTap(AppNotificationModel notification) async {
    try {
      if (!notification.isRead) {
        await _repository.markAsRead(notification.id);
        _markNotificationAsReadLocally(notification.id);
      }
    } catch (_) {
      if (mounted) {
        _showRefreshError();
      }
    }

    if (!mounted || !notification.isOrderStatusNotification) {
      return;
    }

    await getIt<PushNotificationService>().openNotificationDestination(
      notification.data,
      resetStack: false,
    );
  }

  void _markNotificationAsReadLocally(String notificationId) {
    final readAt = DateTime.now();
    setState(() {
      _notifications = _notifications
          .map(
            (notification) =>
                notification.id != notificationId
                    ? notification
                    : notification.copyWith(readAt: readAt),
          )
          .toList(growable: false);
    });
  }

  void _showRefreshError() {
    AppSnackBar.show(
      context: context,
      message: NotificationsStrings.loadError,
      badgeText: AppStrings.retry,
      backgroundColor: const Color(0xffD85B5B),
      onBadgeTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        unawaited(_loadNotifications(showLoading: false));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CustomLoadingIndicator();
    }

    if (_errorMessage != null) {
      return _RefreshableState(
        onRefresh: () => _loadNotifications(showLoading: false),
        child: StateMessage(
          message: _errorMessage!,
          onRetry: () => unawaited(_loadNotifications()),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return _RefreshableState(
        onRefresh: () => _loadNotifications(showLoading: false),
        child: const StateMessage(
          message: NotificationsStrings.noNotificationsYet,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(showLoading: false),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppResponsive.all(context, AppSpacing.screenEdge),
        itemCount: _notifications.length,
        separatorBuilder: (_, _) => const Gap(12),
        itemBuilder: (context, index) {
          final notification = _notifications[index];

          return NotificationListItem(
            notification: notification,
            onTap: () => unawaited(_handleNotificationTap(notification)),
            onOrderActionTap:
                () => unawaited(_handleNotificationTap(notification)),
          );
        },
      ),
    );
  }
}

class _RefreshableState extends StatelessWidget {
  const _RefreshableState({required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
      ),
    );
  }
}
