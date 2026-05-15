import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/features/order_history/domain/repos/order_history_repository.dart';
import 'package:makanak/features/order_history/presentation/manager/order_history_cubit/order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit(this._repository) : super(const OrderHistoryInitial());

  final OrderHistoryRepository _repository;

  Future<void> fetchOrders() async {
    emit(const OrderHistoryLoading());

    final result = await _repository.fetchOrders();
    if (isClosed) return;

    result.fold(
      (failure) => emit(OrderHistoryFailure(failure.message)),
      (orders) => emit(OrderHistorySuccess(orders)),
    );
  }
}
