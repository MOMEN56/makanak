import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/features/order_history/presentation/manager/order_history_cubit/order_history_cubit.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_history_view_body.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key, this.onFullScreenNetworkStateChanged});

  static const String routeName = 'order_history';

  final ValueChanged<bool>? onFullScreenNetworkStateChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderHistoryCubit>()..fetchOrders(),
      child: Scaffold(
        body: OrderHistoryViewBody(
          onFullScreenNetworkStateChanged: onFullScreenNetworkStateChanged,
        ),
      ),
    );
  }
}
