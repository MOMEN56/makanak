import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/core/utils/assets.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_logo_badge.dart';
import 'package:makanak/features/auth/presentation/views/widgets/decorative_circle.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.logoAsset = Assets.assetsIconsAppIcon,
    this.showBackButton = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String logoAsset;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: -AppResponsive.height(context, 140),
              right: -AppResponsive.width(context, 40),
              child: DecorativeCircle(
                size: AppResponsive.width(context, 260),
                color: AppColors.primaryColor.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              top: AppResponsive.height(context, 110),
              left: -AppResponsive.width(context, 70),
              child: DecorativeCircle(
                size: AppResponsive.width(context, 180),
                color: AppColors.primaryDarkColor.withValues(alpha: 0.08),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: AppResponsive.fromLTRB(context, 24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showBackButton)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.white,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                    const Gap(8),
                    Center(child: AuthLogoBadge(asset: logoAsset)),
                    const Gap(20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyles.bold24.copyWith(
                        color: AppColors.primaryDarkColor,
                        height: 1.2,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyles.regular14.copyWith(
                        color: AppColors.shopCategoryColor,
                        height: 1.8,
                      ),
                    ),
                    const Gap(28),
                    Container(
                      padding: AppResponsive.all(context, 24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radius(context, 30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDarkColor.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                            spreadRadius: -18,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
