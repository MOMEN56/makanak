import 'package:makanak/features/notifications/data/models/app_notification_model.dart';

abstract class NotificationsRepository {
  Future<AppNotificationModel?> fetchLatestNotification();

  Future<List<AppNotificationModel>> fetchNotifications({int limit = 50});

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();

  Stream<List<AppNotificationModel>> watchNotifications();

  Future<void> dispose();
}
