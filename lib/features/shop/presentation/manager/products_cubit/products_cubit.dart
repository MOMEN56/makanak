import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/debouncer.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._productsRepo) : super(const ProductsInitial());

  final ProductsRepo _productsRepo;
  final Debouncer _searchDebouncer = Debouncer(
    delay: const Duration(milliseconds: 400),
  );
  String _pendingQuery = '';
  String _appliedQuery = '';
  ProductPriceSort _pendingPriceSort = ProductPriceSort.none;
  ProductPriceSort _appliedPriceSort = ProductPriceSort.none;
  int _requestId = 0;
  int _refreshFailureId = 0;

  String get appliedQuery => _appliedQuery;
  ProductPriceSort get appliedPriceSort => _appliedPriceSort;

  Future<void> fetchProducts(String shopId) async {
    await _fetchProducts(shopId, query: '', priceSort: ProductPriceSort.none);
  }

  Future<void> retry(String shopId) async {
    _searchDebouncer.cancel();
    await _fetchProducts(
      shopId,
      query: _pendingQuery,
      priceSort: _pendingPriceSort,
    );
  }

  void searchProducts(String shopId, String query) {
    final nextQuery = _normalizeQuery(query);
    if (nextQuery == _pendingQuery) return;

    _pendingQuery = nextQuery;
    _searchDebouncer.cancel();
    _requestId++;
    _searchDebouncer.run(() {
      _fetchProducts(shopId, query: nextQuery, priceSort: _pendingPriceSort);
    });
  }

  Future<void> changePriceSort(String shopId, ProductPriceSort priceSort) {
    if (priceSort == _pendingPriceSort) return Future.value();
    _searchDebouncer.cancel();
    _pendingPriceSort = priceSort;
    return _fetchProducts(shopId, query: _pendingQuery, priceSort: priceSort);
  }

  Future<void> _fetchProducts(
    String shopId, {
    required String query,
    required ProductPriceSort priceSort,
  }) async {
    final previousAppliedQuery = _appliedQuery;
    final previousAppliedPriceSort = _appliedPriceSort;
    _pendingQuery = query;
    _pendingPriceSort = priceSort;
    final currentRequestId = ++_requestId;
    final currentState = state;
    final previousProducts =
        currentState is ProductsSuccess
            ? currentState.products
            : const <ProductModel>[];
    final shouldPreserveContent = currentState is ProductsSuccess;

    if (!shouldPreserveContent) {
      emit(ProductsLoading(priceSort: priceSort));
    }

    final result = await _productsRepo.fetchProductsByShopId(
      shopId,
      query: query,
      priceSort: priceSort,
    );
    if (currentRequestId != _requestId || isClosed) return;

    result.fold(
      (failure) {
        if (shouldPreserveContent) {
          _pendingQuery = previousAppliedQuery;
          _pendingPriceSort = previousAppliedPriceSort;
          emit(
            ProductsSuccess(
              List.unmodifiable(previousProducts),
              priceSort: previousAppliedPriceSort,
              refreshFailure: failure,
              refreshFailureId: ++_refreshFailureId,
            ),
          );
          return;
        }

        emit(ProductsFailure(failure, priceSort: priceSort));
      },
      (products) {
        _appliedQuery = query;
        _pendingQuery = query;
        _appliedPriceSort = priceSort;
        _pendingPriceSort = priceSort;
        emit(ProductsSuccess(products, priceSort: priceSort));
      },
    );
  }

  String _normalizeQuery(String query) {
    final trimmedQuery = query.trim();
    return trimmedQuery;
  }

  @override
  Future<void> close() {
    _searchDebouncer.dispose();
    return super.close();
  }
}
