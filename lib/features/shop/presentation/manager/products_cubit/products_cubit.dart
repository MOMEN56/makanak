import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._productsRepo) : super(const ProductsInitial());

  final ProductsRepo _productsRepo;

  Future<void> fetchProducts(String shopId) async {
    emit(const ProductsLoading());

    final result = await _productsRepo.fetchProductsByShopId(shopId);
    result.fold(
      (failure) => emit(ProductsFailure(failure.message)),
      (products) => emit(ProductsSuccess(products)),
    );
  }
}
