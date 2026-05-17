import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = AppColors.searchFieldBackground,
    this.highlightColor = AppColors.greyBackground,
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final shimmerDirection =
        Directionality.of(context) == TextDirection.rtl
            ? ShimmerDirection.rtl
            : ShimmerDirection.ltr;

    return RepaintBoundary(
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        direction: shimmerDirection,
        period: const Duration(milliseconds: 1400),
        child: child,
      ),
    );
  }
}
