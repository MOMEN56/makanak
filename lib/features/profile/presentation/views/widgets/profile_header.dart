import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/auth/domain/entities/profile_entity.dart';
import 'package:makanak/features/profile/presentation/views/widgets/profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isSigningOut,
    required this.onSignOutTap,
  });

  final ProfileEntity? profile;
  final bool isSigningOut;
  final VoidCallback? onSignOutTap;

  @override
  Widget build(BuildContext context) {
    final displayName = _resolveDisplayName();

    return Column(
      children: [
        Row(
          children: [
            ProfileAvatar(avatarUrl: profile?.avatarUrl),
            const Gap(14),
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.bold20.copyWith(color: Colors.black),
              ),
            ),
            const Gap(10),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onSignOutTap,
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.shopCategoryIconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child:
                      isSigningOut
                          ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                          : const Icon(
                            Icons.logout_rounded,
                            size: 22.5,
                            color: AppColors.shopCategoryIconColor,
                          ),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            AppStrings.savedAddresses,
            style: TextStyles.bold16.copyWith(color: AppColors.shopNameColor),
          ),
        ),
      ],
    );
  }

  String _resolveDisplayName() {
    final fullName = profile?.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;

    final email = profile?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    return AppStrings.account;
  }
}
