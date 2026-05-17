import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';

class ShopCardSkeleton extends StatelessWidget {
  const ShopCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cardRadius = AppResponsive.radius(context, 16);
    final imageRadius = AppResponsive.radius(context, 12);
    final imageHeight = AppResponsive.height(context, 140);
    final iconSize = AppResponsive.width(context, 48);
    final spacing12 = AppResponsive.spacing(context, 12);
    final spacing16 = AppResponsive.spacing(context, 16);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: AppResponsive.all(context, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(height: imageHeight, radius: imageRadius),
            SizedBox(height: spacing16),
            Row(
              children: [
                ShimmerBox(
                  width: iconSize,
                  height: iconSize,
                  radius: AppResponsive.radius(context, 16),
                ),
                SizedBox(width: spacing12),
                const Expanded(child: _ShopCardTextSkeleton()),
              ],
            ),
            SizedBox(height: spacing16),
            ShimmerBox(
              height: AppResponsive.height(context, 52),
              radius: cardRadius,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopCardTextSkeleton extends StatelessWidget {
  const _ShopCardTextSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FractionallySizedBox(
          widthFactor: 0.62,
          alignment: Alignment.centerLeft,
          child: ShimmerBox(
            height: AppResponsive.height(context, 18),
            radius: 999,
          ),
        ),
        SizedBox(height: AppResponsive.spacing(context, 8)),
        FractionallySizedBox(
          widthFactor: 0.42,
          alignment: Alignment.centerLeft,
          child: ShimmerBox(
            height: AppResponsive.height(context, 12),
            radius: 999,
          ),
        ),
      ],
    );
  }
}
