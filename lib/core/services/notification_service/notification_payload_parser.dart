import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:makanak/core/services/notification_service/notification_event.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/order_status_presenter.dart';

class NotificationPayloadParser {
  const NotificationPayloadParser({
    required void Function(
      String message, {
      Object? error,
      StackTrace? stackTrace,
    })
    log,
  }) : _log = log;

  final void Function(String message, {Object? error, StackTrace? stackTrace})
  _log;

  Map<String, dynamic> decodePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (error, stackTrace) {
      _log(
        'Push notification payload decoding failed.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return const {};
  }

  String? readText(Map<String, dynamic> data, String key) {
    final value = data[key]?.toString().trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  NotificationContent? resolveNotificationContent(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    final title =
        readText(data, 'title') ??
        notification?.title ??
        (isOrderStatusNavigationPayload(data)
            ? AppStrings.orderStatusUpdateTitle
            : null);
    final body =
        readText(data, 'body') ??
        notification?.body ??
        fallbackBodyFromStatus(data);

    if (title == null || title.trim().isEmpty) {
      return null;
    }

    if (body == null || body.trim().isEmpty) {
      return null;
    }

    return NotificationContent(title: title.trim(), body: body.trim());
  }

  NotificationEvent? resolveEventFromRemoteMessage(RemoteMessage message) {
    final content = resolveNotificationContent(message);
    if (content == null) {
      return null;
    }

    return resolveEventFromData(
      message.data,
      fallbackId: message.messageId,
      fallbackTitle: content.title,
      fallbackBody: content.body,
      fallbackCreatedAt: message.sentTime?.toLocal() ?? DateTime.now(),
    );
  }

  NotificationEvent? resolveEventFromData(
    Map<String, dynamic> data, {
    String? fallbackId,
    String? fallbackTitle,
    String? fallbackBody,
    DateTime? fallbackCreatedAt,
  }) {
    final title =
        readText(data, 'title') ??
        fallbackTitle ??
        (isOrderStatusNavigationPayload(data)
            ? AppStrings.orderStatusUpdateTitle
            : null);
    final body =
        readText(data, 'body') ?? fallbackBody ?? fallbackBodyFromStatus(data);

    if (title == null || title.trim().isEmpty) {
      return null;
    }

    if (body == null || body.trim().isEmpty) {
      return null;
    }

    final createdAt = _readCreatedAt(data, fallbackCreatedAt);
    final orderId = readText(data, 'order_id');
    final screen = readText(data, 'screen')?.toLowerCase();

    return NotificationEvent(
      id: _resolveEventId(
        data,
        createdAt: createdAt,
        fallbackId: fallbackId,
        fallbackTitle: title,
        fallbackBody: body,
      ),
      title: title.trim(),
      body: body.trim(),
      type: _resolveType(data, orderId: orderId, screen: screen),
      orderId: orderId,
      screen: screen,
      createdAt: createdAt,
      data: Map<String, dynamic>.from(data),
    );
  }

  Map<String, dynamic> encodeNotificationPayload(NotificationEvent event) {
    return {
      ...event.data,
      'notification_id': event.id,
      'title': event.title,
      'body': event.body,
      'type': event.type,
      if (event.orderId != null && event.orderId!.trim().isNotEmpty)
        'order_id': event.orderId,
      if (event.screen != null && event.screen!.trim().isNotEmpty)
        'screen': event.screen,
      'created_at': event.createdAt.toIso8601String(),
    };
  }

  String? fallbackBodyFromStatus(Map<String, dynamic> data) {
    final status = readText(data, 'status');
    if (status == null || status.trim().isEmpty) {
      return null;
    }

    return OrderStatusPresenter.notificationBody(status);
  }

  bool isOrderStatusNavigationPayload(Map<String, dynamic> data) {
    final type = (readText(data, 'type') ?? '').toLowerCase();
    if (type == 'order_status') {
      return true;
    }

    return readText(data, 'order_id') != null;
  }

  DateTime _readCreatedAt(
    Map<String, dynamic> data,
    DateTime? fallbackCreatedAt,
  ) {
    final rawCreatedAt =
        readText(data, 'created_at') ??
        readText(data, 'notification_created_at');
    final parsedCreatedAt =
        rawCreatedAt == null
            ? null
            : DateTime.tryParse(rawCreatedAt)?.toLocal();

    return parsedCreatedAt ?? fallbackCreatedAt ?? DateTime.now();
  }

  String _resolveType(
    Map<String, dynamic> data, {
    required String? orderId,
    required String? screen,
  }) {
    final rawType = readText(data, 'type')?.toLowerCase();
    if (rawType != null && rawType.isNotEmpty) {
      return rawType;
    }

    if (orderId != null && orderId.isNotEmpty) {
      return 'order_status';
    }

    if (screen == 'offers') {
      return 'offer';
    }

    return 'general';
  }

  String _resolveEventId(
    Map<String, dynamic> data, {
    required DateTime createdAt,
    String? fallbackId,
    String? fallbackTitle,
    String? fallbackBody,
  }) {
    final payloadId = readText(data, 'notification_id') ?? readText(data, 'id');
    if (payloadId != null && payloadId.isNotEmpty) {
      return payloadId;
    }

    final normalizedFallbackId = fallbackId?.trim();
    if (normalizedFallbackId != null && normalizedFallbackId.isNotEmpty) {
      return normalizedFallbackId;
    }

    return <String>[
      readText(data, 'type') ?? '',
      readText(data, 'order_id') ?? '',
      readText(data, 'screen') ?? '',
      fallbackTitle ?? readText(data, 'title') ?? '',
      fallbackBody ?? readText(data, 'body') ?? '',
      createdAt.toIso8601String(),
    ].join('|');
  }
}

class NotificationContent {
  const NotificationContent({required this.title, required this.body});

  final String title;
  final String body;
}
