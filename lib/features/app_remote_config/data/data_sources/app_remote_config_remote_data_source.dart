import 'package:makanak/core/services/supabase_remote_data_source.dart';
import 'package:makanak/features/app_remote_config/data/models/remote_app_config_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRemoteConfigRemoteDataSource extends SupabaseRemoteDataSource {
  const AppRemoteConfigRemoteDataSource(super.client);

  static const String _tableName = 'app_remote_config';

  Future<RemoteAppConfigModel?> fetchActiveConfig({
    required String platform,
  }) async {
    try {
      final data = await client
          .from(_tableName)
          .select(
            'platform, min_supported_version, latest_version, '
            'blocked_versions, maintenance_mode:customer_maintenance_mode, '
            'force_update_message, maintenance_message, update_url, is_active',
          )
          .eq('platform', platform)
          .eq('is_active', true)
          .order('updated_at', ascending: false)
          .limit(1);

      final rows = List<Map<String, dynamic>>.from(data);
      if (rows.isEmpty) return null;

      return RemoteAppConfigModel.fromJson(rows.first);
    } on PostgrestException catch (error) {
      throw databaseException(
        error,
        operation: 'fetchAppRemoteConfig',
        log: true,
      );
    } catch (error, stackTrace) {
      throw unexpectedDatabaseException(
        operation: 'fetchAppRemoteConfig',
        error: error,
        stackTrace: stackTrace,
        log: true,
      );
    }
  }
}
