import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushTokenManager {
  static const int _maxTokenSyncRetries = 3;
  static const Duration _tokenRetryDelay = Duration(seconds: 2);

  PushTokenManager(
    this._databaseService,
    this._client, {
    FirebaseMessaging Function()? messagingFactory,
    required void Function(
      String message, {
      Object? error,
      StackTrace? stackTrace,
    })
    log,
  }) : _messagingFactory = messagingFactory ?? _defaultMessagingFactory,
       _log = log;

  final SupabaseDatabaseService _databaseService;
  final SupabaseClient _client;
  final FirebaseMessaging Function() _messagingFactory;
  final void Function(String message, {Object? error, StackTrace? stackTrace})
  _log;

  bool _isInitialized = false;
  String? _lastSyncedToken;
  FirebaseMessaging? _firebaseMessaging;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _messaging;
    _isInitialized = true;
  }

  Future<void> syncCurrentDeviceToken({int retryCount = 0}) async {
    if (!_canManageTokens || _client.auth.currentSession == null) {
      return;
    }

    final permission = await _messaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.denied) {
      _log('Push notification permission was denied.');
      return;
    }

    final token = (await _messaging.getToken())?.trim();
    if (token == null || token.isEmpty) {
      if (retryCount >= _maxTokenSyncRetries) {
        _log('FCM token is not available after retries.');
        return;
      }

      await Future<void>.delayed(_tokenRetryDelay);
      return syncCurrentDeviceToken(retryCount: retryCount + 1);
    }

    if (_lastSyncedToken == token) {
      return;
    }

    await _databaseService.upsertUserPushToken(
      token: token,
      platform: _pushPlatform,
    );
    _lastSyncedToken = token;
  }

  Future<void> handleTokenRefresh(String token) async {
    if (!_canManageTokens || _client.auth.currentSession == null) {
      return;
    }

    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      return;
    }

    final previousToken = _lastSyncedToken;
    if (previousToken == normalizedToken) {
      return;
    }

    if (previousToken != null && previousToken != normalizedToken) {
      await _databaseService.deleteUserPushToken(token: previousToken);
    }

    await _databaseService.upsertUserPushToken(
      token: normalizedToken,
      platform: _pushPlatform,
    );
    _lastSyncedToken = normalizedToken;
  }

  Future<void> detachCurrentDevice() async {
    if (!_canManageTokens) {
      return;
    }

    final token = (_lastSyncedToken ?? await _messaging.getToken())?.trim();
    if (token == null || token.isEmpty) {
      return;
    }

    await _databaseService.deleteUserPushToken(token: token);
    _lastSyncedToken = null;
  }

  void clearCachedToken() {
    _lastSyncedToken = null;
  }

  bool get _canManageTokens => _isInitialized;

  FirebaseMessaging get _messaging =>
      _firebaseMessaging ??= _messagingFactory();

  String get _pushPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'web';
    }
  }
}

FirebaseMessaging _defaultMessagingFactory() => FirebaseMessaging.instance;
