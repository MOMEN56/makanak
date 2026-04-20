import 'package:supabase/supabase.dart';

class SupabaseDatabaseService {
  const SupabaseDatabaseService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchVisibleActiveShops() async {
    final data = await _client
        .from('shops')
        .select(
          'id, owner_id, name, logo_url, primary_color, category, is_active, is_visible, is_open, working_hours',
        )
        .eq('is_visible', true)
        .eq('is_active', true)
        .order('name');

    return data.map((shop) => Map<String, dynamic>.from(shop)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchVisibleProductsByShopId(
    String shopId,
  ) async {
    final data = await _client
        .from('products')
        .select(
          'id, shop_id, name, description, image_url, price, in_stock, stock_quantity, is_visible',
        )
        .eq('shop_id', shopId)
        .eq('is_visible', true)
        .order('name');

    return data.map((product) => Map<String, dynamic>.from(product)).toList();
  }
}
