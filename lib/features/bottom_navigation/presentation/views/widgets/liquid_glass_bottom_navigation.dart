import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/bottom_navigation_item.dart';

class LiquidGlassBottomNavigation extends StatelessWidget {
  const LiquidGlassBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onItemSelected,
  });

  final int currentIndex;
  final List<BottomNavigationItemData> items;
  final ValueChanged<int> onItemSelected;

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
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: BottomNavigationItem(
                    data: items[index],
                    isSelected: currentIndex == index,
                    onTap: () => onItemSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
