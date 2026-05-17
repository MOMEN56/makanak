import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/order_history/data/data_sources/orders_remote_data_source.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';
import 'package:makanak/features/order_history/domain/repos/order_history_repository.dart';

class OrderHistoryRepositoryImpl implements OrderHistoryRepository {
  const OrderHistoryRepositoryImpl(this._remoteDataSource);

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<OrderModel>>> fetchOrders() async {
    try {
      final data = await _remoteDataSource.fetchUserOrders();
      final orders = data.map(OrderModel.fromJson).toList(growable: false);
      return right(orders);
    } on DatabaseException {
      return left(const Failure(AppStrings.orderHistoryLoadError));
    } catch (_) {
      return left(const Failure(AppStrings.orderHistoryLoadError));
    }
  }
}
