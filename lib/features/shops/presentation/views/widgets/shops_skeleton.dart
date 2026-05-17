import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/shared/widgets/shimmer/app_shimmer.dart';
import 'package:makanak/shared/widgets/skeletons/shop_card_skeleton.dart';

class ShopsSkeleton extends StatelessWidget {
  const ShopsSkeleton({super.key});

  static const int _itemCount = 4;

  @override
  Widget build(BuildContext context) {
    final spacing = AppResponsive.spacing(context, 16);

    return SliverPadding(
      padding: AppResponsive.symmetric(context, horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          AppShimmer(
            child: Column(
              children: [
                for (var index = 0; index < _itemCount; index++) ...[
                  const ShopCardSkeleton(),
                  if (index != _itemCount - 1) SizedBox(height: spacing),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
