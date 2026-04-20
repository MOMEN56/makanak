import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';

class ShopsRepoImpl implements ShopsRepo {
  const ShopsRepoImpl(this._databaseService);

  final SupabaseDatabaseService _databaseService;

  @override
  Future<Either<Failure, List<ShopModel>>> fetchShops() async {
    try {
      final shopsData = await _databaseService.fetchVisibleActiveShops();
      final shops = shopsData.map(ShopModel.fromJson).toList();
      return right(shops);
    } catch (_) {
      return left(
        const Failure('تعذر تحميل المحلات الآن. حاول مرة أخرى بعد قليل.'),
      );
    }
  }
}
