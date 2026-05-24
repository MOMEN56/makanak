import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/debouncer.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_state.dart';

class ShopsCubit extends Cubit<ShopsState> {
  ShopsCubit(this._shopsRepo) : super(const ShopsInitial());

  final ShopsRepo _shopsRepo;
  final Debouncer _searchDebouncer = Debouncer(
    delay: const Duration(milliseconds: 400),
  );
  String _query = '';
  int _requestId = 0;

  Future<void> fetchShops() async {
    await _fetchShops(query: '');
  }

  void searchShops(String query) {
    final nextQuery = _normalizeQuery(query);
    if (nextQuery == _query) return;

    _query = nextQuery;
    _searchDebouncer.cancel();
    _requestId++;
    _searchDebouncer.run(() {
      _fetchShops(query: nextQuery);
    });
  }

  Future<void> _fetchShops({required String query}) async {
    _query = query;
    final currentRequestId = ++_requestId;
    emit(const ShopsLoading());

    final result = await _shopsRepo.fetchShops(query: query);
    if (currentRequestId != _requestId || isClosed) return;

    result.fold(
      (failure) => emit(ShopsFailure(failure.message)),
      (shops) => emit(ShopsSuccess(shops)),
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
