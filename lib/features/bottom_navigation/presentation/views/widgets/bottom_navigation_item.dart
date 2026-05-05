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
    this.badgeCount = 0,
  });

  final BottomNavigationItemData data;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(data.icon, color: Colors.white, size: 24),
                    if (badgeCount > 0)
                      PositionedDirectional(
                        top: -7,
                        end: -10,
                        child: _CartBadge(count: badgeCount),
                      ),
                  ],
                ),
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

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';

    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Color(0xFFE53935),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyles.medium12.copyWith(
              color: Colors.white,
              fontSize: 10,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
