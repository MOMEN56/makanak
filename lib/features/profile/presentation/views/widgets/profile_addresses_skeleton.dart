import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/shared/widgets/shimmer/app_shimmer.dart';
import 'package:makanak/shared/widgets/shimmer/shimmer_box.dart';
import 'package:makanak/shared/widgets/skeletons/address_card_skeleton.dart';

class ProfileAddressesSkeleton extends StatelessWidget {
  const ProfileAddressesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AddressCardSkeleton(),
          SizedBox(height: AppResponsive.spacing(context, 14)),
          const AddressCardSkeleton(),
          SizedBox(height: AppResponsive.spacing(context, 14)),
          ShimmerBox(
            height: AppResponsive.height(context, 52),
            radius: AppResponsive.radius(context, 16),
          ),
        ],
      ),
    );
  }
}
