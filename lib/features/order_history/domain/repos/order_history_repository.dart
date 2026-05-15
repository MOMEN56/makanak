import 'package:dartz/dartz.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';

abstract class OrderHistoryRepository {
  Future<Either<Failure, List<OrderModel>>> fetchOrders();
}
