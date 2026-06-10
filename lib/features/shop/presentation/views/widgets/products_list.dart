import 'package:flutter/material.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/assets.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/domain/entities/product_availability_extension.dart';
import 'package:makanak/features/shop/presentation/views/product_details_view.dart';
import 'package:makanak/features/shop/presentation/views/widgets/product_card.dart';
import 'package:makanak/features/shop/presentation/views/widgets/products_grid_delegate.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/message_emoji_widget.dart';

class ProductsList extends StatefulWidget {
  const ProductsList({
    super.key,
    required this.products,
    required this.primaryColor,
    required this.resetSelectionSignal,
    required this.isShopOpen,
    this.shopModel,
    this.onProductSelected,
    this.onCartRequested,
    this.bottomPadding = 0,
    this.emptyMessage = AppStrings.productsEmptySearch,
  });

  final List<ProductModel> products;
  final Color primaryColor;
  final int resetSelectionSignal;
  final bool isShopOpen;
  final ShopModel? shopModel;
  final void Function(ProductModel product, int quantity)? onProductSelected;
  final VoidCallback? onCartRequested;
  final double bottomPadding;
  final String emptyMessage;

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  final Map<String, int> _quantities = {};

  @override
  void didUpdateWidget(covariant ProductsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetSelectionSignal == oldWidget.resetSelectionSignal) return;

    _quantities.clear();
  }

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
    final visibleProducts = widget.products
        .where((product) => !product.isHiddenFromCustomers)
        .toList(growable: false);

    if (visibleProducts.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        child: MessageEmojiWidget(
          image: Assets.assetsIconsIdkEmoji,
          text: widget.emptyMessage,
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: visibleProducts.length,
      gridDelegate: buildProductsGridDelegate(context),
      itemBuilder: (context, index) {
        final product = visibleProducts[index];
        final quantity = _quantityFor(product, index);

        return ProductCard(
          product: product,
          quantity: quantity,
          primaryColor: widget.primaryColor,
          resetSignal: widget.resetSelectionSignal,
          isShopOpen: widget.isShopOpen,
          onTap: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            final result = await Navigator.pushNamed(
              context,
              ProductDetailsView.routeName,
              arguments: ProductDetailsRouteArguments.fromModels(
                product: product,
                primaryColor: widget.primaryColor,
                shopModel: widget.shopModel,
                initialQuantity: quantity,
                returnToCartTab: widget.onCartRequested != null,
              ),
            );
            if (!context.mounted) return;
            if (result == ProductDetailsRouteResult.openCart) {
              widget.onCartRequested?.call();
            }
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onQuantityChanged:
              (quantity) => _setQuantity(product, index, quantity),
        );
      },
    );
  }
}
