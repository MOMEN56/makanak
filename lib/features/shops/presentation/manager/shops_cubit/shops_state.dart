import 'package:equatable/equatable.dart';
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
  const ShopsSuccess(this.shops);

  final List<ShopModel> shops;

  @override
  List<Object?> get props => [shops];
}

class ShopsFailure extends ShopsState {
  const ShopsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
