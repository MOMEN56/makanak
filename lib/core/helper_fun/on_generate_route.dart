import 'package:flutter/material.dart';
import 'package:makanak/features/auth/presentation/views/auth_gate_view.dart';
import 'package:makanak/features/auth/presentation/views/sign_in_view.dart';
import 'package:makanak/features/auth/presentation/views/sign_up_view.dart';
import 'package:makanak/features/shop/presentation/views/products_list_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/presentation/views/shops_view.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AuthGateView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const AuthGateView(),
      );
    case SignInView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const SignInView(),
      );
    case SignUpView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const SignUpView(),
      );
    case ShopsView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const ShopsView(),
      );
    case ProductsListView.routeName:
      final shopModel = settings.arguments;
      if (shopModel is ShopModel) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductsListView(shopModel: shopModel),
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder:
            (_) => const Scaffold(
              body: Center(child: Text('بيانات المحل غير متاحة')),
            ),
      );
    default:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const AuthGateView(),
      );
  }
}
