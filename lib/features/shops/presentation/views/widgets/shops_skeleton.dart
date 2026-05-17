import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/shared/widgets/shimmer/app_shimmer.dart';
import 'package:makanak/shared/widgets/skeletons/shop_card_skeleton.dart';

class ShopsSkeleton extends StatelessWidget {
  const ShopsSkeleton({super.key});

  static const int _itemCount = 4;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: AppResponsive.symmetric(context, horizontal: 24),
      sliver: SliverList.separated(
        itemCount: _itemCount,
        itemBuilder:
            (context, index) => const AppShimmer(child: ShopCardSkeleton()),
        separatorBuilder:
            (context, index) => Gap(AppResponsive.spacing(context, 16)),
      ),
    );
  }
}
