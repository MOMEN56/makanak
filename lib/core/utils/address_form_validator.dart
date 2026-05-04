import 'package:makanak/core/utils/app_strings.dart';

abstract final class AddressFormValidator {
  const AddressFormValidator._();

  static final RegExp _egyptPhoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');

  static String normalizeDigits(String value) {
    const arabicDigits = {
      '\u0660': '0',
      '\u0661': '1',
      '\u0662': '2',
      '\u0663': '3',
      '\u0664': '4',
      '\u0665': '5',
      '\u0666': '6',
      '\u0667': '7',
      '\u0668': '8',
      '\u0669': '9',
      '\u06f0': '0',
      '\u06f1': '1',
      '\u06f2': '2',
      '\u06f3': '3',
      '\u06f4': '4',
      '\u06f5': '5',
      '\u06f6': '6',
      '\u06f7': '7',
      '\u06f8': '8',
      '\u06f9': '9',
    };

    return value
        .split('')
        .map((char) => arabicDigits[char] ?? char)
        .join()
        .trim();
  }

  static String? requiredMaxWords(
    String? value, {
    required int maxWords,
    required String fieldName,
  }) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return AppStrings.requiredField(fieldName);
    }

    if (_wordCount(trimmedValue) > maxWords) {
      return AppStrings.maxWords(fieldName, maxWords);
    }

    return null;
  }

  static String? optionalMaxWords(
    String? value, {
    required int maxWords,
    required String fieldName,
  }) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return null;
    }

    if (_wordCount(trimmedValue) > maxWords) {
      return AppStrings.feminineMaxWords(fieldName, maxWords);
    }

    return null;
  }

  static String? phoneNumber(String? value) {
    final normalizedPhone = normalizeDigits(value ?? '');
    if (normalizedPhone.isEmpty) {
      return AppStrings.phoneRequired;
    }

    if (!RegExp(r'^\d+$').hasMatch(normalizedPhone)) {
      return AppStrings.phoneDigitsOnly;
    }

    if (normalizedPhone.length != 11) {
      return AppStrings.phoneLength;
    }

    if (!_egyptPhoneRegex.hasMatch(normalizedPhone)) {
      return AppStrings.phonePrefix;
    }

    return null;
  }

  static int _wordCount(String value) {
    return value.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }
}
