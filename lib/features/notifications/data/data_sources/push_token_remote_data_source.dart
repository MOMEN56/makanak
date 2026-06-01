import 'package:makanak/core/services/supabase_remote_data_source.dart';

class PushTokenRemoteDataSource extends SupabaseRemoteDataSource {
  const PushTokenRemoteDataSource(super.client);

  static const String _appType = 'customer';

  Future<void> upsertUserPushToken({
    required String token,
    required String platform,
  }) async {
    await guardedRequest(
      () => client.rpc(
        'upsert_user_push_token',
        params: {
          'p_token': token.trim(),
          'p_platform': platform.trim(),
          'p_app_type': _appType,
        },
      ),
      operation: 'upsertUserPushToken',
      log: true,
    );
  }

  Future<void> deleteUserPushToken({required String token}) async {
    await guardedRequest(
      () => client.rpc(
        'delete_user_push_token',
        params: {
          'p_token': token.trim(),
          'p_app_type': _appType,
        },
      ),
      operation: 'deleteUserPushToken',
      log: true,
    );
  }
}
