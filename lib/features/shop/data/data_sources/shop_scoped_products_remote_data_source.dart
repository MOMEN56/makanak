import 'package:makanak/features/shop/data/data_sources/products_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopScopedProductsRemoteDataSource extends ProductsRemoteDataSource {
  const ShopScopedProductsRemoteDataSource(super.client);

  Future<List<Map<String, dynamic>>> fetchProductsByShopAndIds({
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

    try {
      final data = await client
          .from('products')
          .select(
            'id, shop_id, name, description, image_url, price, in_stock, stock_quantity, is_visible',
          )
          .eq('shop_id', normalizedShopId)
          .inFilter('id', normalizedIds.toList(growable: false));

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (error) {
      throw databaseException(
        error,
        operation: 'fetchProductsByShopAndIds',
        log: true,
      );
    } catch (error, stackTrace) {
      throw unexpectedDatabaseException(
        operation: 'fetchProductsByShopAndIds',
        error: error,
        stackTrace: stackTrace,
        log: true,
      );
    }
  }
}
