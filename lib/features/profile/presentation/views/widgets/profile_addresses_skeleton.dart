import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/shared/widgets/shimmer/app_shimmer.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';
import 'package:makanak/shared/widgets/skeletons/address_card_skeleton.dart';

class ProfileAddressesSkeleton extends StatelessWidget {
  const ProfileAddressesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AddressCardSkeleton(),
          Gap(14),
          ShimmerBox(height: 52, radius: 16),
        ],
      ),
    );
  }
}
