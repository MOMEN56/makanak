import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/assets.dart';

class AuthLogoBadge extends StatelessWidget {
  const AuthLogoBadge({super.key, this.asset = Assets.assetsIconsAppIcon});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkColor.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 18),
            spreadRadius: -18,
          ),
        ],
      ),
      child: Image.asset(asset, width: 64, height: 64),
    );
  }
}
