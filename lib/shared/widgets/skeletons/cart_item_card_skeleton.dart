import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_circle.dart';

class CartItemCardSkeleton extends StatelessWidget {
  const CartItemCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, 8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkColor.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: AppResponsive.symmetric(context, horizontal: 8, vertical: 12),
        child: Row(
          children: [
            ShimmerBox(
              width: AppResponsive.width(context, 74),
              height: AppResponsive.height(context, 74),
              radius: AppResponsive.radius(context, 8),
            ),
            SizedBox(width: AppResponsive.spacing(context, 12)),
            const Expanded(child: _CartItemDetailsSkeleton()),
          ],
        ),
      ),
    );
  }
}

class _CartItemDetailsSkeleton extends StatelessWidget {
  const _CartItemDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: _CartTitleLinesSkeleton()),
            SizedBox(width: AppResponsive.spacing(context, 8)),
            ShimmerCircle(size: AppResponsive.width(context, 28)),
          ],
        ),
        SizedBox(height: AppResponsive.spacing(context, 8)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 0.35,
                alignment: Alignment.centerLeft,
                child: ShimmerBox(
                  height: AppResponsive.height(context, 14),
                  radius: 999,
                ),
              ),
            ),
            SizedBox(width: AppResponsive.spacing(context, 10)),
            ShimmerBox(
              width: AppResponsive.width(context, 92),
              height: AppResponsive.height(context, 24),
              radius: 999,
            ),
          ],
        ),
      ],
    );
  }
}

class _CartTitleLinesSkeleton extends StatelessWidget {
  const _CartTitleLinesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FractionallySizedBox(
          widthFactor: 0.72,
          alignment: Alignment.centerLeft,
          child: ShimmerBox(
            height: AppResponsive.height(context, 16),
            radius: 999,
          ),
        ),
        SizedBox(height: AppResponsive.spacing(context, 6)),
        FractionallySizedBox(
          widthFactor: 0.48,
          alignment: Alignment.centerLeft,
          child: ShimmerBox(
            height: AppResponsive.height(context, 16),
            radius: 999,
          ),
        ),
      ],
    );
  }
}
