import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/features/shop/presentation/views/products_list_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/presentation/views/widgets/shop_card.dart';

class ShopsList extends StatelessWidget {
  const ShopsList({super.key, required this.shops});

  final List<ShopModel> shops;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: AppResponsive.symmetric(context, horizontal: 24),
      sliver: SliverList.separated(
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
