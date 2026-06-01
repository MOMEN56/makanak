import 'package:makanak/core/services/supabase_remote_data_source.dart';

class ShopsRemoteDataSource extends SupabaseRemoteDataSource {
  const ShopsRemoteDataSource(super.client);

  static const int defaultFetchLimit = 30;
  static const String _shopSelectColumns =
      'id, owner_id, name, logo_url, category, is_active, is_visible, is_open, working_hours';

  Future<List<Map<String, dynamic>>> fetchVisibleActiveShops({
    String query = '',
    int limit = defaultFetchLimit,
  }) async {
    final normalizedQuery = query.trim();
    var request = client
        .from('shops')
        .select(_shopSelectColumns)
        .eq('is_visible', true)
        .eq('is_active', true);

    if (normalizedQuery.isNotEmpty) {
      request = request.ilike('name', '%$normalizedQuery%');
    }

    final data = await guardedRequest(
      () => request.order('name').limit(limit),
      operation: 'fetchVisibleActiveShops',
    );
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> fetchShopById(String shopId) async {
    final normalizedShopId = shopId.trim();
    if (normalizedShopId.isEmpty) {
      return null;
    }

    final data = await guardedRequest(
      () => client
          .from('shops')
          .select(_shopSelectColumns)
          .eq('id', normalizedShopId)
          .eq('is_visible', true)
          .eq('is_active', true)
          .maybeSingle(),
      operation: 'fetchShopById',
      log: true,
    );

    if (data == null) {
      return null;
    }

    return Map<String, dynamic>.from(data);
  }
}
