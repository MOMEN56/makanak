import 'package:makanak/core/services/supabase_remote_data_source.dart';

class ProfileRemoteDataSource extends SupabaseRemoteDataSource {
  const ProfileRemoteDataSource(super.client);

  Future<Map<String, dynamic>?> fetchProfileById(String id) async {
    final data = await guardedRequest(
      () => client
          .from('profiles')
          .select('id, full_name, role')
          .eq('id', id)
          .maybeSingle(),
      operation: 'fetchProfileById',
    );

    if (data == null) {
      return null;
    }

    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> upsertProfile(
    Map<String, dynamic> profile,
  ) async {
    final data = await guardedRequest(
      () => client
          .from('profiles')
          .upsert(profile, onConflict: 'id')
          .select('id, full_name, role')
          .single(),
      operation: 'upsertProfile',
      log: true,
    );

    return Map<String, dynamic>.from(data);
  }
}
