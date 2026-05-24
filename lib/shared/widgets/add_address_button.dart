import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class AddAddressButton extends StatelessWidget {
  const AddAddressButton({
    super.key,
    required this.onTap,
    this.hint = AppStrings.addAddress,
  });

  final VoidCallback? onTap;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      hint: hint,
      color: AppColors.primaryColor,
      preventRapidTaps: true,
      icon: const Icon(
        Icons.add_location_alt_outlined,
        color: AppColors.white,
        size: 22,
      ),
      onTap: onTap,
    );
  }
}
