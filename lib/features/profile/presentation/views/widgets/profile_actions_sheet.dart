import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class ProfileActionsSheet extends StatelessWidget {
  const ProfileActionsSheet({
    super.key,
    required this.onSignOut,
    required this.onGoToShopsList,
  });

  final VoidCallback onSignOut;
  final VoidCallback onGoToShopsList;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppResponsive.spacing(context, 20);
    final verticalPadding = AppResponsive.spacing(context, 16);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          verticalPadding,
          horizontalPadding,
          verticalPadding + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProfileActionContainer(
              label: AppStrings.signOut,
              textColor: const Color(0xffD85B5B),
              backgroundColor: const Color(0xffFFF3F3),
              borderColor: const Color(0xffF2CACA),
              onTap: onSignOut,
            ),
            Gap(AppResponsive.spacing(context, 12)),
            _ProfileActionContainer(
              label: AppStrings.goToShopsList,
              textColor: AppColors.white,
              backgroundColor: AppColors.primaryColor,
              borderColor: AppColors.primaryColor,
              onTap: onGoToShopsList,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionContainer extends StatelessWidget {
  const _ProfileActionContainer({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      AppResponsive.radius(context, 18),
    );

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            padding: AppResponsive.symmetric(
              context,
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              border: Border.all(color: borderColor),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyles.bold16.copyWith(
                fontSize: AppResponsive.text(context, 16),
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
