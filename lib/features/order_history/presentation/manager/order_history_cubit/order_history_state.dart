import 'package:equatable/equatable.dart';
import 'package:makanak/core/errors/failures.dart';
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
  const OrderHistorySuccess(
    this.orders, {
    this.refreshFailure,
    this.refreshFailureId = 0,
  });

  final List<OrderModel> orders;
  final Failure? refreshFailure;
  final int refreshFailureId;

  @override
  List<Object?> get props => [orders, refreshFailure, refreshFailureId];
}

class OrderHistoryFailure extends OrderHistoryState {
  const OrderHistoryFailure(this.failure);

  final Failure failure;

  String get message => failure.message;
  bool get isNetworkFailure => failure.isNetwork;

  @override
  List<Object?> get props => [failure];
}
