import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';

class ProductsRepoImpl implements ProductsRepo {
  const ProductsRepoImpl(this._databaseService);

  final SupabaseDatabaseService _databaseService;

  @override
  Future<Either<Failure, List<ProductModel>>> fetchProductsByShopId(
    String shopId, {
    String query = '',
    ProductPriceSort priceSort = ProductPriceSort.none,
  }) async {
    try {
      final productsData = await _databaseService.fetchVisibleProductsByShopId(
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
}
