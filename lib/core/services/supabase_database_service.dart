import 'package:flutter/foundation.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/utils/address_form_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatabaseService {
  const SupabaseDatabaseService(this._client);

  static const int defaultFetchLimit = 30;

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchVisibleActiveShops({
    String query = '',
    int limit = defaultFetchLimit,
  }) async {
    try {
      final normalizedQuery = query.trim();
      var request = _client
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
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, code: e.code);
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }

  void _logPostgrestException(String operation, PostgrestException error) {
    if (!kDebugMode) return;

    debugPrint(
      'Supabase $operation failed: '
      'code=${error.code}, message=${error.message}, details=${error.details}',
    );
  }

  Future<List<Map<String, dynamic>>> fetchVisibleProductsByShopId(
    String shopId, {
    String query = '',
    bool? priceAscending,
    int limit = defaultFetchLimit,
  }) async {
    try {
      final normalizedQuery = query.trim();
      var request = _client
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

  Future<Map<String, dynamic>> addUserAddress({
    required String street,
    required String floor,
    required String building,
    required String apartmentNumber,
    String notes = '',
    required String phoneNumber,
  }) async {
    try {
      final normalizedPhone = AddressFormValidator.normalizeDigits(phoneNumber);
      final data = await _client.rpc(
        'add_user_address',
        params: {
          'p_street': street.trim(),
          'p_floor': floor.trim(),
          'p_building_number': building.trim(),
          'p_apartment_number': apartmentNumber.trim(),
          'p_address_notes': notes.trim(),
          'p_phone_number': normalizedPhone,
        },
      );

      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      _logPostgrestException('addUserAddress', e);
      throw DatabaseException(e.message, code: e.code);
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserAddresses() async {
    try {
      final data = await _client.rpc('fetch_user_addresses');

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, code: e.code);
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }

  Future<Map<String, dynamic>> setDefaultUserAddress(String addressId) async {
    try {
      final data = await _client.rpc(
        'set_default_user_address',
        params: {'p_address_id': addressId},
      );

      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, code: e.code);
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required String shopId,
    required String addressId,
    required int shippingPrice,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final data = await _client.rpc(
        'create_order',
        params: {
          'p_shop_id': shopId,
          'p_address_id': addressId,
          'p_shipping_price': shippingPrice,
          'p_order_details': items,
        },
      );

      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, code: e.code);
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserOrders() async {
    try {
      final userId = _client.auth.currentSession?.user.id.trim();
      if (userId == null || userId.isEmpty) {
        throw const DatabaseException('User is not authenticated');
      }

      final data = await _client
          .from('orders')
          .select('''
            *,
            product:products(
              id,
              shop_id,
              name,
              description,
              image_url,
              price,
              in_stock,
              stock_quantity,
              is_visible
            ),
            user_address:user_addresses(
              id,
              street,
              floor,
              building_number,
              apartment_number,
              address_notes,
              phone_number,
              is_default
            )
            ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, code: e.code);
    } catch (_) {
      throw const DatabaseException('Unexpected database error');
    }
  }
}
