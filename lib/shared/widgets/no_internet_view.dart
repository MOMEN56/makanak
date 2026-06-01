import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/assets.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class NoInternetView extends StatelessWidget {
  const NoInternetView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppResponsive.all(context, AppSpacing.screenEdge),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Assets.assetsIconsNoConnectionEmoji,
                    width: AppResponsive.width(context, 180),
                    height: AppResponsive.width(context, 180),
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: AppResponsive.spacing(context, 24)),
                  CustomButton(
                    hint: AppStrings.retry,
                    onTap: onRetry,
                    preventRapidTaps: true,
                    hasShadowEffect: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
