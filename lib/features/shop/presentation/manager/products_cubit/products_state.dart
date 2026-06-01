import 'package:equatable/equatable.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';

sealed class ProductsState extends Equatable {
  const ProductsState({this.priceSort = ProductPriceSort.none});

  final ProductPriceSort priceSort;

  @override
  List<Object?> get props => [priceSort];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading({super.priceSort});
}

class ProductsSuccess extends ProductsState {
  const ProductsSuccess(
    this.products, {
    super.priceSort,
    this.refreshFailure,
    this.refreshFailureId = 0,
  });

  final List<ProductModel> products;
  final Failure? refreshFailure;
  final int refreshFailureId;

  @override
  List<Object?> get props => [products, priceSort, refreshFailure, refreshFailureId];
}

class ProductsFailure extends ProductsState {
  const ProductsFailure(this.failure, {super.priceSort});

  final Failure failure;

  String get message => failure.message;
  bool get isNetworkFailure => failure.isNetwork;

  @override
  List<Object?> get props => [failure, priceSort];
}
