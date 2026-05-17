import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';

class ShopCardSkeleton extends StatelessWidget {
  const ShopCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const cardRadius = 16.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(height: 140, radius: 12),
            const Gap(16),
            Row(
              children: [
                const ShimmerBox(width: 48, height: 48, radius: 16),
                const Gap(12),
                const Expanded(child: _ShopCardTextSkeleton()),
              ],
            ),
            const Gap(16),
            const ShimmerBox(height: 52, radius: cardRadius),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FractionallySizedBox(
          widthFactor: 0.62,
          alignment: Alignment.centerLeft,
          child: ShimmerBox(height: 18, radius: 999),
        ),
        Gap(8),
        FractionallySizedBox(
          widthFactor: 0.42,
          alignment: Alignment.centerLeft,
          child: ShimmerBox(height: 12, radius: 999),
        ),
      ],
    );
  }
}
