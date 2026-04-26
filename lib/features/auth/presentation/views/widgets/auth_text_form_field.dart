import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class AuthTextFormField extends StatelessWidget {
  const AuthTextFormField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      enabled: enabled,
      textAlign: TextAlign.right,
      style: TextStyles.medium16.copyWith(color: AppColors.shopNameColor),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintText: hint,
        hintStyle: TextStyles.regular14.copyWith(color: AppColors.lightGrey),
        labelStyle: TextStyles.regular14.copyWith(
          color: AppColors.shopCategoryColor,
        ),
        filled: true,
        fillColor: AppColors.greyBackground.withValues(alpha: 0.9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: _border(),
        enabledBorder: _border(color: Colors.transparent),
        focusedBorder: _border(color: AppColors.primaryColor),
        errorBorder: _border(color: const Color(0xffD85B5B)),
        focusedErrorBorder: _border(color: const Color(0xffD85B5B)),
      ),
    );
  }

  OutlineInputBorder _border({Color color = AppColors.searchFieldBackground}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color),
    );
  }
}
