import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/app_remote_config/app_remote_config_strings.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';

class AppRemoteConfigLoadingViewBody extends StatelessWidget {
  const AppRemoteConfigLoadingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.greyBackground,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: AppResponsive.symmetric(context, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppResponsive.width(context, 84),
                  height: AppResponsive.width(context, 84),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: AppResponsive.width(context, 42),
                    color: AppColors.primaryColor,
                  ),
                ),
                Gap(AppResponsive.spacing(context, 22)),
                Text(
                  AppRemoteConfigStrings.loadingTitle,
                  textAlign: TextAlign.center,
                  style: TextStyles.bold24.copyWith(
                    color: AppColors.primaryDarkColor,
                    fontSize: AppResponsive.text(context, 24),
                  ),
                ),
                Gap(AppResponsive.spacing(context, 10)),
                Text(
                  AppRemoteConfigStrings.loadingSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyles.regular14.copyWith(
                    color: AppColors.shopCategoryColor,
                    fontSize: AppResponsive.text(context, 15),
                    height: 1.6,
                  ),
                ),
                Gap(AppResponsive.spacing(context, 20)),
                const CustomLoadingIndicator(size: 30, strokeWidth: 2.8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
