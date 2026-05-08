import 'package:makanak/core/utils/app_strings.dart';

String? validateAuthFullName(String? value) {
  final fullName = value?.trim() ?? '';
  if (fullName.isEmpty) {
    return AppStrings.authFullNameRequired;
  }

  if (fullName.length < 3) {
    return AppStrings.authFullNameTooShort;
  }

  return null;
}

String? validateAuthEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return AppStrings.authEmailRequired;
  }

  const emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
  if (!RegExp(emailPattern).hasMatch(email)) {
    return AppStrings.authEmailInvalid;
  }

  return null;
}

String? validateAuthPassword(String? value) {
  if ((value ?? '').isEmpty) {
    return AppStrings.authPasswordRequired;
  }

  if ((value ?? '').length < 8) {
    return AppStrings.authPasswordTooShort;
  }

  return null;
}

String? validateAuthConfirmPassword(String? value, String password) {
  if ((value ?? '').isEmpty) {
    return AppStrings.authConfirmPasswordRequired;
  }

  if (value != password) {
    return AppStrings.authPasswordsDoNotMatch;
  }

  return null;
}
