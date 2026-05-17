import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/shared/widgets/confirming_card_widget.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_circle.dart';

class AddressCardSkeleton extends StatelessWidget {
  const AddressCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfirmingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerCircle(size: AppResponsive.width(context, 22)),
              SizedBox(width: AppResponsive.spacing(context, 8)),
              const Expanded(child: _HeaderLineSkeleton()),
              SizedBox(width: AppResponsive.spacing(context, 12)),
              ShimmerBox(
                width: AppResponsive.width(context, 96),
                height: AppResponsive.height(context, 32),
                radius: 999,
              ),
            ],
          ),
          SizedBox(height: AppResponsive.spacing(context, 12)),
          FractionallySizedBox(
            widthFactor: 0.44,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(
              height: AppResponsive.height(context, 16),
              radius: 999,
            ),
          ),
          SizedBox(height: AppResponsive.spacing(context, 8)),
          FractionallySizedBox(
            widthFactor: 0.84,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(
              height: AppResponsive.height(context, 14),
              radius: 999,
            ),
          ),
          SizedBox(height: AppResponsive.spacing(context, 6)),
          FractionallySizedBox(
            widthFactor: 0.66,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(
              height: AppResponsive.height(context, 14),
              radius: 999,
            ),
          ),
          SizedBox(height: AppResponsive.spacing(context, 10)),
          const _AddressMetaSkeleton(widthFactor: 0.52),
          SizedBox(height: AppResponsive.spacing(context, 6)),
          const _AddressMetaSkeleton(widthFactor: 0.70),
        ],
      ),
    );
  }
}

class _HeaderLineSkeleton extends StatelessWidget {
  const _HeaderLineSkeleton();

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.38,
      alignment: Alignment.centerLeft,
      child: ShimmerBox(
        height: AppResponsive.height(context, 16),
        radius: 999,
      ),
    );
  }
}

class _AddressMetaSkeleton extends StatelessWidget {
  const _AddressMetaSkeleton({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerCircle(size: AppResponsive.width(context, 18)),
        SizedBox(width: AppResponsive.spacing(context, 6)),
        Expanded(
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(
              height: AppResponsive.height(context, 12),
              radius: 999,
            ),
          ),
        ),
      ],
    );
  }
}
