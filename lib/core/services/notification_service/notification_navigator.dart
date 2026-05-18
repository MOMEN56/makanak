import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/services/notification_service/notification_event.dart';
import 'package:makanak/core/services/notification_service/notification_navigation_service.dart';
import 'package:makanak/core/services/notification_service/notification_payload_parser.dart';
import 'package:makanak/features/order_history/presentation/views/order_details_view.dart';
import 'package:makanak/features/order_history/presentation/views/order_history_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationNavigator {
  NotificationNavigator(
    this._client,
    this._payloadParser, {
    required GlobalKey<NavigatorState> navigatorKey,
    void Function(NotificationEvent event)? onNotificationEvent,
  }) : _navigatorKey = navigatorKey,
       _onNotificationEvent = onNotificationEvent;

  final SupabaseClient _client;
  final NotificationPayloadParser _payloadParser;
  final GlobalKey<NavigatorState> _navigatorKey;
  final void Function(NotificationEvent event)? _onNotificationEvent;

  bool _isNavigationReady = false;
  Map<String, dynamic>? _pendingNotificationData;

  Future<void> handleAppLaunchFromNotification({
    required FirebaseMessaging firebaseMessaging,
    required FlutterLocalNotificationsPlugin localNotifications,
  }) async {
    final initialMessage = await firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      await NotificationNavigationService.handleRemoteMessage(initialMessage);
      _emitNotificationEvent(
        _payloadParser.resolveEventFromRemoteMessage(initialMessage),
      );
      await queueNotificationNavigation(initialMessage.data);
      return;
    }

    final launchDetails =
        await localNotifications.getNotificationAppLaunchDetails();
    final payload = launchDetails?.notificationResponse?.payload;
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payloadData = _payloadParser.decodePayload(payload);
      NotificationNavigationService.navigateFromData(payloadData);
      _emitNotificationEvent(_payloadParser.resolveEventFromData(payloadData));
      await queueNotificationNavigation(payloadData);
    }
  }

  Future<void> markNavigationReady() async {
    _isNavigationReady = true;
    await consumePendingNotificationNavigation();
  }

  void resetNavigationReadiness({bool clearPendingNavigation = false}) {
    _isNavigationReady = false;
    if (clearPendingNavigation) {
      _pendingNotificationData = null;
    }
  }

  Future<void> queueNotificationNavigation(Map<String, dynamic> data) async {
    if (!_payloadParser.isOrderStatusNavigationPayload(data)) {
      return;
    }

    if (_client.auth.currentSession == null || !_isNavigationReady) {
      _pendingNotificationData = Map<String, dynamic>.from(data);
      return;
    }

    _pendingNotificationData = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(navigateToNotificationDestination(data));
    });
  }

  Future<void> consumePendingNotificationNavigation() async {
    final pendingData = _pendingNotificationData;
    if (pendingData == null) {
      return;
    }

    _pendingNotificationData = null;
    await queueNotificationNavigation(pendingData);
  }

  void handleNotificationResponse(NotificationResponse response) {
    final payloadData = _payloadParser.decodePayload(response.payload);
    NotificationNavigationService.navigateFromData(payloadData);
    _emitNotificationEvent(_payloadParser.resolveEventFromData(payloadData));
    unawaited(queueNotificationNavigation(payloadData));
  }

  Future<void> navigateToNotificationDestination(
    Map<String, dynamic> data, {
    bool resetStack = true,
  }) async {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      _pendingNotificationData = Map<String, dynamic>.from(data);
      return;
    }

    final orderId = _payloadParser.readText(data, 'order_id')?.trim();
    if (resetStack) {
      navigator.popUntil((route) => route.isFirst);
    }

    if (orderId != null && orderId.isNotEmpty) {
      navigator.pushNamed(
        OrderDetailsView.routeName,
        arguments: OrderDetailsRouteArguments(orderId: orderId),
      );
      return;
    }

    navigator.pushNamed(OrderHistoryView.routeName);
  }

  void _emitNotificationEvent(NotificationEvent? event) {
    if (event == null) {
      return;
    }

    _onNotificationEvent?.call(event);
  }
}
