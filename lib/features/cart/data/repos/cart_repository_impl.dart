import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/domain/entities/create_order_item.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';
import 'package:makanak/features/order_history/data/data_sources/orders_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._remoteDataSource);

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, void>> createOrder({
    required String shopId,
    required String addressId,
    required int shippingPrice,
    required List<CreateOrderItem> items,
  }) async {
    try {
      await _remoteDataSource.createOrder(
        shopId: shopId,
        addressId: addressId,
        shippingPrice: shippingPrice,
        items: items
            .map(
              (item) => {
                'product_id': item.productId,
                'quantity': item.quantity,
              },
            )
            .toList(growable: false),
      );
      return right(null);
    } on DatabaseException catch (error) {
      return left(_mapCreateOrderFailure(error));
    } catch (_) {
      return left(const Failure(AppStrings.orderConfirmError));
    }
  }

  Failure _mapCreateOrderFailure(DatabaseException error) {
    if (_isAvailabilityValidationFailure(error.message)) {
      return const Failure(AppStrings.cartAvailabilityCheckFailed);
    }

    return const Failure(AppStrings.orderConfirmError);
  }

  bool _isAvailabilityValidationFailure(String message) {
    final normalizedMessage = message.toLowerCase();
    return normalizedMessage.contains('out of stock') ||
        normalizedMessage.contains('not available') ||
        normalizedMessage.contains('unavailable') ||
        normalizedMessage.contains('hidden') ||
        normalizedMessage.contains('is_visible') ||
        normalizedMessage.contains('in_stock');
  }
}
