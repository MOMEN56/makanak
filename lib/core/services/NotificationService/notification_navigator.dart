import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:makanak/core/services/NotificationService/notification_event.dart';
import 'package:makanak/core/services/NotificationService/notification_navigation_service.dart';
import 'package:makanak/core/services/NotificationService/notification_payload_parser.dart';
import 'package:makanak/features/order_history/data/data_sources/orders_remote_data_source.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';
import 'package:makanak/features/order_history/presentation/views/order_details_view.dart';
import 'package:makanak/features/order_history/presentation/views/order_history_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationNavigator {
  NotificationNavigator(
    this._ordersRemoteDataSource,
    this._client,
    this._payloadParser, {
    required GlobalKey<NavigatorState> navigatorKey,
    required void Function(
      String message, {
      Object? error,
      StackTrace? stackTrace,
    })
    log,
    void Function(NotificationEvent event)? onNotificationEvent,
  }) : _navigatorKey = navigatorKey,
       _log = log,
       _onNotificationEvent = onNotificationEvent;

  final OrdersRemoteDataSource _ordersRemoteDataSource;
  final SupabaseClient _client;
  final NotificationPayloadParser _payloadParser;
  final GlobalKey<NavigatorState> _navigatorKey;
  final void Function(String message, {Object? error, StackTrace? stackTrace})
  _log;
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

    final order = await _resolveOrderFromNotification(data);
    if (resetStack) {
      navigator.popUntil((route) => route.isFirst);
    }

    if (order != null) {
      navigator.pushNamed(OrderDetailsView.routeName, arguments: order);
      return;
    }

    navigator.pushNamed(OrderHistoryView.routeName);
  }

  Future<OrderModel?> _resolveOrderFromNotification(
    Map<String, dynamic> data,
  ) async {
    final orderId = _payloadParser.readText(data, 'order_id');
    if (orderId == null) {
      return null;
    }

    try {
      final orderData = await _ordersRemoteDataSource.fetchUserOrderById(
        orderId,
      );
      if (orderData == null) {
        return null;
      }

      return OrderModel.fromJson(orderData);
    } catch (error, stackTrace) {
      _log(
        'Failed to resolve notification order before navigation.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  void _emitNotificationEvent(NotificationEvent? event) {
    if (event == null) {
      return;
    }

    _onNotificationEvent?.call(event);
  }
}
