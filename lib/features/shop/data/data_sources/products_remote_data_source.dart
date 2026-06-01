import 'package:makanak/core/services/supabase_remote_data_source.dart';

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
    final data = await guardedRequest(
      () => orderedRequest.limit(limit),
      operation: 'fetchVisibleProductsByShopId',
      log: true,
    );

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchProductsByIds({
    required String shopId,
    required List<String> productIds,
  }) async {
    final normalizedShopId = shopId.trim();
    if (normalizedShopId.isEmpty) {
      throw ArgumentError.value(shopId, 'shopId', 'Shop id cannot be empty.');
    }

    final normalizedIds =
        productIds.map((id) => id.trim()).where((id) => id.isNotEmpty).toSet();
    if (normalizedIds.isEmpty) {
      return const [];
    }

    final data = await guardedRequest(
      () => client
          .from('products')
          .select(_productSelectColumns)
          .eq('shop_id', normalizedShopId)
          .inFilter('id', normalizedIds.toList(growable: false)),
      operation: 'fetchProductsByIds',
      log: true,
    );

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> fetchProductByShopAndId({
    required String shopId,
    required String productId,
  }) async {
    final normalizedShopId = shopId.trim();
    final normalizedProductId = productId.trim();

    if (normalizedShopId.isEmpty || normalizedProductId.isEmpty) {
      return null;
    }

    final data = await guardedRequest(
      () => client
          .from('products')
          .select(_productSelectColumns)
          .eq('shop_id', normalizedShopId)
          .eq('id', normalizedProductId)
          .eq('is_visible', true)
          .maybeSingle(),
      operation: 'fetchProductByShopAndId',
      log: true,
    );

    if (data == null) {
      return null;
    }

    return Map<String, dynamic>.from(data);
  }
}

