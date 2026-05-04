import 'package:flutter/material.dart';
import 'package:makanak/core/utils/assets.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/presentation/views/product_details_view.dart';
import 'package:makanak/features/shop/presentation/views/widgets/product_card.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/message_emoji_widget.dart';

class ProductsList extends StatefulWidget {
  const ProductsList({
    super.key,
    required this.products,
    required this.primaryColor,
    this.shopModel,
    this.onProductSelected,
  });

  final List<ProductModel> products;
  final Color primaryColor;
  final ShopModel? shopModel;
  final void Function(ProductModel product, int quantity)? onProductSelected;

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  final Map<String, int> _quantities = {};

  String _productKey(ProductModel product, int index) {
    return product.id ?? '${product.shopId}-${product.name}-$index';
  }

  int _quantityFor(ProductModel product, int index) {
    return _quantities[_productKey(product, index)] ?? 0;
  }

  void _setQuantity(ProductModel product, int index, int quantity) {
    setState(() => _quantities[_productKey(product, index)] = quantity);
    widget.onProductSelected?.call(product, quantity);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const MessageEmojiWidget(
        image: Assets.assetsIconsIdkEmoji,
        text: 'لا توجد منتجات بهذا الأسم.',
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: widget.products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final product = widget.products[index];
        final quantity = _quantityFor(product, index);

        return ProductCard(
          product: product,
          quantity: quantity,
          primaryColor: widget.primaryColor,
          onTap: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            await Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                reverseTransitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return ProductDetailsView(
                    product: product,
                    primaryColor: widget.primaryColor,
                    shopModel: widget.shopModel,
                    initialQuantity: quantity,
                  );
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
            if (!context.mounted) return;
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onQuantityChanged:
              (quantity) => _setQuantity(product, index, quantity),
        );
      },
    );
  }
}
