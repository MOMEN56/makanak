import 'package:makanak/core/utils/app_keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseClientService {
  const SupabaseClientService._();

  static Future<void> initialize() {
    return Supabase.initialize(
      url: AppKeys.supabaseUrl,
      anonKey: AppKeys.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
