import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_cubit.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_state.dart';
import 'package:makanak/features/shops/presentation/views/widgets/shops_header.dart';
import 'package:makanak/features/shops/presentation/views/widgets/shops_list.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class ShopsViewBody extends StatelessWidget {
  const ShopsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopsCubit, ShopsState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: AppResponsive.fromLTRB(context, 24, 48, 24, 0),
              sliver: const SliverToBoxAdapter(child: ShopsHeader()),
            ),
            switch (state) {
              ShopsInitial() || ShopsLoading() => const SliverFillRemaining(
                hasScrollBody: false,
                child: CustomLoadingIndicator(),
              ),
              ShopsSuccess(:final shops) =>
                shops.isEmpty
                    ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: StateMessage(
                        message: 'لا توجد محلات متاحة حاليا.',
                      ),
                    )
                    : ShopsList(shops: shops),
              ShopsFailure(:final message) => SliverFillRemaining(
                hasScrollBody: false,
                child: StateMessage(
                  message: message,
                  onRetry: context.read<ShopsCubit>().fetchShops,
                ),
              ),
            },
            const SliverToBoxAdapter(child: Gap(24)),
          ],
        );
      },
    );
  }
}
