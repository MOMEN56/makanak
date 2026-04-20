import 'package:flutter/material.dart';
import 'package:makanak/features/shop/presentation/views/products_list_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/presentation/views/shops_view.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
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
        builder: (_) => const Scaffold(
          body: Center(child: Text('بيانات المحل غير متاحة')),
        ),
      );
    default:
      return null;
  }
}
