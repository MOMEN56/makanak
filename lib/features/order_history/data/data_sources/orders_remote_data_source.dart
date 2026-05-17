import 'package:makanak/core/services/supabase_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersRemoteDataSource extends SupabaseRemoteDataSource {
  const OrdersRemoteDataSource(super.client);

  static const String _userOrderSelect = '''
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
            ''';

  Future<void> createOrder({
    required String shopId,
    required String addressId,
    required int shippingPrice,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      await client.rpc(
        'create_order',
        params: {
          'p_shop_id': shopId,
          'p_address_id': addressId,
          'p_shipping_price': shippingPrice,
          'p_order_details': items,
        },
      );
    } on PostgrestException catch (error) {
      throw databaseException(error, operation: 'createOrder', log: true);
    } catch (error, stackTrace) {
      throw unexpectedDatabaseException(
        operation: 'createOrder',
        error: error,
        stackTrace: stackTrace,
        log: true,
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserOrders() async {
    try {
      final data = await client
          .from('orders')
          .select(_userOrderSelect)
          .eq('user_id', requireAuthenticatedUserId())
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (error) {
      throw databaseException(error);
    } catch (_) {
      throw unexpectedDatabaseException();
    }
  }

  Future<Map<String, dynamic>?> fetchUserOrderById(String orderId) async {
    try {
      final normalizedOrderId = orderId.trim();
      if (normalizedOrderId.isEmpty) {
        return null;
      }

      final data =
          await client
              .from('orders')
              .select(_userOrderSelect)
              .eq('user_id', requireAuthenticatedUserId())
              .eq('id', normalizedOrderId)
              .maybeSingle();

      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data);
    } on PostgrestException catch (error) {
      throw databaseException(error);
    } catch (_) {
      throw unexpectedDatabaseException();
    }
  }
}
