import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const cardRadius = 8.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(cardRadius),
                ),
                child: const SizedBox.expand(
                  child: ShimmerBox(height: double.infinity, radius: 0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FractionallySizedBox(
                    widthFactor: 0.82,
                    alignment: Alignment.centerLeft,
                    child: ShimmerBox(height: 18, radius: 999),
                  ),
                  const SizedBox(height: 8),
                  const FractionallySizedBox(
                    widthFactor: 0.45,
                    alignment: Alignment.centerLeft,
                    child: ShimmerBox(height: 14, radius: 999),
                  ),
                  const SizedBox(height: 10),
                  const ShimmerBox(width: 36, height: 36, radius: cardRadius),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
