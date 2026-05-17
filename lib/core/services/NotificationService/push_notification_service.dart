import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:makanak/core/services/NotificationService/notification_event.dart';
import 'package:makanak/core/services/NotificationService/notification_navigation_service.dart';
import 'package:makanak/core/services/NotificationService/notification_navigator.dart';
import 'package:makanak/core/services/NotificationService/notification_payload_parser.dart';
import 'package:makanak/core/services/NotificationService/push_token_manager.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:makanak/core/utils/app_navigator_key.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _orderUpdatesChannel = AndroidNotificationChannel(
  'order_updates',
  'Order Updates',
  description: 'Notifications about order status changes.',
  importance: Importance.max,
);

const _orderNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'order_updates',
    'Order Updates',
    channelDescription: 'Notifications about order status changes.',
    importance: Importance.max,
    priority: Priority.high,
  ),
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!_supportsRemotePushNotifications) {
    return;
  }

  await Firebase.initializeApp();
}

bool get _supportsRemotePushNotifications =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

class PushNotificationService {
  factory PushNotificationService(
    SupabaseDatabaseService databaseService,
    SupabaseClient client, {
    FirebaseMessaging? firebaseMessaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    NotificationPayloadParser? payloadParser,
    PushTokenManager? pushTokenManager,
    NotificationNavigator? notificationNavigator,
  }) {
    final messagingFactory = _buildMessagingFactory(firebaseMessaging);
    final notificationEventsController =
        StreamController<NotificationEvent>.broadcast();
    final parser = payloadParser ?? NotificationPayloadParser(log: _debugLog);
    final tokenManager =
        pushTokenManager ??
        PushTokenManager(
          databaseService,
          client,
          messagingFactory: messagingFactory,
          log: _debugLog,
        );
    final navigator =
        notificationNavigator ??
        NotificationNavigator(
          databaseService,
          client,
          parser,
          navigatorKey: appNavigatorKey,
          log: _debugLog,
          onNotificationEvent: (event) {
            if (notificationEventsController.isClosed) {
              return;
            }

            notificationEventsController.add(event);
          },
        );

    return PushNotificationService._(
      client: client,
      firebaseMessagingFactory: messagingFactory,
      notificationEventsController: notificationEventsController,
      localNotifications:
          localNotifications ?? FlutterLocalNotificationsPlugin(),
      payloadParser: parser,
      pushTokenManager: tokenManager,
      notificationNavigator: navigator,
    );
  }

  PushNotificationService._({
    required SupabaseClient client,
    required FirebaseMessaging Function() firebaseMessagingFactory,
    required StreamController<NotificationEvent> notificationEventsController,
    required FlutterLocalNotificationsPlugin localNotifications,
    required NotificationPayloadParser payloadParser,
    required PushTokenManager pushTokenManager,
    required NotificationNavigator notificationNavigator,
  }) : _client = client,
       _firebaseMessagingFactory = firebaseMessagingFactory,
       _notificationEventsController = notificationEventsController,
       _localNotifications = localNotifications,
       _payloadParser = payloadParser,
       _pushTokenManager = pushTokenManager,
       _notificationNavigator = notificationNavigator;

  final SupabaseClient _client;
  final FirebaseMessaging Function() _firebaseMessagingFactory;
  final StreamController<NotificationEvent> _notificationEventsController;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final NotificationPayloadParser _payloadParser;
  final PushTokenManager _pushTokenManager;
  final NotificationNavigator _notificationNavigator;

  StreamSubscription<AuthState>? _authStateSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;
  FirebaseMessaging? _firebaseMessaging;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized || !_supportsRemotePushNotifications) {
      return;
    }

    _isInitialized = true;
    try {
      await Firebase.initializeApp();
      _messaging;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _pushTokenManager.initialize();
      await _initializeLocalNotifications();

      _authStateSubscription = _client.auth.onAuthStateChange.listen((event) {
        unawaited(_syncAfterAuthStateChange(event));
      });

      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
        unawaited(_syncAfterTokenRefresh(token));
      });

      _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((
        message,
      ) {
        unawaited(_showForegroundNotification(message));
      });

      _messageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp
          .listen((message) {
            unawaited(
              NotificationNavigationService.handleRemoteMessage(message),
            );
            _emitNotificationEvent(
              _payloadParser.resolveEventFromRemoteMessage(message),
            );
            unawaited(
              _notificationNavigator.queueNotificationNavigation(message.data),
            );
          });

      await _notificationNavigator.handleAppLaunchFromNotification(
        firebaseMessaging: _messaging,
        localNotifications: _localNotifications,
      );
      await _pushTokenManager.syncCurrentDeviceToken();
    } catch (error, stackTrace) {
      _debugLog(
        'Push notification initialization failed.',
        error: error,
        stackTrace: stackTrace,
      );
      _isInitialized = false;
    }
  }

  Future<void> dispose() async {
    await _authStateSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    await _messageOpenedAppSubscription?.cancel();
    await _notificationEventsController.close();
  }

  Future<void> markNavigationReady() {
    return _markNavigationReady();
  }

  void resetNavigationReadiness() {
    _notificationNavigator.resetNavigationReadiness();
    NotificationNavigationService.resetNavigationReadiness();
  }

  Future<void> detachCurrentDevice() {
    return _pushTokenManager.detachCurrentDevice();
  }

  Stream<NotificationEvent> get notificationEvents =>
      _notificationEventsController.stream;

  Future<void> openNotificationDestination(
    Map<String, dynamic> data, {
    bool resetStack = true,
  }) {
    return _notificationNavigator.navigateToNotificationDestination(
      data,
      resetStack: resetStack,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse:
          _notificationNavigator.handleNotificationResponse,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_orderUpdatesChannel);
  }

  Future<void> _syncAfterAuthStateChange(AuthState authState) async {
    try {
      await _handleAuthStateChange(authState);
    } catch (error, stackTrace) {
      _debugLog(
        'Push state sync failed after auth change.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _handleAuthStateChange(AuthState authState) async {
    switch (authState.event) {
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
      case AuthChangeEvent.mfaChallengeVerified:
        await _pushTokenManager.syncCurrentDeviceToken();
        await _notificationNavigator.consumePendingNotificationNavigation();
        return;
      case AuthChangeEvent.signedOut:
        _notificationNavigator.resetNavigationReadiness(
          clearPendingNavigation: true,
        );
        _pushTokenManager.clearCachedToken();
        return;
      default:
        return;
    }
  }

  Future<void> _syncAfterTokenRefresh(String token) async {
    try {
      await _pushTokenManager.handleTokenRefresh(token);
    } catch (error, stackTrace) {
      _debugLog(
        'Push token refresh sync failed.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final event = _payloadParser.resolveEventFromRemoteMessage(message);
    if (event == null) {
      return;
    }

    _emitNotificationEvent(event);
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      event.title,
      event.body,
      _orderNotificationDetails,
      payload: jsonEncode(_payloadParser.encodeNotificationPayload(event)),
    );
  }

  FirebaseMessaging get _messaging =>
      _firebaseMessaging ??= _firebaseMessagingFactory();

  void _emitNotificationEvent(NotificationEvent? event) {
    if (event == null || _notificationEventsController.isClosed) {
      return;
    }

    _notificationEventsController.add(event);
  }

  Future<void> _markNavigationReady() async {
    await _notificationNavigator.markNavigationReady();
    NotificationNavigationService.markNavigationReady();
  }
}

FirebaseMessaging Function() _buildMessagingFactory(
  FirebaseMessaging? firebaseMessaging,
) {
  if (firebaseMessaging != null) {
    return () => firebaseMessaging;
  }

  return () => FirebaseMessaging.instance;
}

void _debugLog(String message, {Object? error, StackTrace? stackTrace}) {
  if (!kDebugMode) {
    return;
  }

  debugPrint(message);
  if (error != null) {
    debugPrint('Push notification error: $error');
  }
  if (stackTrace != null) {
    debugPrint('$stackTrace');
  }
}
