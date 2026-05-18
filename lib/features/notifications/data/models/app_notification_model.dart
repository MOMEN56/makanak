import 'package:makanak/core/services/notification_service/notification_event.dart';

class AppNotificationModel {
  AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required String type,
    required DateTime createdAt,
    required Map<String, dynamic> data,
    DateTime? readAt,
  }) : type = type.trim().toLowerCase(),
       createdAt = createdAt.toLocal(),
       readAt = readAt?.toLocal(),
       data = Map.unmodifiable(_normalizeData(data));

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: _readText(json['id']) ?? '',
      title: _readText(json['title']) ?? '',
      body: _readText(json['body']) ?? '',
      type: _readText(json['type']) ?? 'general',
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      readAt: _parseDateTime(json['read_at']),
      data: _readData(json['data']),
    );
  }

  factory AppNotificationModel.fromEvent(NotificationEvent event) {
    final eventData = Map<String, dynamic>.from(event.data);
    eventData.putIfAbsent('notification_id', () => event.id);
    eventData.putIfAbsent('title', () => event.title);
    eventData.putIfAbsent('body', () => event.body);
    eventData.putIfAbsent('type', () => event.type);
    if (event.orderId != null && event.orderId!.trim().isNotEmpty) {
      eventData.putIfAbsent('order_id', () => event.orderId);
    }
    if (event.screen != null && event.screen!.trim().isNotEmpty) {
      eventData.putIfAbsent('screen', () => event.screen);
    }
    eventData.putIfAbsent(
      'created_at',
      () => event.createdAt.toIso8601String(),
    );

    return AppNotificationModel(
      id: event.id,
      title: event.title,
      body: event.body,
      type: event.type,
      createdAt: event.createdAt,
      data: eventData,
    );
  }

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final DateTime? readAt;

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? createdAt,
    Map<String, dynamic>? data,
    DateTime? readAt,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
    );
  }

  bool get isRead => readAt != null;

  bool get isManualNotification =>
      type == 'manual_notification' || type == 'manual-notification';

  bool get isOrderStatusNotification =>
      type == 'order_status' || (orderId?.trim().isNotEmpty ?? false);

  String? get orderId => _readText(data['order_id']);

  String? get screen => _readText(data['screen'])?.toLowerCase();

  bool get isOrderStatus => isOrderStatusNotification;

  bool get isOffer =>
      type == 'offer' || screen?.trim().toLowerCase() == 'offers';

  String get formattedTime {
    final hour =
        createdAt.hour == 0
            ? 12
            : (createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour);
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = createdAt.hour < 12 ? 'ص' : 'م';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year} - '
        '$hour:$minute $period';
  }

  static Map<String, dynamic> _normalizeData(Map<String, dynamic> data) {
    return Map<String, dynamic>.from(data);
  }

  static Map<String, dynamic> _readData(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const {};
  }

  static DateTime? _parseDateTime(Object? value) {
    final rawValue = _readText(value);
    if (rawValue == null) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }

  static String? _readText(Object? value) {
    final normalizedValue = value?.toString().trim();
    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }
}
