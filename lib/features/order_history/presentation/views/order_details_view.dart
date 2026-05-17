import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/features/order_history/presentation/manager/order_details_cubit/order_details_cubit.dart';
import 'package:makanak/features/order_history/presentation/manager/order_details_cubit/order_details_state.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_details_view_body.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key, required this.orderId});

  static const String routeName = 'order_details';

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderDetailsCubit>()..fetchOrder(orderId),
      child: Scaffold(
        body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          builder: (context, state) {
            return switch (state) {
              OrderDetailsInitial() || OrderDetailsLoading() => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              OrderDetailsSuccess(:final order) => OrderDetailsViewBody(
                order: order,
              ),
              OrderDetailsFailure(:final message) => SafeArea(
                child: StateMessage(
                  message: message,
                  onRetry:
                      () =>
                          context.read<OrderDetailsCubit>().fetchOrder(orderId),
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}
