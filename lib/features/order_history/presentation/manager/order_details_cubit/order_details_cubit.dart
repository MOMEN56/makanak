import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/order_history/domain/repos/order_history_repository.dart';
import 'package:makanak/features/order_history/presentation/manager/order_details_cubit/order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._repository) : super(const OrderDetailsInitial());

  final OrderHistoryRepository _repository;

  Future<void> fetchOrder(String orderId) async {
    final normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) {
      emit(const OrderDetailsFailure(AppStrings.orderDetailsUnavailable));
      return;
    }

    emit(const OrderDetailsLoading());

    final result = await _repository.fetchOrderById(normalizedOrderId);
    if (isClosed) return;

    result.fold((failure) => emit(OrderDetailsFailure(failure.message)), (
      order,
    ) {
      if (order == null) {
        emit(const OrderDetailsFailure(AppStrings.orderDetailsUnavailable));
        return;
      }

      emit(OrderDetailsSuccess(order));
    });
  }
}
