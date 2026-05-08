import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';

abstract class CartRepository {
  Future<Either<Failure, void>> createOrder({
    required String shopId,
    required String productId,
    required String addressId,
    required int quantity,
    required int itemsTotal,
    required int shippingPrice,
  });
}