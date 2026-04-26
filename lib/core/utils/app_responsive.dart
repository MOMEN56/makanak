import 'package:flutter/widgets.dart';

abstract final class AppResponsive {
  const AppResponsive._();

  static const double _baseWidth = 390;
  static const double _baseHeight = 844;

  static double width(BuildContext context, double value) {
    return value *
        _scale(MediaQuery.sizeOf(context).width, _baseWidth, 0.85, 1.2);
  }

  static double height(BuildContext context, double value) {
    return value *
        _scale(MediaQuery.sizeOf(context).height, _baseHeight, 0.85, 1.15);
  }

  static double spacing(BuildContext context, double value) {
    return value *
        _scale(MediaQuery.sizeOf(context).shortestSide, _baseWidth, 0.85, 1.15);
  }

  static double radius(BuildContext context, double value) {
    return spacing(context, value);
  }

  static double text(BuildContext context, double value) {
    return value *
        _scale(MediaQuery.sizeOf(context).shortestSide, _baseWidth, 0.9, 1.1);
  }

  static EdgeInsets all(BuildContext context, double value) {
    return EdgeInsets.all(spacing(context, value));
  }

  static EdgeInsets symmetric(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: spacing(context, horizontal),
      vertical: spacing(context, vertical),
    );
  }

  static EdgeInsets fromLTRB(
    BuildContext context,
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return EdgeInsets.fromLTRB(
      spacing(context, left),
      spacing(context, top),
      spacing(context, right),
      spacing(context, bottom),
    );
  }

  static double _scale(
    double actual,
    double base,
    double minScale,
    double maxScale,
  ) {
    return (actual / base).clamp(minScale, maxScale).toDouble();
  }
}
