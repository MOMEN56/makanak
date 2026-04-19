import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: ShapeDecoration(
        color: AppColors.searchFieldBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textAlign: TextAlign.right,
          style: TextStyles.regular14.copyWith(
            color: AppColors.searchFieldGrey,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyles.regular14.copyWith(
              color: AppColors.searchFieldGrey,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.searchFieldGrey,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
