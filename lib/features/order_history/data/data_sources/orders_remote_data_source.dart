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
    final normalizedShopId = shopId.trim();
    if (normalizedShopId.isEmpty) {
      throw ArgumentError.value(shopId, 'shopId', 'Shop id cannot be empty.');
    }

    final normalizedAddressId = addressId.trim();
    if (normalizedAddressId.isEmpty) {
      throw ArgumentError.value(
        addressId,
        'addressId',
        'Address id cannot be empty.',
      );
    }

    if (shippingPrice < 0) {
      throw ArgumentError.value(
        shippingPrice,
        'shippingPrice',
        'Shipping price cannot be negative.',
      );
    }

    if (items.isEmpty) {
      throw ArgumentError.value(
        items,
        'items',
        'Order items must not be empty.',
      );
    }

    final normalizedItems =
        items.map((item) {
          final productId = item['product_id'] ?? item['productId'];
          final quantity = item['quantity'];

          if (productId is! String || productId.trim().isEmpty) {
            throw ArgumentError(
              'Each item must contain a non-empty string product_id.',
            );
          }
          if (quantity is! int || quantity <= 0) {
            throw ArgumentError(
              'Each item must contain a positive integer quantity.',
            );
          }

          return <String, dynamic>{
            'product_id': productId.trim(),
            'quantity': quantity,
          };
        }).toList(growable: false);

    try {
      await client.rpc(
        'create_order',
        params: {
          'p_shop_id': normalizedShopId,
          'p_address_id': normalizedAddressId,
          'p_shipping_price': shippingPrice,
          'p_order_details': normalizedItems,
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
      throw databaseException(error, operation: 'fetchUserOrders', log: true);
    } catch (error, stackTrace) {
      throw unexpectedDatabaseException(
        operation: 'fetchUserOrders',
        error: error,
        stackTrace: stackTrace,
        log: true,
      );
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
      throw databaseException(
        error,
        operation: 'fetchUserOrderById',
        log: true,
      );
    } catch (error, stackTrace) {
      throw unexpectedDatabaseException(
        operation: 'fetchUserOrderById',
        error: error,
        stackTrace: stackTrace,
        log: true,
      );
    }
  }
}
