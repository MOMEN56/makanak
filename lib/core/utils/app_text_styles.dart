import 'package:flutter/material.dart';

abstract final class TextStyles {
  const TextStyles._();

  static const TextStyle extraBold30 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle regular14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle semiBold14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
  );
  static const TextStyle bold16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle bold20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bold24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.43,
  );

  static const TextStyle medium16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle medium12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle medium10 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle medium8 = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w500,
  );
}
