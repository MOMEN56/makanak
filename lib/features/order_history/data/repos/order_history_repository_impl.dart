import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failure_mapper.dart';
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
    } on DatabaseException catch (error) {
      return left(
        FailureMapper.fromDatabaseException(
          error,
          genericMessage: AppStrings.orderHistoryLoadError,
        ),
      );
    } catch (_) {
      return left(const Failure(AppStrings.orderHistoryLoadError));
    }
  }

  @override
  Future<Either<Failure, OrderModel?>> fetchOrderById(String orderId) async {
    try {
      final data = await _remoteDataSource.fetchUserOrderById(orderId);
      if (data == null) {
        return right(null);
      }

      return right(OrderModel.fromJson(data));
    } on DatabaseException catch (error) {
      return left(
        FailureMapper.fromDatabaseException(
          error,
          genericMessage: AppStrings.orderDetailsLoadError,
        ),
      );
    } catch (_) {
      return left(const Failure(AppStrings.orderDetailsLoadError));
    }
  }
}
