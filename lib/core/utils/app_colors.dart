import 'package:flutter/material.dart';

abstract final class AppColors {
  const AppColors._();

  static const Color primaryDarkColor = Color(0xff00357F);
  static const Color primaryColor = Color(0xff004AAD);
  static const Color lightGrey = Color(0xff75777E);
  static const Color searchFieldGrey = Color(0xff737784);
  static const Color searchFieldBackground = Color(0xffE2E2EB);
  static const Color greyBackground = Color(0xffFAF8FF);
  static const Color shopNameColor = Color(0xff191B22);
  static const Color shopCategoryColor = Color(0xff434653);
  static const Color shopCategoryIconBackground = Color(0xffF3F3FC);
  static const Color shopCategoryIconColor = primaryDarkColor;
  static const Color white = Color(0xffFFFFFF);

  static Color fromHex(String? hexColor, {Color fallback = primaryColor}) {
    if (hexColor == null || hexColor.trim().isEmpty) {
      return fallback;
    }

    var normalizedHex = hexColor.trim().replaceFirst('#', '');
    if (normalizedHex.length == 6) {
      normalizedHex = 'FF$normalizedHex';
    }

    if (normalizedHex.length != 8) {
      return fallback;
    }

    final colorValue = int.tryParse(normalizedHex, radix: 16);
    if (colorValue == null) {
      return fallback;
    }

    return Color(colorValue);
  }

  static Color darkerShade(Color color, [double amount = 0.18]) {
    final hslColor = HSLColor.fromColor(color);
    final darkerLightness = (hslColor.lightness - amount).clamp(0.0, 1.0);
    return hslColor.withLightness(darkerLightness).toColor();
  }
}
