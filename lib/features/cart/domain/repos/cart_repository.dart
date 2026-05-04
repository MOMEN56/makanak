import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/features/cart/data/models/confirming_order_address_model.dart';

abstract class CartRepository {
  Future<Either<Failure, List<ConfirmingOrderAddressModel>>>
  fetchUserAddresses();

  Future<Either<Failure, ConfirmingOrderAddressModel>> saveAddress({
    required String street,
    required String floor,
    required String building,
    required String apartmentNumber,
    String notes = '',
    required String phoneNumber,
  });

  Future<Either<Failure, void>> setDefaultAddress(String addressId);

  Future<Either<Failure, void>> createOrder({
    required String shopId,
    required String productId,
    required String addressId,
    required int quantity,
    required int itemsTotal,
    required int shippingPrice,
  });
}
