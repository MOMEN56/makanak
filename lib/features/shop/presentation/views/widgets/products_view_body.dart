import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
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
  final Map<String, _SelectedCartProduct> _selectedProducts = {};
  int _resetSelectionSignal = 0;

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

  void _addSelectedProductsToCart() {
    if (_selectedProducts.isEmpty) return;

    for (final item in _selectedProducts.values) {
      AddProductToCartAction.run(
        context: context,
        product: item.product,
        primaryColor: AppColors.primaryColor,
        shopModel: widget.shopModel,
        quantity: item.quantity,
      );
    }

    setState(() {
      _selectedProducts.clear();
      _resetSelectionSignal++;
    });
  }

  String _productKey(ProductModel product) {
    return product.id ?? '${product.shopId}-${product.name}';
  }

  @override
  Widget build(BuildContext context) {
    const shopPrimaryColor = AppColors.primaryColor;
    final hasSelectedProducts = _selectedProducts.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(
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
                BlocSelector<ProductsCubit, ProductsState, ProductPriceSort>(
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
                    ProductsLoading() => const ProductsGridSkeleton(),
                    ProductsSuccess(:final products) => ProductsList(
                      products: products,
                      primaryColor: shopPrimaryColor,
                      resetSelectionSignal: _resetSelectionSignal,
                      shopModel: widget.shopModel,
                      onProductSelected: _onProductSelected,
                      onCartRequested: widget.onCartRequested,
                    ),
                    ProductsFailure(:final message) => StateMessage(
                      message: message,
                      onRetry: () {
                        context.read<ProductsCubit>().fetchProducts(
                          widget.shopModel.id ?? '',
                        );
                      },
                    ),
                  };
                },
              ),
            ),
            const Gap(16),
            CustomButton(
              hint: AppStrings.addToCart,
              onTap: hasSelectedProducts ? _addSelectedProductsToCart : null,
              preventRapidTaps: true,
              hasShadowEffect: hasSelectedProducts,
              color:
                  hasSelectedProducts
                      ? shopPrimaryColor
                      : AppColors.searchFieldBackground,
            ),
            SizedBox(height: widget.bottomContentPadding),
          ],
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
