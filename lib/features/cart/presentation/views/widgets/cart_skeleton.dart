import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/shared/widgets/shimmer/app_shimmer.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_circle.dart';
import 'package:makanak/shared/widgets/skeletons/cart_item_card_skeleton.dart';

class CartSkeleton extends StatelessWidget {
  const CartSkeleton({super.key, this.bottomContentPadding = 0});

  final double bottomContentPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: bottomContentPadding == 0,
      child: Padding(
        padding: AppResponsive.all(context, AppSpacing.screenEdge),
        child: AppShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CartHeaderSkeleton(),
              SizedBox(height: AppResponsive.spacing(context, 20)),
              const _CartStepIndicatorSkeleton(),
              SizedBox(height: AppResponsive.spacing(context, 12)),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: 3,
                  separatorBuilder:
                      (context, index) =>
                          SizedBox(height: AppResponsive.spacing(context, 12)),
                  itemBuilder:
                      (context, index) => const CartItemCardSkeleton(),
                ),
              ),
              SizedBox(height: AppResponsive.spacing(context, 12)),
              ShimmerBox(
                height: AppResponsive.height(context, 52),
                radius: AppResponsive.radius(context, 16),
              ),
              SizedBox(height: bottomContentPadding),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartHeaderSkeleton extends StatelessWidget {
  const _CartHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerCircle(size: AppResponsive.width(context, 44)),
        SizedBox(width: AppResponsive.spacing(context, 14)),
        Expanded(
          child: FractionallySizedBox(
            widthFactor: 0.42,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(
              height: AppResponsive.height(context, 20),
              radius: 999,
            ),
          ),
        ),
        SizedBox(width: AppResponsive.spacing(context, 12)),
        ShimmerBox(
          width: AppResponsive.width(context, 92),
          height: AppResponsive.height(context, 34),
          radius: 999,
        ),
      ],
    );
  }
}

class _CartStepIndicatorSkeleton extends StatelessWidget {
  const _CartStepIndicatorSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _CartStepItemSkeleton()),
        Expanded(child: _CartStepLineSkeleton()),
        Expanded(child: _CartStepItemSkeleton()),
        Expanded(child: _CartStepLineSkeleton()),
        Expanded(child: _CartStepItemSkeleton()),
      ],
    );
  }
}

class _CartStepItemSkeleton extends StatelessWidget {
  const _CartStepItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppResponsive.spacing(context, 4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerCircle(size: AppResponsive.width(context, 38)),
          SizedBox(height: AppResponsive.spacing(context, 8)),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: ShimmerBox(
              height: AppResponsive.height(context, 12),
              radius: 999,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartStepLineSkeleton extends StatelessWidget {
  const _CartStepLineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppResponsive.spacing(context, 28)),
      child: const ShimmerBox(height: 3, radius: 999),
    );
  }
}
