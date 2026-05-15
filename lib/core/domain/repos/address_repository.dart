import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/models/user_address_model.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<UserAddressModel>>> fetchUserAddresses();

  Future<Either<Failure, UserAddressModel>> saveAddress({
    required String street,
    required String floor,
    required String building,
    required String apartmentNumber,
    String notes = '',
    required String phoneNumber,
  });

  Future<Either<Failure, void>> setDefaultAddress(String addressId);
}
