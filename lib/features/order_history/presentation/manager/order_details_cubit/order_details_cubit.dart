import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/bloc/safe_emit_mixin.dart';
import 'package:makanak/features/order_history/domain/repos/order_history_repository.dart';
import 'package:makanak/features/order_history/presentation/manager/order_details_cubit/order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState>
    with SafeEmitMixin<OrderDetailsState> {
  OrderDetailsCubit(this._repository) : super(OrderDetailsInitial());

  final OrderHistoryRepository _repository;

  Future<void> fetchOrder(String orderId) async {
    if (orderId.trim().isEmpty) {
      safeEmit(
        const OrderDetailsFailure(Failure(AppStrings.orderDetailsUnavailable)),
      );
      return;
    }

    safeEmit(OrderDetailsLoading());

    final result = await _repository.fetchOrderById(orderId);

    result.fold((failure) => safeEmit(OrderDetailsFailure(failure)), (order) {
      if (order == null) {
        safeEmit(
          const OrderDetailsFailure(
            Failure(AppStrings.orderDetailsUnavailable),
          ),
        );
      } else {
        safeEmit(OrderDetailsSuccess(order));
      }
    });
  }
}
