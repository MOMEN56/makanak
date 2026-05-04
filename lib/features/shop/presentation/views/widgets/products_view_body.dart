import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_cubit.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_state.dart';
import 'package:makanak/features/shop/presentation/views/widgets/fiilter_items_widgets.dart';
import 'package:makanak/features/shop/presentation/views/widgets/products_list.dart';
import 'package:makanak/features/shop/presentation/views/widgets/show_product_added_snack_bar.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/custom_button.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';
import 'package:makanak/shared/widgets/search_text_field.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class ProductsViewBody extends StatefulWidget {
  const ProductsViewBody({super.key, required this.shopModel});

  final ShopModel shopModel;

  @override
  State<ProductsViewBody> createState() => _ProductsViewBodyState();
}

class _ProductsViewBodyState extends State<ProductsViewBody> {
  ProductModel? _selectedProduct;
  int _selectedQuantity = 1;

  void _onPriceSortChanged(BuildContext context, ProductPriceSort priceSort) {
    context.read<ProductsCubit>().changePriceSort(
      widget.shopModel.id ?? '',
      priceSort,
    );
  }

  void _onProductSelected(ProductModel product, int quantity) {
    setState(() {
      _selectedProduct = quantity > 0 ? product : null;
      _selectedQuantity = quantity;
    });
  }

  void _showAddedSnackBar() {
    final product = _selectedProduct;
    if (product == null) return;

    showProductAddedSnackBar(
      context: context,
      product: product,
      shopColor: AppColors.fromHex(widget.shopModel.primaryColor),
      shopModel: widget.shopModel,
      quantity: _selectedQuantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopPrimaryColor = AppColors.fromHex(widget.shopModel.primaryColor);
    final hasSelectedProduct = _selectedProduct != null;

    return Padding(
      padding: AppResponsive.all(context, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(widget.shopModel.imageUrl),
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
                  hintText:
                      '\u0646\u0641\u0633\u0643 \u062a\u062c\u064a\u0628 \u0627\u064a\u0647\u061f',
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
              builder: (context, state) {
                return switch (state) {
                  ProductsInitial() ||
                  ProductsLoading() => const CustomLoadingIndicator(),
                  ProductsSuccess(:final products) => ProductsList(
                    products: products,
                    primaryColor: shopPrimaryColor,
                    shopModel: widget.shopModel,
                    onProductSelected: _onProductSelected,
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
            hint: '\u0627\u0636\u0641 \u0644\u0644\u0633\u0644\u0629',
            onTap: hasSelectedProduct ? _showAddedSnackBar : null,
            hasShadowEffect: hasSelectedProduct,
            color:
                hasSelectedProduct
                    ? shopPrimaryColor
                    : AppColors.searchFieldBackground,
          ),
        ],
      ),
    );
  }
}
