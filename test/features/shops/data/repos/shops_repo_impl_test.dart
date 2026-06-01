import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failure_mapper.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/shops/data/data_sources/shops_remote_data_source.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/data/repos/shops_repo_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('ShopsRepoImpl.fetchShopById', () {
    test('returns a shop model when remote data exists', () async {
      final repo = ShopsRepoImpl(
        _FakeShopsRemoteDataSource(
          shopData: const {
            'id': 'shop-1',
            'owner_id': 'owner-1',
            'name': 'Test Shop',
            'logo_url': 'https://example.com/logo.png',
            'category': 'Groceries',
            'is_active': true,
            'is_visible': true,
            'is_open': true,
            'working_hours': '9-5',
          },
        ),
      );

      final result = await repo.fetchShopById('shop-1');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected a shop model'), (shop) {
        expect(shop?.id, 'shop-1');
        expect(shop?.name, 'Test Shop');
      });
    });

    test('returns null when the remote data source finds no shop', () async {
      final repo = ShopsRepoImpl(_FakeShopsRemoteDataSource());

      final result = await repo.fetchShopById('missing-shop');

      expect(result, const Right<Failure, ShopModel?>(null));
    });

    test('maps database errors to a failure', () async {
      const error = DatabaseException.network('network failed');
      final repo = ShopsRepoImpl(_FakeShopsRemoteDataSource(fetchError: error));

      final result = await repo.fetchShopById('shop-1');

      expect(
        result,
        Left<Failure, dynamic>(
          FailureMapper.fromDatabaseException(
            error,
            genericMessage: AppStrings.shopsLoadError,
          ),
        ),
      );
    });
  });
}

class _FakeShopsRemoteDataSource extends ShopsRemoteDataSource {
  _FakeShopsRemoteDataSource({this.shopData, this.fetchError})
    : super(SupabaseClient('https://example.com', 'test-anon-key'));

  final Map<String, dynamic>? shopData;
  final Object? fetchError;

  @override
  Future<Map<String, dynamic>?> fetchShopById(String shopId) async {
    if (fetchError != null) {
      throw fetchError!;
    }

    return shopData;
  }
}
