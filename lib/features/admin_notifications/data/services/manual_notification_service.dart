import 'package:flutter/foundation.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/admin_notifications/data/services/manual_notification_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef ManualNotificationHeadersBuilder = Map<String, String> Function();

class ManualNotificationService {
  static const String _manualNotificationType = 'manual_notification';
  static const String _notificationsHistoryScreen = 'notifications_history';
  static const String _generalNotificationsChannel = 'general_notifications';

  ManualNotificationService(
    this._client, {
    ManualNotificationHeadersBuilder? headersBuilder,
  }) : _headersBuilder = headersBuilder;

  static const String _functionName = 'send-manual-notification';

  final SupabaseClient _client;
  final ManualNotificationHeadersBuilder? _headersBuilder;

  Future<void> sendToAllUsers({
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) {
    return _send(title: title, body: body, data: data);
  }

  Future<void> sendToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw const ManualNotificationException(
        AppStrings.adminNotificationUserIdRequired,
      );
    }

    return _send(
      userId: normalizedUserId,
      title: title,
      body: body,
      data: data,
    );
  }

  Future<void> _send({
    String? userId,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    _ensureAuthenticated();

    final normalizedTitle = title.trim();
    final normalizedBody = body.trim();

    if (normalizedTitle.isEmpty) {
      throw const ManualNotificationException(
        AppStrings.adminNotificationTitleRequired,
      );
    }

    if (normalizedBody.isEmpty) {
      throw const ManualNotificationException(
        AppStrings.adminNotificationBodyRequired,
      );
    }

    try {
      await _client.functions.invoke(
        _functionName,
        headers: _buildHeaders(),
        body: {
          if (userId != null) 'userId': userId,
          'title': normalizedTitle,
          'body': normalizedBody,
          'data': _buildNotificationData(data),
        },
      );
    } on FunctionException catch (error, stackTrace) {
      _logFailure(error, stackTrace);
      throw ManualNotificationException(
        _mapFunctionError(error),
        statusCode: error.status,
      );
    } catch (error, stackTrace) {
      _logUnexpectedFailure(error, stackTrace);
      throw const ManualNotificationException(
        AppStrings.adminNotificationSendError,
      );
    }
  }

  void _ensureAuthenticated() {
    final accessToken = _client.auth.currentSession?.accessToken.trim();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ManualNotificationException(
        AppStrings.adminNotificationAuthRequired,
      );
    }
  }

  Map<String, String>? _buildHeaders() {
    final headers = _headersBuilder?.call();
    if (headers == null || headers.isEmpty) {
      return null;
    }

    return Map<String, String>.from(headers);
  }

  Map<String, dynamic> _buildNotificationData(Map<String, dynamic> data) {
    return {
      'type': _manualNotificationType,
      'screen': _notificationsHistoryScreen,
      'channel_id': _generalNotificationsChannel,
      ...Map<String, dynamic>.from(data),
    };
  }

  String _mapFunctionError(FunctionException error) {
    if (error.status == 400) {
      return AppStrings.adminNotificationInvalidPayload;
    }

    if (error.status == 401 || error.status == 403) {
      return AppStrings.adminNotificationPermissionError;
    }

    if (error.status >= 500) {
      return AppStrings.adminNotificationServerError;
    }

    return AppStrings.adminNotificationSendError;
  }

  void _logFailure(FunctionException error, StackTrace stackTrace) {
    if (!kDebugMode) return;

    debugPrint(
      'Manual notification function failed: '
      'status=${error.status}, reason=${error.reasonPhrase}, details=${error.details}',
    );
    debugPrint('$stackTrace');
  }

  void _logUnexpectedFailure(Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;

    debugPrint('Manual notification request failed unexpectedly: $error');
    debugPrint('$stackTrace');
  }
}
