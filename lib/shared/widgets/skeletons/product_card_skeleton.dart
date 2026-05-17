import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cardRadius = AppResponsive.radius(context, 8);

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
              padding: AppResponsive.fromLTRB(context, 8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.82,
                    alignment: Alignment.centerLeft,
                    child: ShimmerBox(
                      height: AppResponsive.height(context, 18),
                      radius: 999,
                    ),
                  ),
                  SizedBox(height: AppResponsive.spacing(context, 8)),
                  FractionallySizedBox(
                    widthFactor: 0.45,
                    alignment: Alignment.centerLeft,
                    child: ShimmerBox(
                      height: AppResponsive.height(context, 14),
                      radius: 999,
                    ),
                  ),
                  SizedBox(height: AppResponsive.spacing(context, 10)),
                  ShimmerBox(
                    width: AppResponsive.width(context, 36),
                    height: AppResponsive.height(context, 36),
                    radius: cardRadius,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
