import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failure_mapper.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/shops/data/data_sources/shops_remote_data_source.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';

class ShopsRepoImpl implements ShopsRepo {
  const ShopsRepoImpl(this._remoteDataSource);

  final ShopsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ShopModel>>> fetchShops({
    String query = '',
  }) async {
    try {
      final shopsData = await _remoteDataSource.fetchVisibleActiveShops(
        query: query,
      );
      final shops = shopsData.map(ShopModel.fromJson).toList();
      return right(shops);
    } on DatabaseException catch (error) {
      return left(
        FailureMapper.fromDatabaseException(
          error,
          genericMessage: AppStrings.shopsLoadError,
        ),
      );
    } catch (_) {
      return left(const Failure(AppStrings.shopsLoadError));
    }
  }

  @override
  Future<Either<Failure, ShopModel?>> fetchShopById(String shopId) async {
    try {
      final shopData = await _remoteDataSource.fetchShopById(shopId);
      if (shopData == null) {
        return right(null);
      }

      return right(ShopModel.fromJson(shopData));
    } on DatabaseException catch (error) {
      return left(
        FailureMapper.fromDatabaseException(
          error,
          genericMessage: AppStrings.shopsLoadError,
        ),
      );
    } catch (_) {
      return left(const Failure(AppStrings.shopsLoadError));
    }
  }
}
