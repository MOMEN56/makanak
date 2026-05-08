import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._databaseService);

  final SupabaseDatabaseService _databaseService;

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
    } on DatabaseException {
      return left(const Failure(AppStrings.orderConfirmError));
    } catch (_) {
      return left(const Failure(AppStrings.orderConfirmError));
    }
  }
}
