import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/shops/presentation/views/shops_view.dart';

class BottomNavigationView extends StatelessWidget {
  const BottomNavigationView({super.key});

  static const String routeName = 'bottom_navigation';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: ShopsView(),
    );
  }
}
