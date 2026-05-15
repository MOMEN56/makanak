import 'package:flutter/material.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_details_view_body.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key, required this.order});

  static const String routeName = 'order_details';

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: OrderDetailsViewBody(order: order));
  }
}
