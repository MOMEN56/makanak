import 'package:makanak/core/services/supabase_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource extends SupabaseRemoteDataSource {
  const ProfileRemoteDataSource(super.client);

  Future<Map<String, dynamic>?> fetchProfileById(String id) async {
    try {
      final data =
          await client
              .from('profiles')
              .select('id, full_name, role')
              .eq('id', id)
              .maybeSingle();

      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data);
    } on PostgrestException catch (error) {
      throw databaseException(error);
    } catch (_) {
      throw unexpectedDatabaseException();
    }
  }

  Future<Map<String, dynamic>> upsertProfile(
    Map<String, dynamic> profile,
  ) async {
    try {
      final data =
          await client
              .from('profiles')
              .upsert(profile, onConflict: 'id')
              .select('id, full_name, role')
              .single();

      return Map<String, dynamic>.from(data);
    } on PostgrestException catch (error) {
      throw databaseException(error, operation: 'upsertProfile', log: true);
    } catch (error, stackTrace) {
      throw unexpectedDatabaseException(
        operation: 'upsertProfile',
        error: error,
        stackTrace: stackTrace,
        log: true,
      );
    }
  }
}
