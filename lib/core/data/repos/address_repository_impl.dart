import 'package:dartz/dartz.dart';
import 'package:makanak/core/data/data_sources/address_local_data_source.dart';
import 'package:makanak/core/data/data_sources/address_remote_data_source.dart';
import 'package:makanak/core/domain/repos/address_repository.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failure_mapper.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/helper/print_helper.dart';
import 'package:makanak/core/models/user_address_model.dart';
import 'package:makanak/core/services/supabase_auth_service.dart';
import 'package:makanak/core/utils/app_strings.dart';

class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._authService,
  );

  final AddressRemoteDataSource _remoteDataSource;
  final AddressLocalDataSource _localDataSource;
  final SupabaseAuthService _authService;

  @override
  Future<List<UserAddressModel>> loadStoredAddresses() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      return await _localDataSource.loadStoredAddresses(userId: userId);
    } catch (error, stackTrace) {
      _logStorageError(
        operation: 'loadStoredAddresses',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<Either<Failure, List<UserAddressModel>>> fetchUserAddresses() async {
    try {
      final data = await _remoteDataSource.fetchUserAddresses();
      final addresses = data.map(UserAddressModel.fromJson).toList();
      await _saveStoredAddressesSafely(addresses);
      return right(addresses);
    } on DatabaseException catch (error) {
      final storedAddresses = await loadStoredAddresses();
      if (error.isNetwork && storedAddresses.isNotEmpty) {
        return right(storedAddresses);
      }

      return left(
        FailureMapper.fromDatabaseException(
          error,
          genericMessage: AppStrings.addressLoadError,
        ),
      );
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
      final address = UserAddressModel.fromJson(data);
      final storedAddresses = await loadStoredAddresses();
      await _saveStoredAddressesSafely(
        _mergeStoredAddresses(storedAddresses, address),
      );
      return right(address);
    } on DatabaseException catch (error) {
      return left(
        FailureMapper.fromDatabaseException(
          error,
          genericMessage: AppStrings.addressSaveError,
        ),
      );
    } catch (_) {
      return left(const Failure(AppStrings.addressSaveError));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String addressId) async {
    try {
      await _remoteDataSource.setDefaultUserAddress(addressId);
      final storedAddresses = await loadStoredAddresses();
      if (storedAddresses.isNotEmpty) {
        await _saveStoredAddressesSafely(
          storedAddresses
              .map(
                (address) =>
                    address.copyWith(isDefault: address.id == addressId),
              )
              .toList(),
        );
      }

      return right(null);
    } on DatabaseException catch (error) {
      return left(
        FailureMapper.fromDatabaseException(
          error,
          genericMessage: AppStrings.defaultAddressError,
        ),
      );
    } catch (_) {
      return left(const Failure(AppStrings.defaultAddressError));
    }
  }

  String? get _currentUserId {
    final userId = _authService.currentSession?.user.id.trim();
    if (userId == null || userId.isEmpty) return null;
    return userId;
  }

  List<UserAddressModel> _mergeStoredAddresses(
    List<UserAddressModel> currentAddresses,
    UserAddressModel newAddress,
  ) {
    final updatedAddresses =
        currentAddresses.map((address) {
          if (address.id == newAddress.id) {
            return newAddress;
          }

          if (newAddress.isDefault && address.isDefault) {
            return address.copyWith(isDefault: false);
          }

          return address;
        }).toList();

    if (updatedAddresses.any((address) => address.id == newAddress.id)) {
      return updatedAddresses;
    }

    if (!newAddress.isDefault) {
      return [...updatedAddresses, newAddress];
    }

    return [
      ...updatedAddresses.map((address) => address.copyWith(isDefault: false)),
      newAddress,
    ];
  }

  Future<void> _saveStoredAddressesSafely(
    List<UserAddressModel> addresses,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _localDataSource.saveStoredAddresses(
        userId: userId,
        addresses: addresses,
      );
    } catch (error, stackTrace) {
      _logStorageError(
        operation: 'saveStoredAddresses',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _logStorageError({
    required String operation,
    required Object error,
    required StackTrace stackTrace,
  }) {
    PrintHelper.error(
      'Address local storage $operation failed.',
      error: error,
      stackTrace: stackTrace,
      tag: 'Address',
    );
  }
}
