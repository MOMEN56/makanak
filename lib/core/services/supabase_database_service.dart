import 'package:makanak/core/errors/database_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatabaseService {
  const SupabaseDatabaseService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchVisibleActiveShops() async {
    try {
      final data = await _client
          .from('shops')
          .select(
            'id, owner_id, name, logo_url, primary_color, category, is_active, is_visible, is_open, working_hours',
          )
          .eq('is_visible', true)
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, code: e.code);
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVisibleProductsByShopId(
    String shopId,
  ) async {
    try {
      final data = await _client
          .from('products')
          .select(
            'id, shop_id, name, description, image_url, price, in_stock, stock_quantity, is_visible',
          )
          .eq('shop_id', shopId)
          .eq('is_visible', true)
          .order('name');

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, code: e.code);
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }

  Future<Map<String, dynamic>?> fetchProfileById(String id) async {
    try {
      final data =
          await _client
              .from('profiles')
              .select('id, full_name, role')
              .eq('id', id)
              .maybeSingle();

      if (data == null) return null;

      return Map<String, dynamic>.from(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, code: e.code);
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }

  Future<Map<String, dynamic>> upsertProfile(
    Map<String, dynamic> profile,
  ) async {
    try {
      final data =
          await _client
              .from('profiles')
              .upsert(profile, onConflict: 'id')
              .select('id, full_name, role')
              .single();

      return Map<String, dynamic>.from(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, code: e.code);
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }
}
