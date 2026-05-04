import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class BottomNavigationItemData {
  const BottomNavigationItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class BottomNavigationItem extends StatelessWidget {
  const BottomNavigationItem({
    super.key,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavigationItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: ShapeDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data.icon, color: Colors.white, size: 24),
                const SizedBox(height: 4),
                Text(
                  data.label,
                  maxLines: 1,
                  style: TextStyles.medium12.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
