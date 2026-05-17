import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
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
import 'package:makanak/shared/widgets/state_message.dart';

class OrderHistoryViewBody extends StatelessWidget {
  const OrderHistoryViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
      builder: (context, state) {
        if (state is OrderHistoryInitial || state is OrderHistoryLoading) {
          return const OrderHistorySkeleton();
        }

        if (state is OrderHistoryFailure) {
          return StateMessage(
            message: state.message,
            onRetry: () => context.read<OrderHistoryCubit>().fetchOrders(),
          );
        }

        final orders =
            state is OrderHistorySuccess ? state.orders : const <OrderModel>[];

        return SafeArea(
          child: RefreshIndicator.adaptive(
            color: AppColors.primaryColor,
            onRefresh: () => context.read<OrderHistoryCubit>().fetchOrders(),
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
                                arguments: order,
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
