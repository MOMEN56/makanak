import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/helpers/bloc_state_change_helpers.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';
import 'package:makanak/features/order_history/presentation/manager/order_history_cubit/order_history_cubit.dart';
import 'package:makanak/features/order_history/presentation/manager/order_history_cubit/order_history_state.dart';
import 'package:makanak/features/order_history/presentation/views/order_details_view.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/empty_order_history_state.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_history_card.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_history_skeleton.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';
import 'package:makanak/shared/views/no_internet_view.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class OrderHistoryViewBody extends StatelessWidget {
  const OrderHistoryViewBody({super.key, this.onFullScreenNetworkStateChanged});

  final ValueChanged<bool>? onFullScreenNetworkStateChanged;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderHistoryCubit, OrderHistoryState>(
      listenWhen: _shouldListenToOrderHistoryChanges,
      listener: (context, state) {
        onFullScreenNetworkStateChanged?.call(
          _isFullScreenNetworkFailure(state),
        );

        if (state is! OrderHistorySuccess || state.refreshFailure == null) {
          return;
        }

        final refreshFailure = state.refreshFailure!;
        if (refreshFailure.isNetwork) {
          AppSnackBar.showNetwork(
            context: context,
            message: refreshFailure.message,
          );
          return;
        }

        AppSnackBar.show(
          context: context,
          message: refreshFailure.message,
          badgeText: AppStrings.retry,
          onBadgeTap: context.read<OrderHistoryCubit>().fetchOrders,
        );
      },
      buildWhen: _shouldRebuildOrderHistoryView,
      builder: (context, state) {
        if (state is OrderHistoryInitial || state is OrderHistoryLoading) {
          return const OrderHistorySkeleton();
        }

        if (state is OrderHistoryFailure) {
          final retry = context.read<OrderHistoryCubit>().fetchOrders;

          return state.failure.isNetwork
              ? NoInternetView(onRetry: retry)
              : SafeArea(
                child: StateMessage(message: state.message, onRetry: retry),
              );
        }

        final orders =
            state is OrderHistorySuccess ? state.orders : const <OrderModel>[];

        return SafeArea(
          child: RefreshIndicator.adaptive(
            color: AppColors.primaryColor,
            onRefresh: context.read<OrderHistoryCubit>().fetchOrders,
            child:
                orders.isEmpty
                    ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: AppResponsive.all(
                        context,
                        AppSpacing.screenEdge,
                      ),
                      children: const [
                        _OrderHistoryTitle(),
                        Gap(14),
                        EmptyOrderHistoryState(),
                        Gap(12),
                      ],
                    )
                    : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: AppResponsive.all(
                        context,
                        AppSpacing.screenEdge,
                      ),
                      itemCount: orders.length + 1,
                      separatorBuilder: (_, index) => Gap(index == 0 ? 14 : 10),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const _OrderHistoryTitle();
                        }

                        final order = orders[index - 1];

                        return OrderHistoryCard(
                          order: order,
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                OrderDetailsView.routeName,
                                arguments: OrderDetailsRouteArguments(
                                  orderId: order.id,
                                ),
                              ),
                        );
                      },
                    ),
          ),
        );
      },
    );
  }
}

class _OrderHistoryTitle extends StatelessWidget {
  const _OrderHistoryTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign: TextAlign.center,
      AppStrings.orderHistory,
      style: TextStyles.bold24.copyWith(color: AppColors.primaryDarkColor),
    );
  }
}

bool _isFullScreenNetworkFailure(OrderHistoryState state) {
  return state is OrderHistoryFailure && state.failure.isNetwork;
}

bool _didRefreshFailureChange(
  OrderHistoryState previous,
  OrderHistoryState current,
) {
  return didRefreshFailureIdChange<OrderHistoryState>(
    previous: previous,
    current: current,
    refreshFailureOf:
        (state) => state is OrderHistorySuccess ? state.refreshFailure : null,
    refreshFailureIdOf:
        (state) => state is OrderHistorySuccess ? state.refreshFailureId : -1,
  );
}

bool _shouldListenToOrderHistoryChanges(
  OrderHistoryState previous,
  OrderHistoryState current,
) {
  if (didFlagChange<OrderHistoryState>(
    previous: previous,
    current: current,
    flagOf: _isFullScreenNetworkFailure,
  )) {
    return true;
  }

  return _didRefreshFailureChange(previous, current);
}

bool _shouldRebuildOrderHistoryView(
  OrderHistoryState previous,
  OrderHistoryState current,
) {
  if (previous.runtimeType != current.runtimeType) {
    return true;
  }

  if (previous is OrderHistorySuccess && current is OrderHistorySuccess) {
    return previous.orders != current.orders;
  }

  if (previous is OrderHistoryFailure && current is OrderHistoryFailure) {
    return previous.failure != current.failure;
  }

  return false;
}
