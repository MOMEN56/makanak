import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';

class ProductsRepoImpl implements ProductsRepo {
  const ProductsRepoImpl(this._databaseService);

  final SupabaseDatabaseService _databaseService;

  @override
  Future<Either<Failure, List<ProductModel>>> fetchProductsByShopId(
    String shopId,
  ) async {
    try {
      final productsData = await _databaseService.fetchVisibleProductsByShopId(
        shopId,
      );
      final products = productsData.map(ProductModel.fromJson).toList();
      return right(products);
    } catch (_) {
      return left(
        const Failure('تعذر تحميل المنتجات الآن. حاول مرة أخرى.'),
      );
    }
  }
}
