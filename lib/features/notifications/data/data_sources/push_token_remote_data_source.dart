import 'package:makanak/core/services/supabase_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushTokenRemoteDataSource extends SupabaseRemoteDataSource {
  const PushTokenRemoteDataSource(super.client);

  Future<void> upsertUserPushToken({
    required String token,
    required String platform,
  }) async {
    try {
      await client.rpc(
        'upsert_user_push_token',
        params: {'p_token': token.trim(), 'p_platform': platform.trim()},
      );
    } on PostgrestException catch (error) {
      throw databaseException(
        error,
        operation: 'upsertUserPushToken',
        log: true,
      );
    } catch (_) {
      throw unexpectedDatabaseException();
    }
  }

  Future<void> deleteUserPushToken({required String token}) async {
    try {
      await client.rpc(
        'delete_user_push_token',
        params: {'p_token': token.trim()},
      );
    } on PostgrestException catch (error) {
      throw databaseException(
        error,
        operation: 'deleteUserPushToken',
        log: true,
      );
    } catch (_) {
      throw unexpectedDatabaseException();
    }
  }
}
