import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/confirming_order_address_model.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._databaseService);

  final SupabaseDatabaseService _databaseService;

  @override
  Future<Either<Failure, List<ConfirmingOrderAddressModel>>>
  fetchUserAddresses() async {
    try {
      final data = await _databaseService.fetchUserAddresses();
      final addresses = data.map(ConfirmingOrderAddressModel.fromJson).toList();
      return right(addresses);
    } on DatabaseException catch (e) {
      return left(Failure(e.message));
    } catch (_) {
      return left(const Failure(AppStrings.addressLoadError));
    }
  }

  @override
  Future<Either<Failure, ConfirmingOrderAddressModel>> saveAddress({
    required String street,
    required String floor,
    required String building,
    required String apartmentNumber,
    String notes = '',
    required String phoneNumber,
  }) async {
    try {
      final data = await _databaseService.addUserAddress(
        street: street,
        floor: floor,
        building: building,
        apartmentNumber: apartmentNumber,
        notes: notes,
        phoneNumber: phoneNumber,
      );
      return right(ConfirmingOrderAddressModel.fromJson(data));
    } on DatabaseException catch (e) {
      return left(Failure(e.message));
    } catch (_) {
      return left(const Failure(AppStrings.addressSaveError));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String addressId) async {
    try {
      await _databaseService.setDefaultUserAddress(addressId);
      return right(null);
    } on DatabaseException catch (e) {
      return left(Failure(e.message));
    } catch (_) {
      return left(const Failure(AppStrings.defaultAddressError));
    }
  }

  @override
  Future<Either<Failure, void>> createOrder({
    required String shopId,
    required String productId,
    required String addressId,
    required int quantity,
    required int itemsTotal,
    required int shippingPrice,
  }) async {
    try {
      await _databaseService.createOrder(
        shopId: shopId,
        productId: productId,
        addressId: addressId,
        quantity: quantity,
        itemsTotal: itemsTotal,
        shippingPrice: shippingPrice,
      );
      return right(null);
    } on DatabaseException catch (e) {
      return left(Failure(e.message));
    } catch (_) {
      return left(const Failure(AppStrings.orderConfirmError));
    }
  }
}
