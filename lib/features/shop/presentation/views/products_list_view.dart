import 'package:flutter/material.dart';
import 'package:makanak/features/shop/presentation/widgets/products_list_view_body.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class ProductsListView extends StatelessWidget {
  const ProductsListView({super.key, required this.shopModel});

  static const String routeName = 'products_list';

  final ShopModel shopModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ProductsListViewBody(shopModel: shopModel));
  }
}
