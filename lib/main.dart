import 'package:flutter/material.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/services/supabase_client_service.dart';
import 'package:makanak/makanak_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseClientService.initialize();
  setupServiceLocator();
  runApp(const MakanakApp());
}
