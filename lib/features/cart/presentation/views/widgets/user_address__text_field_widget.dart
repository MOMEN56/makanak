import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class UserAddressTextField extends StatelessWidget {
  const UserAddressTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.controller,
    this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.isRequired = true,
    this.primaryColor = AppColors.primaryColor,
    this.validator,
  });

  final TextEditingController? controller;
  final String? label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isRequired;
  final Color primaryColor;
  final FormFieldValidator<String>? validator;

  static const _errorColor = Color(0xffD85B5B);
  static final _defaultBorder = _border();
  static final _errorBorder = _border(color: _errorColor);
  static final _textStyle = TextStyles.medium16.copyWith(
    color: AppColors.shopNameColor,
  );
  static final _hintStyle = TextStyles.medium12.copyWith(
    color: AppColors.lightGrey,
    fontSize: 11,
  );
  static final _labelStyle = TextStyles.semiBold14.copyWith(
    color: AppColors.shopCategoryColor,
  );
  static final _errorStyle = TextStyles.medium12.copyWith(color: _errorColor);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator ?? (isRequired ? _requiredValidator : null),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: _textStyle,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hint,
          hintStyle: _hintStyle,
          labelStyle: _labelStyle,
          errorStyle: _errorStyle,
          prefixIcon: Icon(icon, color: primaryColor, size: 22),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: _defaultBorder,
          enabledBorder: _defaultBorder,
          focusedBorder: _border(color: primaryColor),
          errorBorder: _errorBorder,
          focusedErrorBorder: _errorBorder,
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredFieldMessage;
    }
    return null;
  }

  static OutlineInputBorder _border({
    Color color = AppColors.searchFieldBackground,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}
