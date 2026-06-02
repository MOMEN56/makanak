import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failure_mapper.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/services/services.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/notifications/data/models/app_notification_model.dart';
import 'package:makanak/features/notifications/data/repos/notifications_repository.dart';
import 'package:makanak/features/notifications/presentation/notifications_strings.dart';
import 'package:makanak/features/notifications/presentation/widgets/notification_list_item.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';
import 'package:makanak/shared/views/no_internet_view.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class NotificationsHistoryViewBody extends StatefulWidget {
  const NotificationsHistoryViewBody({
    super.key,
    this.onFullScreenNetworkStateChanged,
  });

  final ValueChanged<bool>? onFullScreenNetworkStateChanged;

  @override
  State<NotificationsHistoryViewBody> createState() =>
      _NotificationsHistoryViewBodyState();
}

class _NotificationsHistoryViewBodyState
    extends State<NotificationsHistoryViewBody> {
  late final NotificationsRepository _repository;

  List<AppNotificationModel> _notifications = const [];
  bool _isLoading = true;
  bool _hasLoadedContentOnce = false;
  Failure? _failure;

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
        _failure = null;
      });
      widget.onFullScreenNetworkStateChanged?.call(false);
    }

    try {
      final notifications = await _repository.fetchNotifications();
      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = notifications;
        _isLoading = false;
        _hasLoadedContentOnce = true;
        _failure = null;
      });
      widget.onFullScreenNetworkStateChanged?.call(false);
    } catch (error) {
      if (!mounted) {
        return;
      }

      final failure = _mapFailure(error);

      if (_hasLoadedContentOnce) {
        setState(() {
          _isLoading = false;
        });
        widget.onFullScreenNetworkStateChanged?.call(false);
        _showRefreshError(failure);
        return;
      }

      setState(() {
        _isLoading = false;
        _failure = failure;
      });
      widget.onFullScreenNetworkStateChanged?.call(failure.isNetwork);
    }
  }

  Future<void> _handleNotificationTap(AppNotificationModel notification) async {
    try {
      if (!notification.isRead) {
        await _repository.markAsRead(notification.id);
        _markNotificationAsReadLocally(notification.id);
      }
    } catch (error) {
      if (mounted) {
        _showRefreshError(_mapFailure(error));
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

  Failure _mapFailure(Object error) {
    if (error is DatabaseException) {
      return FailureMapper.fromDatabaseException(
        error,
        genericMessage: NotificationsStrings.loadError,
      );
    }

    return const Failure(NotificationsStrings.loadError);
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

  void _showRefreshError(Failure failure) {
    if (failure.isNetwork) {
      AppSnackBar.showNetwork(context: context, message: failure.message);
      return;
    }

    AppSnackBar.show(
      context: context,
      message: failure.message,
      badgeText: AppStrings.retry,
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

    final failure = _failure;
    if (failure != null) {
      return failure.isNetwork
          ? NoInternetView(onRetry: () => unawaited(_loadNotifications()))
          : StateMessage(
            message: failure.message,
            onRetry: () => unawaited(_loadNotifications()),
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
