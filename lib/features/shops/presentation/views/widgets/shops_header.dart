import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/shared/widgets/search_text_field.dart';

class ShopsHeader extends StatelessWidget {
  const ShopsHeader({
    super.key,
    this.controller,
    this.onSearchChanged,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Center(
            child: Text(
              AppStrings.shopsHeaderTitle,
              style: TextStyles.extraBold30.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const Gap(16),
          SearchTextField(
            hintText: AppStrings.shopsSearchHint,
            controller: controller,
            onChanged: onSearchChanged,
          ),
        ],
      ),
    );
  }
}
