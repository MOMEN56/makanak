import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/services/supabase_request_guard.dart';
import 'package:makanak/core/services/notification_service/notification_event.dart';
import 'package:makanak/core/services/services.dart';
import 'package:makanak/features/notifications/data/models/app_notification_model.dart';
import 'package:makanak/features/notifications/data/repos/notifications_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseNotificationsRepository implements NotificationsRepository {
  SupabaseNotificationsRepository(this._client, this._pushNotificationService)
    : _currentUserId = _readCurrentUserId(_client) {
    _pushSubscription = _pushNotificationService.notificationEvents.listen((_) {
      unawaited(_refreshAfterPushEvent());
    });

    _authStateSubscription = _client.auth.onAuthStateChange.listen((authState) {
      unawaited(_handleAuthStateChange(authState));
    });
  }

  static const int _defaultLimit = 50;

  final SupabaseClient _client;
  final PushNotificationService _pushNotificationService;
  final StreamController<List<AppNotificationModel>> _controller =
      StreamController<List<AppNotificationModel>>.broadcast();
  late final StreamSubscription<NotificationEvent> _pushSubscription;
  late final StreamSubscription<AuthState> _authStateSubscription;

  List<AppNotificationModel> _notifications = const [];
  Future<List<AppNotificationModel>>? _inFlightFetch;
  int _lastFetchLimit = _defaultLimit;
  String? _currentUserId;

  @override
  Future<AppNotificationModel?> fetchLatestNotification() async {
    final notifications = await fetchNotifications(limit: _defaultLimit);
    if (notifications.isEmpty) {
      return null;
    }

    return notifications.first;
  }

  @override
  Future<List<AppNotificationModel>> fetchNotifications({
    int limit = _defaultLimit,
  }) {
    final normalizedLimit = limit < 1 ? _defaultLimit : limit;
    _lastFetchLimit = normalizedLimit;

    final inFlightFetch = _inFlightFetch;
    if (inFlightFetch != null) {
      return inFlightFetch;
    }

    final future = _fetchNotificationsFromRemote(limit: normalizedLimit);
    _inFlightFetch = future;

    return future.whenComplete(() {
      if (identical(_inFlightFetch, future)) {
        _inFlightFetch = null;
      }
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final normalizedId = notificationId.trim();
    if (normalizedId.isEmpty || !_hasAuthenticatedUser) {
      return;
    }

    final alreadyRead = _notifications.any(
      (notification) => notification.id == normalizedId && notification.isRead,
    );
    if (alreadyRead) {
      return;
    }

    final readAt = DateTime.now().toUtc();

    await _guardedRequest(
      () => _client
          .from('notifications')
          .update({'read_at': readAt.toIso8601String()})
          .eq('id', normalizedId),
    );

    _notifications = _notifications
        .map((notification) {
          if (notification.id != normalizedId) {
            return notification;
          }

          return notification.copyWith(readAt: readAt);
        })
        .toList(growable: false);
    _emitNotifications();
  }

  @override
  Future<void> markAllAsRead() async {
    if (!_hasAuthenticatedUser) {
      return;
    }

    final readAt = DateTime.now().toUtc();

    await _guardedRequest(
      () => _client
          .from('notifications')
          .update({'read_at': readAt.toIso8601String()})
          .isFilter('read_at', null),
    );

    if (_notifications.isEmpty) {
      return;
    }

    _notifications = _notifications
        .map(
          (notification) =>
              notification.isRead
                  ? notification
                  : notification.copyWith(readAt: readAt),
        )
        .toList(growable: false);
    _emitNotifications();
  }

  @override
  Stream<List<AppNotificationModel>> watchNotifications() async* {
    if (_notifications.isNotEmpty) {
      yield List<AppNotificationModel>.unmodifiable(_notifications);
    } else {
      yield await fetchNotifications(limit: _lastFetchLimit);
    }

    yield* _controller.stream;
  }

  @override
  Future<void> dispose() async {
    await _pushSubscription.cancel();
    await _authStateSubscription.cancel();
    await _controller.close();
  }

  Future<List<AppNotificationModel>> _fetchNotificationsFromRemote({
    required int limit,
  }) async {
    if (!_hasAuthenticatedUser) {
      _notifications = const [];
      _emitNotifications();
      return const [];
    }

    final response = await _guardedRequest(
      () => _client
          .from('notifications')
          .select('id, title, body, type, data, read_at, created_at')
          .order('created_at', ascending: false)
          .limit(limit),
    );

    final notifications = List<Map<String, dynamic>>.from(
      response,
    ).map(AppNotificationModel.fromJson).toList(growable: false);

    _notifications = notifications;
    _emitNotifications();
    return List<AppNotificationModel>.unmodifiable(_notifications);
  }

  Future<T> _guardedRequest<T>(Future<T> Function() request) async {
    try {
      return await SupabaseRequestGuard.run(request);
    } on PostgrestException catch (error) {
      throw DatabaseException(error.message, code: error.code);
    } on DatabaseException {
      rethrow;
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }

  Future<void> _handleAuthStateChange(AuthState authState) async {
    final nextUserId = authState.session?.user.id.trim();
    final didUserChange = nextUserId != _currentUserId;
    _currentUserId = nextUserId;

    if (authState.event == AuthChangeEvent.signedOut || didUserChange) {
      _notifications = const [];
      _emitNotifications();
    }

    if (!didUserChange || !_controller.hasListener) {
      return;
    }

    if (nextUserId == null || nextUserId.isEmpty) {
      return;
    }

    try {
      await fetchNotifications(limit: _lastFetchLimit);
    } catch (error, stackTrace) {
      _logBackgroundRefreshFailure(
        'Notifications refresh failed after auth change.',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _refreshAfterPushEvent() async {
    if (!_controller.hasListener || !_hasAuthenticatedUser) {
      return;
    }

    try {
      await fetchNotifications(limit: _lastFetchLimit);
    } catch (error, stackTrace) {
      _logBackgroundRefreshFailure(
        'Notifications refresh failed after push event.',
        error,
        stackTrace,
      );
    }
  }

  void _emitNotifications() {
    if (_controller.isClosed) {
      return;
    }

    _controller.add(List<AppNotificationModel>.unmodifiable(_notifications));
  }

  bool get _hasAuthenticatedUser {
    final userId = _readCurrentUserId(_client);
    return userId != null && userId.isNotEmpty;
  }

  static String? _readCurrentUserId(SupabaseClient client) {
    final userId = client.auth.currentSession?.user.id.trim();
    if (userId == null || userId.isEmpty) {
      return null;
    }

    return userId;
  }

  void _logBackgroundRefreshFailure(
    String message,
    Object error,
    StackTrace stackTrace,
  ) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(message);
    debugPrint('Notifications repository error: $error');
    debugPrint('$stackTrace');
  }
}
