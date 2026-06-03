import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:makanak/core/utils/app_colors.dart';

class AppSystemUiWrapper extends StatelessWidget {
  const AppSystemUiWrapper({super.key, required this.child});

  final Widget child;

  static const SystemUiOverlayStyle _overlayStyle = SystemUiOverlayStyle(
    statusBarColor: AppColors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: Stack(
        children: [
          child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top,
            child: const IgnorePointer(
              child: ColoredBox(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
