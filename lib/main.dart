import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:makanak/core/services/notification_service/push_notification_service.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/services/supabase_client_service.dart';
import 'package:makanak/core/utils/bootstrap_error_logging.dart';
import 'package:makanak/features/notifications/data/repos/notifications_repository.dart';
import 'package:makanak/makanak_app.dart';

Future<void> main() async {
  configureErrorLogging(libraryName: 'makanak bootstrap');

  final binding = WidgetsFlutterBinding.ensureInitialized();
  binding.deferFirstFrame();
  await SupabaseClientService.initialize();
  setupServiceLocator();
  getIt<NotificationsRepository>();
  unawaited(getIt<PushNotificationService>().initialize());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MakanakApp());
}
