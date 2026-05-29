import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/shop/data/data_sources/products_remote_data_source.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';

class ProductsRepoImpl implements ProductsRepo {
  const ProductsRepoImpl(this._remoteDataSource);

  final ProductsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ProductModel>>> fetchProductsByShopId(
    String shopId, {
    String query = '',
    ProductPriceSort priceSort = ProductPriceSort.none,
  }) async {
    try {
      final productsData = await _remoteDataSource.fetchVisibleProductsByShopId(
        shopId,
        query: query,
        priceAscending: switch (priceSort) {
          ProductPriceSort.none => null,
          ProductPriceSort.lowToHigh => true,
          ProductPriceSort.highToLow => false,
        },
      );
      final products = productsData.map(ProductModel.fromJson).toList();
      return right(products);
    } catch (_) {
      return left(const Failure(AppStrings.productsLoadError));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> fetchProductsByIds({
    required String shopId,
    required List<String> productIds,
  }) async {
    try {
      final productsData = await _remoteDataSource.fetchProductsByIds(
        shopId: shopId,
        productIds: productIds,
      );
      final products = productsData.map(ProductModel.fromJson).toList();
      return right(products);
    } catch (_) {
      return left(const Failure(AppStrings.productsLoadError));
    }
  }
}
