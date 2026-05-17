import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/shared/widgets/shimmer/app_shimmer.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';
import 'package:makanak/shared/widgets/skeletons/order_history_card_skeleton.dart';

class OrderHistorySkeleton extends StatelessWidget {
  const OrderHistorySkeleton({super.key});

  static const int _cardCount = 5;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppShimmer(
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: AppResponsive.all(context, AppSpacing.screenEdge),
          itemCount: _cardCount + 1,
          separatorBuilder:
              (context, index) => SizedBox(
                height: AppResponsive.spacing(context, index == 0 ? 14 : 10),
              ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Align(
                child: ShimmerBox(
                  width: AppResponsive.width(context, 170),
                  height: AppResponsive.height(context, 28),
                  radius: 999,
                ),
              );
            }

            return const OrderHistoryCardSkeleton();
          },
        ),
      ),
    );
  }
}
