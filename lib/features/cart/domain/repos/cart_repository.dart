import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/features/cart/domain/entities/create_order_item.dart';

abstract class CartRepository {
  Future<Either<Failure, void>> createOrder({
    required String shopId,
    required String addressId,
    required int shippingPrice,
    required List<CreateOrderItem> items,
  });
}
