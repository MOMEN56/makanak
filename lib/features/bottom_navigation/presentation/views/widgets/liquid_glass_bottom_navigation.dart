import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/bottom_navigation_item.dart';

class LiquidGlassBottomNavigation extends StatefulWidget {
  const LiquidGlassBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onItemSelected,
    this.cartAnimationTrigger = 0,
    this.cartIndex = 1,
    this.cartBadgeCount = 0,
  });

  final int currentIndex;
  final List<BottomNavigationItemData> items;
  final ValueChanged<int> onItemSelected;
  final int cartAnimationTrigger;
  final int cartIndex;
  final int cartBadgeCount;

  @override
  State<LiquidGlassBottomNavigation> createState() =>
      _LiquidGlassBottomNavigationState();
}

class _LiquidGlassBottomNavigationState
    extends State<LiquidGlassBottomNavigation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cartAnimationController;
  late final Animation<double> _cartScaleAnimation;
  late final Animation<double> _cartRotationAnimation;

  @override
  void initState() {
    super.initState();
    _cartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _cartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.96), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(parent: _cartAnimationController, curve: Curves.easeOut),
    );
    _cartRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0), weight: 40),
    ]).animate(
      CurvedAnimation(parent: _cartAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant LiquidGlassBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cartAnimationTrigger != oldWidget.cartAnimationTrigger) {
      _cartAnimationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _cartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.greyBackground.withValues(alpha: 0.86),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDarkColor.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var index = 0; index < widget.items.length; index++)
                Expanded(
                  child: _CartAnimatedNavigationItem(
                    animation: _cartAnimationController,
                    scaleAnimation: _cartScaleAnimation,
                    rotationAnimation: _cartRotationAnimation,
                    isCartItem: index == widget.cartIndex,
                    child: BottomNavigationItem(
                      data: widget.items[index],
                      isSelected: widget.currentIndex == index,
                      badgeCount:
                          index == widget.cartIndex ? widget.cartBadgeCount : 0,
                      onTap: () => widget.onItemSelected(index),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartAnimatedNavigationItem extends StatelessWidget {
  const _CartAnimatedNavigationItem({
    required this.animation,
    required this.scaleAnimation,
    required this.rotationAnimation,
    required this.isCartItem,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> scaleAnimation;
  final Animation<double> rotationAnimation;
  final bool isCartItem;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isCartItem) return child;

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform.rotate(
          angle: rotationAnimation.value,
          child: Transform.scale(scale: scaleAnimation.value, child: child),
        );
      },
    );
  }
}
