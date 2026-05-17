class ManualNotificationException implements Exception {
  const ManualNotificationException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ManualNotificationException(statusCode: $statusCode, message: $message)';
}
