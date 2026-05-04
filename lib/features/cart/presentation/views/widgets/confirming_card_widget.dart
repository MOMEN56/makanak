import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';

class ConfirmingCard extends StatelessWidget {
  const ConfirmingCard({
    super.key,
    required this.child,
    this.primaryColor = AppColors.primaryColor,
  });

  final Widget child;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkerShade(primaryColor).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
