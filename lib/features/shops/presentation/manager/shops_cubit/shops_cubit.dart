import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_state.dart';

class ShopsCubit extends Cubit<ShopsState> {
  ShopsCubit(this._shopsRepo) : super(const ShopsInitial());

  final ShopsRepo _shopsRepo;

  Future<void> fetchShops() async {
    emit(const ShopsLoading());

    final result = await _shopsRepo.fetchShops();
    result.fold(
      (failure) => emit(ShopsFailure(failure.message)),
      (shops) => emit(ShopsSuccess(shops)),
    );
  }
}
