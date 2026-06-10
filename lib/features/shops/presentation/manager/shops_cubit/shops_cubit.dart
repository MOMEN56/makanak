import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/bloc/safe_emit_mixin.dart';
import 'package:makanak/core/utils/debouncer.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_state.dart';

class ShopsCubit extends Cubit<ShopsState> with SafeEmitMixin<ShopsState> {
  ShopsCubit(this._shopsRepo) : super(const ShopsInitial());

  final ShopsRepo _shopsRepo;
  final Debouncer _searchDebouncer = Debouncer(
    delay: const Duration(milliseconds: 400),
  );
  String _pendingQuery = '';
  String _appliedQuery = '';
  int _requestId = 0;
  int _refreshFailureId = 0;

  String get appliedQuery => _appliedQuery;

  Future<void> fetchShops() async {
    await _fetchShops(query: '');
  }

  Future<void> retry() async {
    _searchDebouncer.cancel();
    await _fetchShops(query: _pendingQuery);
  }

  void searchShops(String query) {
    final nextQuery = _normalizeQuery(query);
    if (nextQuery == _pendingQuery) return;

    _pendingQuery = nextQuery;
    _searchDebouncer.cancel();
    _requestId++;
    _searchDebouncer.run(() {
      _fetchShops(query: nextQuery);
    });
  }

  Future<void> _fetchShops({required String query}) async {
    final previousAppliedQuery = _appliedQuery;
    _pendingQuery = query;
    final currentRequestId = ++_requestId;
    final currentState = state;
    final previousShops =
        currentState is ShopsSuccess ? currentState.shops : const <ShopModel>[];
    final shouldPreserveContent = currentState is ShopsSuccess;

    if (!shouldPreserveContent) {
      safeEmit(const ShopsLoading());
    }

    final result = await _shopsRepo.fetchShops(query: query);
    if (currentRequestId != _requestId) return;

    result.fold(
      (failure) {
        if (shouldPreserveContent) {
          _pendingQuery = previousAppliedQuery;
          safeEmit(
            ShopsSuccess(
              List.unmodifiable(previousShops),
              query: previousAppliedQuery,
              refreshFailure: failure,
              refreshFailureId: ++_refreshFailureId,
            ),
          );
          return;
        }

        safeEmit(ShopsFailure(failure));
      },
      (shops) {
        _appliedQuery = query;
        _pendingQuery = query;
        safeEmit(ShopsSuccess(shops, query: query));
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
