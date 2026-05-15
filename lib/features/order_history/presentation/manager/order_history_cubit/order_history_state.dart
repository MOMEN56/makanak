import 'package:equatable/equatable.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';

sealed class OrderHistoryState extends Equatable {
  const OrderHistoryState();

  @override
  List<Object?> get props => [];
}

class OrderHistoryInitial extends OrderHistoryState {
  const OrderHistoryInitial();
}

class OrderHistoryLoading extends OrderHistoryState {
  const OrderHistoryLoading();
}

class OrderHistorySuccess extends OrderHistoryState {
  const OrderHistorySuccess(this.orders);

  final List<OrderModel> orders;

  @override
  List<Object?> get props => [orders];
}

class OrderHistoryFailure extends OrderHistoryState {
  const OrderHistoryFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
