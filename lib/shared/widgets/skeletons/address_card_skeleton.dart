import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/shared/widgets/confirming_card_widget.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_circle.dart';

class AddressCardSkeleton extends StatelessWidget {
  const AddressCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConfirmingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerCircle(size: 22),
              Gap(8),
              Expanded(child: _HeaderLineSkeleton()),
              Gap(12),
              ShimmerBox(width: 96, height: 32, radius: 999),
            ],
          ),
          Gap(12),
          FractionallySizedBox(
            widthFactor: 0.44,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(height: 14, radius: 999),
          ),
          Gap(6),
          FractionallySizedBox(
            widthFactor: 0.84,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(height: 14, radius: 999),
          ),
          Gap(6),
          FractionallySizedBox(
            widthFactor: 0.66,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(height: 14, radius: 999),
          ),
          Gap(8),
          _AddressMetaSkeleton(widthFactor: 0.52),
          Gap(6),
          _AddressMetaSkeleton(widthFactor: 0.70),
        ],
      ),
    );
  }
}

class _HeaderLineSkeleton extends StatelessWidget {
  const _HeaderLineSkeleton();

  @override
  Widget build(BuildContext context) {
    return const FractionallySizedBox(
      widthFactor: 0.38,
      alignment: Alignment.centerLeft,
      child: ShimmerBox(height: 16, radius: 999),
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
        const ShimmerCircle(size: 18),
        const Gap(6),
        Expanded(
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            alignment: Alignment.centerLeft,
            child: ShimmerBox(height: 12, radius: 999),
          ),
        ),
      ],
    );
  }
}
