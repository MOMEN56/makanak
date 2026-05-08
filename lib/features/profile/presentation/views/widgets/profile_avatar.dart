import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/assets.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedAvatarUrl = avatarUrl?.trim();

    return ClipOval(
      child: Container(
        height: 50,
        width: 50,
        color: AppColors.shopCategoryIconBackground,
        child:
            resolvedAvatarUrl == null || resolvedAvatarUrl.isEmpty
                ? Image.asset(Assets.assetsIconsDefaultUserImage)
                : Image.network(
                  resolvedAvatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, _, _) =>
                          Image.asset(Assets.assetsIconsDefaultUserImage),
                ),
      ),
    );
  }
}
