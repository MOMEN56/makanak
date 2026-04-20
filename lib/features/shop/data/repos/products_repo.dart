import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';

abstract class ProductsRepo {
  Future<Either<Failure, List<ProductModel>>> fetchProductsByShopId(
    String shopId,
  );
}
