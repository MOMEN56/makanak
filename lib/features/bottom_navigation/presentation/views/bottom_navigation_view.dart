import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/bottom_navigation_item.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/cart_navigation_tab.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/widgets/liquid_glass_bottom_navigation.dart';
import 'package:makanak/features/order_history/presentation/views/order_history_view.dart';
import 'package:makanak/features/profile/presentation/views/profile_view.dart';
import 'package:makanak/features/shops/presentation/views/shops_view.dart';

class BottomNavigationView extends StatefulWidget {
  const BottomNavigationView({super.key});

  static const String routeName = 'bottom_navigation';

  @override
  State<BottomNavigationView> createState() => _BottomNavigationViewState();
}

class _BottomNavigationViewState extends State<BottomNavigationView> {
  int _currentIndex = 0;

  static const _items = [
    BottomNavigationItemData(icon: Icons.home_rounded, label: 'الرئيسية'),
    BottomNavigationItemData(icon: Icons.shopping_cart_rounded, label: 'السلة'),
    BottomNavigationItemData(
      icon: Icons.receipt_long_rounded,
      label: 'سجل الطلبات',
    ),
    BottomNavigationItemData(icon: Icons.person_rounded, label: 'الحساب'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                ShopsView(),
                CartNavigationTab(),
                OrderHistoryView(),
                ProfileView(),
              ],
            ),
          ),
          PositionedDirectional(
            start: 20,
            end: 20,
            bottom: 25,
            child: LiquidGlassBottomNavigation(
              currentIndex: _currentIndex,
              items: _items,
              onItemSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
