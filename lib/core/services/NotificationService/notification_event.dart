class NotificationEvent {
  const NotificationEvent({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.data,
    this.orderId,
    this.screen,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final String? orderId;
  final String? screen;
  final DateTime createdAt;
  final Map<String, dynamic> data;
}
