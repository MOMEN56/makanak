import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:makanak/core/utils/app_navigator_key.dart';
import 'package:makanak/core/utils/app_route_tracker.dart';
import 'package:makanak/features/notifications/presentation/views/notifications_history_view.dart';

class NotificationNavigationService {
  NotificationNavigationService._();

  static const String _manualNotificationType = 'manual_notification';
  static const String _legacyManualNotificationType = 'manual-notification';
  static const String _manualCustomerNotificationType =
      'manual_customer_notification';

  static const String _customerAppType = 'customer';
  static const String _notificationsHistoryScreen = 'notifications_history';

  static String? _lastHandledNavigationKey;
  static String? _pendingNavigationKey;
  static Map<String, dynamic>? _pendingNavigationData;
  static bool _isNavigationReady = false;

  static Future<void> handleRemoteMessage(RemoteMessage message) async {
    final data = Map<String, dynamic>.from(message.data);
    final navigationKey = _buildNavigationKey(
      data,
      fallbackId: message.messageId,
    );

    _queueOrNavigate(data, navigationKey);
  }

  static void navigateFromData(Map<String, dynamic> data) {
    final normalizedData = Map<String, dynamic>.from(data);
    final navigationKey = _buildNavigationKey(normalizedData);

    _queueOrNavigate(normalizedData, navigationKey);
  }

  static void markNavigationReady() {
    _isNavigationReady = true;
    _flushPendingNavigation();
  }

  static void resetNavigationReadiness({bool clearPendingNavigation = false}) {
    _isNavigationReady = false;

    if (clearPendingNavigation) {
      _pendingNavigationKey = null;
      _pendingNavigationData = null;
    }
  }

  static bool isManualNotificationData(Map<String, dynamic> data) {
    final rawType = data['type']?.toString().trim().toLowerCase();
    final appType = data['app_type']?.toString().trim().toLowerCase();
    final screen = data['screen']?.toString().trim().toLowerCase();

    if (rawType == _manualNotificationType ||
        rawType == _legacyManualNotificationType ||
        rawType == _manualCustomerNotificationType) {
      return true;
    }

    return appType == _customerAppType && screen == _notificationsHistoryScreen;
  }

  static void _queueOrNavigate(
    Map<String, dynamic> data,
    String navigationKey,
  ) {
    if (!isManualNotificationData(data)) {
      return;
    }

    if (_lastHandledNavigationKey == navigationKey ||
        _pendingNavigationKey == navigationKey) {
      return;
    }

    final navigator = appNavigatorKey.currentState;
    if (!_isNavigationReady || navigator == null) {
      _pendingNavigationKey = navigationKey;
      _pendingNavigationData = data;
      return;
    }

    _scheduleNavigation(navigationKey);
  }

  static void _flushPendingNavigation() {
    final pendingData = _pendingNavigationData;
    final pendingKey = _pendingNavigationKey;

    if (pendingData == null || pendingKey == null) {
      return;
    }

    _pendingNavigationKey = null;
    _pendingNavigationData = null;

    if (!isManualNotificationData(pendingData)) {
      return;
    }

    if (_lastHandledNavigationKey == pendingKey) {
      return;
    }

    final navigator = appNavigatorKey.currentState;
    if (!_isNavigationReady || navigator == null) {
      _pendingNavigationKey = pendingKey;
      _pendingNavigationData = pendingData;
      return;
    }

    _scheduleNavigation(pendingKey);
  }

  static void _scheduleNavigation(String navigationKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navigator = appNavigatorKey.currentState;
        if (!_isNavigationReady || navigator == null) {
          return;
        }

        if (_lastHandledNavigationKey == navigationKey) {
          return;
        }

        if (AppRouteTracker.currentRouteName ==
            NotificationsHistoryView.routeName) {
          _completeHandledNavigation(navigationKey);
          return;
        }

        _completeHandledNavigation(navigationKey);
        navigator.pushNamed(NotificationsHistoryView.routeName);
      });
    });
  }

  static void _completeHandledNavigation(String navigationKey) {
    _lastHandledNavigationKey = navigationKey;
    _pendingNavigationKey = null;
    _pendingNavigationData = null;
  }

  static String _buildNavigationKey(
    Map<String, dynamic> data, {
    String? fallbackId,
  }) {
    final payloadId =
        data['notification_id']?.toString().trim() ??
        data['id']?.toString().trim();
    if (payloadId != null && payloadId.isNotEmpty) {
      return payloadId;
    }

    final messageId = fallbackId?.trim();
    if (messageId != null && messageId.isNotEmpty) {
      return messageId;
    }

    return <String>[
      data['type']?.toString().trim() ?? '',
      data['screen']?.toString().trim() ?? '',
      data['channel_id']?.toString().trim() ?? '',
      data['title']?.toString().trim() ?? '',
      data['body']?.toString().trim() ?? '',
      data['created_at']?.toString().trim() ?? '',
    ].join('|');
  }
}
