import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';

enum ProductPriceSort { none, lowToHigh, highToLow }

abstract class ProductsRepo {
  Future<Either<Failure, List<ProductModel>>> fetchProductsByShopId(
    String shopId, {
    String query = '',
    ProductPriceSort priceSort = ProductPriceSort.none,
  });

  Future<Either<Failure, List<ProductModel>>> fetchProductsByIds({
    required String shopId,
    required List<String> productIds,
  });

  Future<Either<Failure, ProductModel?>> fetchProductByShopAndId({
    required String shopId,
    required String productId,
  });
}
