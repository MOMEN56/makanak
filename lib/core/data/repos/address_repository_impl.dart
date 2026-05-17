import 'package:dartz/dartz.dart';
import 'package:makanak/core/domain/repos/address_repository.dart';
import 'package:makanak/core/data/data_sources/address_remote_data_source.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/models/user_address_model.dart';
import 'package:makanak/core/utils/app_strings.dart';

class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl(this._remoteDataSource);

  final AddressRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<UserAddressModel>>> fetchUserAddresses() async {
    try {
      final data = await _remoteDataSource.fetchUserAddresses();
      final addresses = data.map(UserAddressModel.fromJson).toList();
      return right(addresses);
    } on DatabaseException {
      return left(const Failure(AppStrings.addressLoadError));
    } catch (_) {
      return left(const Failure(AppStrings.addressLoadError));
    }
  }

  @override
  Future<Either<Failure, UserAddressModel>> saveAddress({
    required String street,
    required String floor,
    required String building,
    required String apartmentNumber,
    String notes = '',
    required String phoneNumber,
  }) async {
    try {
      final data = await _remoteDataSource.addUserAddress(
        street: street,
        floor: floor,
        building: building,
        apartmentNumber: apartmentNumber,
        notes: notes,
        phoneNumber: phoneNumber,
      );
      return right(UserAddressModel.fromJson(data));
    } on DatabaseException {
      return left(const Failure(AppStrings.addressSaveError));
    } catch (_) {
      return left(const Failure(AppStrings.addressSaveError));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String addressId) async {
    try {
      await _remoteDataSource.setDefaultUserAddress(addressId);
      return right(null);
    } on DatabaseException {
      return left(const Failure(AppStrings.defaultAddressError));
    } catch (_) {
      return left(const Failure(AppStrings.defaultAddressError));
    }
  }
}
