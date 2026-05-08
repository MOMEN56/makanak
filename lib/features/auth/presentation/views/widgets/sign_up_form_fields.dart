import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_form_validators.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_text_form_field.dart';

class SignUpFormFields extends StatelessWidget {
  const SignUpFormFields({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.enabled,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onChanged,
  });

  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool enabled;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextFormField(
          controller: fullNameController,
          label: AppStrings.authFullName,
          hint: AppStrings.authFullNameHint,
          textInputAction: TextInputAction.next,
          enabled: enabled,
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.primaryColor,
          ),
          validator: validateAuthFullName,
          onChanged: onChanged,
        ),
        const Gap(14),
        AuthTextFormField(
          controller: emailController,
          label: AppStrings.authEmail,
          hint: AppStrings.authEmailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: enabled,
          prefixIcon: const Icon(
            Icons.mail_outline_rounded,
            color: AppColors.primaryColor,
          ),
          validator: validateAuthEmail,
          onChanged: onChanged,
        ),
        const Gap(14),
        AuthTextFormField(
          controller: passwordController,
          label: AppStrings.authPassword,
          hint: AppStrings.authSignUpPasswordHint,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.next,
          enabled: enabled,
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.primaryColor,
          ),
          suffixIcon: IconButton(
            onPressed: enabled ? onTogglePassword : null,
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          validator: validateAuthPassword,
          onChanged: onChanged,
        ),
        const Gap(14),
        AuthTextFormField(
          controller: confirmPasswordController,
          label: AppStrings.authConfirmPassword,
          hint: AppStrings.authConfirmPasswordHint,
          obscureText: obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          enabled: enabled,
          prefixIcon: const Icon(
            Icons.lock_reset_outlined,
            color: AppColors.primaryColor,
          ),
          suffixIcon: IconButton(
            onPressed: enabled ? onToggleConfirmPassword : null,
            icon: Icon(
              obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          validator:
              (value) =>
                  validateAuthConfirmPassword(value, passwordController.text),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
