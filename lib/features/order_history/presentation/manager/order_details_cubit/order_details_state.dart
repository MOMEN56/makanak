import 'package:equatable/equatable.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';

sealed class OrderDetailsState extends Equatable {
  const OrderDetailsState();

  @override
  List<Object?> get props => [];
}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsSuccess extends OrderDetailsState {
  const OrderDetailsSuccess(this.order);

  final OrderModel order;

  @override
  List<Object?> get props => [order];
}

class OrderDetailsFailure extends OrderDetailsState {
  const OrderDetailsFailure(this.failure);

  final Failure failure;

  String get message => failure.message;
  bool get isNetworkFailure => failure.isNetwork;

  @override
  List<Object?> get props => [failure];
}
