import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key, this.onTap, this.color});

  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.primaryColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          height: 36,
          width: 36,
          child: Icon(Icons.add, color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}
