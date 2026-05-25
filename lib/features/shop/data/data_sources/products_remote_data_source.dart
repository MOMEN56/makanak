import 'package:makanak/core/services/supabase_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsRemoteDataSource extends SupabaseRemoteDataSource {
  const ProductsRemoteDataSource(super.client);

  static const int defaultFetchLimit = 30;
  static const String _productSelectColumns =
      'id, shop_id, name, description, image_url, price, in_stock, stock_quantity, is_visible';

  String _escapeWildcards(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

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
          .select(_productSelectColumns)
          .eq('shop_id', shopId)
          .eq('is_visible', true);

      if (normalizedQuery.isNotEmpty) {
        final escapedQuery = _escapeWildcards(normalizedQuery);
        request = request.ilike('name', '%$escapedQuery%');
      }

      final orderedRequest =
          priceAscending == null
              ? request.order('name')
              : request.order('price', ascending: priceAscending);
      final data = await orderedRequest.limit(limit);

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (error) {
      throw databaseException(
        error,
        operation: 'fetchVisibleProductsByShopId',
        log: true,
      );
    } catch (error, stackTrace) {
      throw unexpectedDatabaseException(
        operation: 'fetchVisibleProductsByShopId',
        error: error,
        stackTrace: stackTrace,
        log: true,
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsByIds(
    List<String> productIds,
  ) async {
    final normalizedIds =
        productIds.map((id) => id.trim()).where((id) => id.isNotEmpty).toSet();
    if (normalizedIds.isEmpty) {
      return const [];
    }

    try {
      final data = await client
          .from('products')
          .select(_productSelectColumns)
          .inFilter('id', normalizedIds.toList(growable: false));

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (error) {
      throw databaseException(
        error,
        operation: 'fetchProductsByIds',
        log: true,
      );
    } catch (error, stackTrace) {
      throw unexpectedDatabaseException(
        operation: 'fetchProductsByIds',
        error: error,
        stackTrace: stackTrace,
        log: true,
      );
    }
  }
}
