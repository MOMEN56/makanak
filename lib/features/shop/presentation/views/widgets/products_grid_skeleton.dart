import 'package:flutter/material.dart';
import 'package:makanak/features/shop/presentation/views/widgets/products_grid_delegate.dart';
import 'package:makanak/shared/widgets/shimmer/app_shimmer.dart';
import 'package:makanak/shared/widgets/skeletons/product_card_skeleton.dart';

class ProductsGridSkeleton extends StatelessWidget {
  const ProductsGridSkeleton({super.key, this.bottomPadding = 0});

  static const int _itemCount = 6;

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: bottomPadding),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: _itemCount,
        gridDelegate: buildProductsGridDelegate(context),
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      ),
    );
  }
}
