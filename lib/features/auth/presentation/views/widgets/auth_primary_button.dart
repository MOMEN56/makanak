import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final resolvedColor = AppColors.primaryColor;
    final gradientStartColor = AppColors.darkerShade(resolvedColor);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [gradientStartColor, resolvedColor],
            ),
            boxShadow: [
              BoxShadow(
                color: resolvedColor.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  isLoading
                      ? const SizedBox.square(
                        key: ValueKey('loader'),
                        dimension: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                      : Text(
                        label,
                        key: const ValueKey('label'),
                        style: TextStyles.bold16.copyWith(
                          color: AppColors.white,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
