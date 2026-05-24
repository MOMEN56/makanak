import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/debouncer.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._productsRepo) : super(const ProductsInitial());

  final ProductsRepo _productsRepo;
  final Debouncer _searchDebouncer = Debouncer(
    delay: const Duration(milliseconds: 400),
  );
  String _query = '';
  ProductPriceSort _priceSort = ProductPriceSort.none;
  int _requestId = 0;

  Future<void> fetchProducts(String shopId) async {
    await _fetchProducts(shopId, query: '', priceSort: ProductPriceSort.none);
  }

  void searchProducts(String shopId, String query) {
    final nextQuery = _normalizeQuery(query);
    if (nextQuery == _query) return;

    _query = nextQuery;
    _searchDebouncer.cancel();
    _requestId++;
    _searchDebouncer.run(() {
      _fetchProducts(shopId, query: nextQuery, priceSort: _priceSort);
    });
  }

  Future<void> changePriceSort(String shopId, ProductPriceSort priceSort) {
    if (priceSort == _priceSort) return Future.value();
    _searchDebouncer.cancel();
    return _fetchProducts(shopId, query: _query, priceSort: priceSort);
  }

  Future<void> _fetchProducts(
    String shopId, {
    required String query,
    required ProductPriceSort priceSort,
  }) async {
    _query = query;
    _priceSort = priceSort;
    final currentRequestId = ++_requestId;
    emit(ProductsLoading(priceSort: priceSort));

    final result = await _productsRepo.fetchProductsByShopId(
      shopId,
      query: query,
      priceSort: priceSort,
    );
    if (currentRequestId != _requestId || isClosed) return;

    result.fold(
      (failure) => emit(ProductsFailure(failure.message, priceSort: priceSort)),
      (products) => emit(ProductsSuccess(products, priceSort: priceSort)),
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
