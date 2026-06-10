import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class AppRemoteConfigBlockingWidget extends StatelessWidget {
  const AppRemoteConfigBlockingWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.primaryActionColor,
    this.errorMessage,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final Color primaryActionColor;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = AppResponsive.spacing(context, 24);
    final double cardPadding = AppResponsive.spacing(context, 24);
    final double iconSize = AppResponsive.width(context, 42);
    final double iconContainerSize = AppResponsive.width(context, 82);

    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppResponsive.radius(context, 28),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: iconContainerSize,
                        height: iconContainerSize,
                        decoration: BoxDecoration(
                          color: primaryActionColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: iconSize,
                          color: primaryActionColor,
                        ),
                      ),
                      Gap(AppResponsive.spacing(context, 20)),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyles.bold24.copyWith(
                          color: AppColors.primaryDarkColor,
                          fontSize: AppResponsive.text(context, 24),
                        ),
                      ),
                      Gap(AppResponsive.spacing(context, 12)),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyles.regular14.copyWith(
                          color: AppColors.shopCategoryColor,
                          fontSize: AppResponsive.text(context, 15),
                          height: 1.6,
                        ),
                      ),
                      if (errorMessage != null &&
                          errorMessage!.trim().isNotEmpty) ...<Widget>[
                        Gap(AppResponsive.spacing(context, 14)),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyles.medium12.copyWith(
                            color: Colors.red.shade700,
                            fontSize: AppResponsive.text(context, 12),
                            height: 1.5,
                          ),
                        ),
                      ],
                      Gap(AppResponsive.spacing(context, 24)),
                      CustomButton(
                        hint: primaryActionLabel,
                        onTap: onPrimaryAction,
                        color: primaryActionColor,
                        preventRapidTaps: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
