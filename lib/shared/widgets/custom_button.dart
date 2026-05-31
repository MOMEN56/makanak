import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.hint,
    this.onTap,
    this.icon,
    this.hasShadowEffect = false,
    this.color,
    this.preventRapidTaps = false,
    this.tapCooldown = const Duration(milliseconds: 600),
  });

  final String hint;
  final VoidCallback? onTap;
  final Widget? icon;
  final bool hasShadowEffect;
  final Color? color;
  final bool preventRapidTaps;
  final Duration tapCooldown;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  Timer? _tapCooldownTimer;
  bool _isTapLocked = false;

  @override
  void didUpdateWidget(covariant CustomButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.preventRapidTaps || widget.onTap == null) {
      _tapCooldownTimer?.cancel();
      _tapCooldownTimer = null;
      _isTapLocked = false;
    }
  }

  void _handleTap() {
    final onTap = widget.onTap;
    if (onTap == null || _isTapLocked) return;

    if (!widget.preventRapidTaps) {
      onTap();
      return;
    }

    setState(() => _isTapLocked = true);
    _tapCooldownTimer?.cancel();
    _tapCooldownTimer = Timer(widget.tapCooldown, _unlockTap);
    onTap();
  }

  void _unlockTap() {
    if (!mounted) {
      _isTapLocked = false;
      return;
    }

    setState(() => _isTapLocked = false);
    _tapCooldownTimer = null;
  }

  @override
  void dispose() {
    _tapCooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = widget.color ?? AppColors.primaryColor;
    final gradientStartColor = AppColors.darkerShade(resolvedColor);
    final resolvedOnTap =
        widget.onTap == null || _isTapLocked ? null : _handleTap;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            widget.hasShadowEffect
                ? [
                  BoxShadow(
                    color: resolvedColor.withValues(alpha: 0.28),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: resolvedColor.withValues(alpha: 0.22),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                    spreadRadius: -3,
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: resolvedOnTap,
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [gradientStartColor, resolvedColor],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[widget.icon!, const Gap(6)],
                Flexible(
                  child: Text(
                    widget.hint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyles.bold16.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
