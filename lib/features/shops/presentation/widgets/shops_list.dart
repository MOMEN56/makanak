import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/features/shop/presentation/views/products_list_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/presentation/widgets/shop_card.dart';

class ShopsList extends StatelessWidget {
  const ShopsList({super.key});

  static const List<ShopModel> shops = [
    ShopModel(
      imageUrl:
          'https://s3-eu-west-1.amazonaws.com/elmenusv5-stg/Normal/23bcf6f9-9f15-4b83-9e37-e9eb2548c623.jpg',
      categoryIcon: Icons.local_restaurant_sharp,
      name: 'تستي توب',
      category: 'وجبات سريعة',
    ),
    ShopModel(
      imageUrl:
          'https://s3-eu-west-1.amazonaws.com/elmenusv5-stg/Normal/23bcf6f9-9f15-4b83-9e37-e9eb2548c623.jpg',
      categoryIcon: Icons.local_cafe,
      name: 'كوفي تايم',
      category: 'مشروبات',
    ),
    ShopModel(
      imageUrl:
          'https://s3-eu-west-1.amazonaws.com/elmenusv5-stg/Normal/23bcf6f9-9f15-4b83-9e37-e9eb2548c623.jpg',
      categoryIcon: Icons.shopping_bag,
      name: 'ماركت الخير',
      category: 'بقالة',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: shops.length,
        separatorBuilder: (context, index) => const Gap(16),
        itemBuilder: (context, index) {
          final shop = shops[index];

          return ShopCard(
            shop: shop,
            onShopTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return ProductsListView(shopModel: shop);
                  },
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
