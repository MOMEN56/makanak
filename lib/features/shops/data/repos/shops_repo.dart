import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

abstract class ShopsRepo {
  Future<Either<Failure, List<ShopModel>>> fetchShops({String query = ''});

  Future<Either<Failure, ShopModel?>> fetchShopById(String shopId);
}
