import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';

class AppSnackBar {
  const AppSnackBar._();

  static const Color errorBackgroundColor = Color(0xffD85B5B);

  static void show({
    required BuildContext context,
    required String message,
    String? badgeText,
    VoidCallback? onBadgeTap,
    Color backgroundColor = AppColors.primaryColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final normalizedBadgeText = badgeText?.trim() ?? '';
    final hasBadge = normalizedBadgeText.isNotEmpty;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hasBadge) ...[
                const SizedBox(width: 10),
                _SnackBarBadge(text: normalizedBadgeText, onTap: onBadgeTap),
              ],
            ],
          ),
        ),
      );
  }

  static void showError({
    required BuildContext context,
    required String message,
    String? badgeText,
    VoidCallback? onBadgeTap,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context: context,
      message: message,
      badgeText: badgeText,
      onBadgeTap: onBadgeTap,
      backgroundColor: errorBackgroundColor,
      duration: duration,
    );
  }

  static void showNetwork({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    showError(context: context, message: message, duration: duration);
  }
}

class _SnackBarBadge extends StatelessWidget {
  const _SnackBarBadge({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.shopNameColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

