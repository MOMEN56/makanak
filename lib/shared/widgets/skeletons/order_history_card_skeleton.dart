import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';

class OrderHistoryCardSkeleton extends StatelessWidget {
  const OrderHistoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cardHeight = AppResponsive.height(context, 130);
    final cardRadius = AppResponsive.radius(context, 12);
    final imageWidth = AppResponsive.width(context, 82);
    final badgeWidth = AppResponsive.width(context, 90);

    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cardRadius),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: imageWidth,
                child: const ShimmerBox(height: double.infinity, radius: 0),
              ),
              Expanded(
                child: Padding(
                  padding: AppResponsive.all(context, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FractionallySizedBox(
                              widthFactor: 0.38,
                              alignment: Alignment.centerLeft,
                              child: ShimmerBox(
                                height: AppResponsive.height(context, 12),
                                radius: 999,
                              ),
                            ),
                            SizedBox(height: AppResponsive.spacing(context, 8)),
                            FractionallySizedBox(
                              widthFactor: 0.56,
                              alignment: Alignment.centerLeft,
                              child: ShimmerBox(
                                height: AppResponsive.height(context, 22),
                                radius: 999,
                              ),
                            ),
                            const Spacer(),
                            FractionallySizedBox(
                              widthFactor: 0.46,
                              alignment: Alignment.centerLeft,
                              child: ShimmerBox(
                                height: AppResponsive.height(context, 10),
                                radius: 999,
                              ),
                            ),
                            SizedBox(height: AppResponsive.spacing(context, 4)),
                            FractionallySizedBox(
                              widthFactor: 0.28,
                              alignment: Alignment.centerLeft,
                              child: ShimmerBox(
                                height: AppResponsive.height(context, 10),
                                radius: 999,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppResponsive.spacing(context, 12)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ShimmerBox(
                            width: badgeWidth,
                            height: AppResponsive.height(context, 26),
                            radius: 999,
                          ),
                          ShimmerBox(
                            width: badgeWidth,
                            height: AppResponsive.height(context, 24),
                            radius: 999,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
