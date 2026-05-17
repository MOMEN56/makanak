import 'package:makanak/core/services/supabase_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopsRemoteDataSource extends SupabaseRemoteDataSource {
  const ShopsRemoteDataSource(super.client);

  static const int defaultFetchLimit = 30;

  Future<List<Map<String, dynamic>>> fetchVisibleActiveShops({
    String query = '',
    int limit = defaultFetchLimit,
  }) async {
    try {
      final normalizedQuery = query.trim();
      var request = client
          .from('shops')
          .select(
            'id, owner_id, name, logo_url, category, is_active, is_visible, is_open, working_hours',
          )
          .eq('is_visible', true)
          .eq('is_active', true);

      if (normalizedQuery.isNotEmpty) {
        request = request.ilike('name', '%$normalizedQuery%');
      }

      final data = await request.order('name').limit(limit);
      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (error) {
      throw databaseException(error);
    } catch (_) {
      throw unexpectedDatabaseException();
    }
  }
}
