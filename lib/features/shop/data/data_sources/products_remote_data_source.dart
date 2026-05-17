import 'package:makanak/core/services/supabase_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsRemoteDataSource extends SupabaseRemoteDataSource {
  const ProductsRemoteDataSource(super.client);

  static const int defaultFetchLimit = 30;

  Future<List<Map<String, dynamic>>> fetchVisibleProductsByShopId(
    String shopId, {
    String query = '',
    bool? priceAscending,
    int limit = defaultFetchLimit,
  }) async {
    try {
      final normalizedQuery = query.trim();
      var request = client
          .from('products')
          .select(
            'id, shop_id, name, description, image_url, price, in_stock, stock_quantity, is_visible',
          )
          .eq('shop_id', shopId)
          .eq('is_visible', true);

      if (normalizedQuery.isNotEmpty) {
        request = request.ilike('name', '%$normalizedQuery%');
      }

      final orderedRequest =
          priceAscending == null
              ? request.order('name')
              : request.order('price', ascending: priceAscending);
      final data = await orderedRequest.limit(limit);

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (error) {
      throw databaseException(error);
    } catch (_) {
      throw unexpectedDatabaseException();
    }
  }
}
