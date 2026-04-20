import 'package:equatable/equatable.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsSuccess extends ProductsState {
  const ProductsSuccess(this.products);

  final List<ProductModel> products;

  @override
  List<Object?> get props => [products];
}

class ProductsFailure extends ProductsState {
  const ProductsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
