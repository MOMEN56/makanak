import 'package:equatable/equatable.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

sealed class ShopsState extends Equatable {
  const ShopsState();

  @override
  List<Object?> get props => [];
}

class ShopsInitial extends ShopsState {
  const ShopsInitial();
}

class ShopsLoading extends ShopsState {
  const ShopsLoading();
}

class ShopsSuccess extends ShopsState {
  const ShopsSuccess(
    this.shops, {
    this.query = '',
    this.refreshFailure,
    this.refreshFailureId = 0,
  });

  final List<ShopModel> shops;
  final String query;
  final Failure? refreshFailure;
  final int refreshFailureId;

  bool get hasActiveSearch => query.trim().isNotEmpty;

  @override
  List<Object?> get props => [shops, query, refreshFailure, refreshFailureId];
}

class ShopsFailure extends ShopsState {
  const ShopsFailure(this.failure);

  final Failure failure;

  String get message => failure.message;
  bool get isNetworkFailure => failure.isNetwork;

  @override
  List<Object?> get props => [failure];
}
