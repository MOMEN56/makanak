import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/domain/entities/product_availability_extension.dart';
import 'package:makanak/features/shop/presentation/actions/add_product_to_cart_action.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_cubit.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_state.dart';
import 'package:makanak/features/shop/presentation/views/widgets/fiilter_items_widgets.dart';
import 'package:makanak/features/shop/presentation/views/widgets/products_grid_skeleton.dart';
import 'package:makanak/features/shop/presentation/views/widgets/products_list.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/custom_button.dart';
import 'package:makanak/shared/widgets/network_image_with_placeholder.dart';
import 'package:makanak/shared/widgets/search_text_field.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class ProductsViewBody extends StatefulWidget {
  const ProductsViewBody({
    super.key,
    required this.shopModel,
    this.bottomContentPadding = 0,
    this.onCartRequested,
  });

  final ShopModel shopModel;
  final double bottomContentPadding;
  final VoidCallback? onCartRequested;

  @override
  State<ProductsViewBody> createState() => _ProductsViewBodyState();
}

class _ProductsViewBodyState extends State<ProductsViewBody> {
  static const double _floatingButtonHeight = 52;
  static const double _floatingButtonTopGap = 16;

  final Map<String, _SelectedCartProduct> _selectedProducts = {};
  int _resetSelectionSignal = 0;
  bool _isAddingSelectedProducts = false;

  double get _floatingButtonBottomOffset =>
      AppSpacing.buttonBottomGap + widget.bottomContentPadding;

  double get _productsBottomPadding =>
      _floatingButtonBottomOffset +
      _floatingButtonHeight +
      _floatingButtonTopGap;

  void _onPriceSortChanged(BuildContext context, ProductPriceSort priceSort) {
    context.read<ProductsCubit>().changePriceSort(
      widget.shopModel.id ?? '',
      priceSort,
    );
  }

  void _onProductSelected(ProductModel product, int quantity) {
    final productKey = _productKey(product);
    setState(() {
      if (quantity < 1) {
        _selectedProducts.remove(productKey);
        return;
      }

      _selectedProducts[productKey] = _SelectedCartProduct(
        product: product,
        quantity: quantity,
      );
    });
  }

  void _syncSelectedProductsWithCatalog(List<ProductModel> products) {
    final availableProductsByKey = <String, ProductModel>{
      for (final product in products)
        if (!product.isHiddenFromCustomers && product.isAvailableForPurchase)
          _productKey(product): product,
    };
    final updatedSelections = <String, _SelectedCartProduct>{};

    for (final entry in _selectedProducts.entries) {
      final latestProduct = availableProductsByKey[entry.key];
      if (latestProduct == null) continue;

      updatedSelections[entry.key] = _SelectedCartProduct(
        product: latestProduct,
        quantity: entry.value.quantity,
      );
    }

    if (_hasSameSelectedProducts(updatedSelections)) return;

    setState(() {
      _selectedProducts
        ..clear()
        ..addAll(updatedSelections);
    });
  }

  bool _hasSameSelectedProducts(
    Map<String, _SelectedCartProduct> updatedSelections,
  ) {
    if (updatedSelections.length != _selectedProducts.length) {
      return false;
    }

    for (final entry in updatedSelections.entries) {
      final currentSelection = _selectedProducts[entry.key];
      if (currentSelection == null) return false;
      if (currentSelection.quantity != entry.value.quantity) return false;
      if (currentSelection.product != entry.value.product) return false;
    }

    return true;
  }

  Future<void> _addSelectedProductsToCart() async {
    if (_selectedProducts.isEmpty || _isAddingSelectedProducts) return;

    final selectedProducts = _selectedProducts.values.toList(growable: false);
    setState(() => _isAddingSelectedProducts = true);

    try {
      for (final item in selectedProducts) {
        await AddProductToCartAction.run(
          context: context,
          product: item.product,
          primaryColor: AppColors.primaryColor,
          shopModel: widget.shopModel,
          quantity: item.quantity,
        );
      }

      if (!mounted) return;
      setState(() {
        _selectedProducts.clear();
        _resetSelectionSignal++;
        _isAddingSelectedProducts = false;
      });
    } finally {
      if (mounted && _isAddingSelectedProducts) {
        setState(() => _isAddingSelectedProducts = false);
      }
    }
  }

  String _productKey(ProductModel product) {
    return product.id ?? '${product.shopId}-${product.name}';
  }

  @override
  Widget build(BuildContext context) {
    const shopPrimaryColor = AppColors.primaryColor;
    final hasSelectedProducts = _selectedProducts.isNotEmpty;
    final isAddToCartEnabled =
        hasSelectedProducts && !_isAddingSelectedProducts;

    return BlocListener<ProductsCubit, ProductsState>(
      listenWhen: (_, current) => current is ProductsSuccess,
      listener: (context, state) {
        if (state is! ProductsSuccess) return;
        _syncSelectedProductsWithCatalog(state.products);
      },
      child: SafeArea(
        bottom: widget.bottomContentPadding == 0,
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.screenEdge,
            right: AppSpacing.screenEdge,
            top: 8,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: NetworkImageWithPlaceholder(
                          imageUrl: widget.shopModel.imageUrl,
                          height: 50,
                          width: 50,
                          cacheWidth: 200,
                          cacheHeight: 200,
                          placeholderIcon: Icons.storefront_outlined,
                          placeholderColor: AppColors.greyBackground,
                          iconColor: AppColors.shopCategoryIconColor,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          widget.shopModel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.bold16.copyWith(
                            color: AppColors.darkerShade(shopPrimaryColor),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(30),
                  Row(
                    children: [
                      Expanded(
                        child: SearchTextField(
                          hintText: AppStrings.productSearchHint,
                          onChanged: (value) {
                            context.read<ProductsCubit>().searchProducts(
                              widget.shopModel.id ?? '',
                              value,
                            );
                          },
                        ),
                      ),
                      const Gap(10),
                      BlocSelector<
                        ProductsCubit,
                        ProductsState,
                        ProductPriceSort
                      >(
                        selector: (state) => state.priceSort,
                        builder: (context, priceSort) {
                          return FilterItemsWidgets(
                            priceSort: priceSort,
                            onPriceSortChanged: (priceSort) {
                              _onPriceSortChanged(context, priceSort);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const Gap(24),
                  Expanded(
                    child: BlocBuilder<ProductsCubit, ProductsState>(
                      buildWhen: _shouldRebuildProductsContent,
                      builder: (context, state) {
                        return switch (state) {
                          ProductsInitial() ||
                          ProductsLoading() => ProductsGridSkeleton(
                            bottomPadding: _productsBottomPadding,
                          ),
                          ProductsSuccess(:final products) => ProductsList(
                            products: products,
                            primaryColor: shopPrimaryColor,
                            resetSelectionSignal: _resetSelectionSignal,
                            shopModel: widget.shopModel,
                            onProductSelected: _onProductSelected,
                            onCartRequested: widget.onCartRequested,
                            bottomPadding: _productsBottomPadding,
                          ),
                          ProductsFailure(:final message) => Padding(
                            padding: EdgeInsets.only(
                              bottom: _productsBottomPadding,
                            ),
                            child: StateMessage(
                              message: message,
                              onRetry: () {
                                context.read<ProductsCubit>().fetchProducts(
                                  widget.shopModel.id ?? '',
                                );
                              },
                            ),
                          ),
                        };
                      },
                    ),
                  ),
                ],
              ),
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: _floatingButtonBottomOffset,
                child: CustomButton(
                  hint:
                      _isAddingSelectedProducts
                          ? AppStrings.addToCartChecking
                          : AppStrings.addToCart,
                  onTap:
                      isAddToCartEnabled
                          ? () => unawaited(_addSelectedProductsToCart())
                          : null,
                  preventRapidTaps: true,
                  hasShadowEffect: hasSelectedProducts,
                  color:
                      hasSelectedProducts
                          ? shopPrimaryColor
                          : AppColors.searchFieldBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedCartProduct {
  const _SelectedCartProduct({required this.product, required this.quantity});

  final ProductModel product;
  final int quantity;
}

bool _shouldRebuildProductsContent(
  ProductsState previous,
  ProductsState current,
) {
  if (previous.runtimeType != current.runtimeType) {
    return true;
  }

  if (previous is ProductsSuccess && current is ProductsSuccess) {
    return previous.products != current.products;
  }

  if (previous is ProductsFailure && current is ProductsFailure) {
    return previous.message != current.message;
  }

  return false;
}
