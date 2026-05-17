import 'package:equatable/equatable.dart';
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
  const OrderDetailsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
