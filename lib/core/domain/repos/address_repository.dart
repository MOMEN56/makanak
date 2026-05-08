import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/models/confirming_order_address_model.dart';

abstract class AddressRepository {
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
}
