import 'package:flutter/material.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_history_view_body.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  static const String routeName = 'order_history';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: OrderHistoryViewBody());
  }
}
