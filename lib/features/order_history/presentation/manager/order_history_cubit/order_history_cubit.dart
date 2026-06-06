import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/bloc/safe_emit_mixin.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';
import 'package:makanak/features/order_history/domain/repos/order_history_repository.dart';
import 'package:makanak/features/order_history/presentation/manager/order_history_cubit/order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState>
    with SafeEmitMixin<OrderHistoryState> {
  OrderHistoryCubit(this._repository) : super(const OrderHistoryInitial());

  final OrderHistoryRepository _repository;
  int _refreshFailureId = 0;

  Future<void> fetchOrders() async {
    final currentState = state;
    final previousOrders =
        currentState is OrderHistorySuccess
            ? currentState.orders
            : <OrderModel>[];
    final shouldPreserveContent = currentState is OrderHistorySuccess;

    if (!shouldPreserveContent) {
      safeEmit(const OrderHistoryLoading());
    }

    final result = await _repository.fetchOrders();

    result.fold((failure) {
      if (shouldPreserveContent) {
        safeEmit(
          OrderHistorySuccess(
            previousOrders,
            refreshFailure: failure,
            refreshFailureId: ++_refreshFailureId,
          ),
        );
        return;
      }

      safeEmit(OrderHistoryFailure(failure));
    }, (orders) => safeEmit(OrderHistorySuccess(orders)));
  }
}
