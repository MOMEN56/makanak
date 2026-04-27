import 'package:equatable/equatable.dart';
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
  const ProductsSuccess(this.products, {super.priceSort});

  final List<ProductModel> products;

  @override
  List<Object?> get props => [products, priceSort];
}

class ProductsFailure extends ProductsState {
  const ProductsFailure(this.message, {super.priceSort});

  final String message;

  @override
  List<Object?> get props => [message, priceSort];
}
