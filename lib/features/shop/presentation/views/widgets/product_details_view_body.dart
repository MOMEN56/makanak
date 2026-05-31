import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/domain/entities/product_availability_extension.dart';
import 'package:makanak/features/shop/presentation/actions/add_product_to_cart_action.dart';
import 'package:makanak/features/shop/presentation/views/widgets/product_details_image.dart';
import 'package:makanak/features/shop/presentation/views/widgets/show_product_added_snack_bar.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/custom_button.dart';
import 'package:makanak/shared/widgets/quantity_selector.dart';

class ProductDetailsViewBody extends StatefulWidget {
  const ProductDetailsViewBody({
    super.key,
    required this.product,
    required this.primaryColor,
    this.shopModel,
    this.initialQuantity = 1,
    this.returnToCartTab = false,
  });

  final ProductModel product;
  final Color primaryColor;
  final ShopModel? shopModel;
  final int initialQuantity;
  final bool returnToCartTab;

  @override
  State<ProductDetailsViewBody> createState() => _ProductDetailsViewBodyState();
}

class _ProductDetailsViewBodyState extends State<ProductDetailsViewBody> {
  late int _quantity;
  bool _isDisposed = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity < 1 ? 1 : widget.initialQuantity;
  }

  Future<void> _onAddButtonTap() async {
    if (!mounted ||
        _isDisposed ||
        _isAddingToCart ||
        widget.product.isUnavailableForPurchase) {
      return;
    }

    final quantity = _quantity < 1 ? 1 : _quantity;
    setState(() => _isAddingToCart = true);

    try {
      final result = await AddProductToCartAction.run(
        context: context,
        product: widget.product,
        primaryColor: widget.primaryColor,
        shopModel: widget.shopModel,
        quantity: quantity,
      );
      if (!mounted ||
          _isDisposed ||
          !result.wasAdded ||
          result.product == null) {
        return;
      }

      showProductAddedSnackBar(
        context: context,
        product: result.product!,
        shopColor: widget.primaryColor,
        shopModel: widget.shopModel,
        quantity: quantity,
        onCartTap: widget.returnToCartTab ? _openCartTab : null,
      );
    } finally {
      if (!mounted || _isDisposed) {
        _isAddingToCart = false;
      } else {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  void _openCartTab() {
    if (!mounted || _isDisposed) return;
    Navigator.of(context).pop(ProductDetailsRouteResult.openCart);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkerPrimaryColor = AppColors.darkerShade(widget.primaryColor);
    final isAvailableForPurchase = widget.product.isAvailableForPurchase;
    final availabilityLabel = AppStrings.productOutOfStock;
    final contentBottomPadding = isAvailableForPurchase ? 120.0 : 24.0;

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, contentBottomPadding),
            children: [
              ProductDetailsImage(imageUrl: widget.product.imageUrl),
              const Gap(24),
              Text(
                widget.product.name,
                style: TextStyles.bold24.copyWith(color: darkerPrimaryColor),
              ),
              const Gap(8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.priceText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.bold16.copyWith(
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                  const Gap(8),
                  if (isAvailableForPurchase)
                    QuantitySelector(
                      initialQuantity:
                          widget.initialQuantity < 1
                              ? 1
                              : widget.initialQuantity,
                      color: widget.primaryColor,
                      onChanged: (quantity) => _quantity = quantity,
                    )
                  else
                    Flexible(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffFCE8E8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            availabilityLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyles.semiBold14.copyWith(
                              color: const Color(0xffD85B5B),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Gap(20),
              Text(
                widget.product.desc,
                style: TextStyles.regular14.copyWith(
                  color: AppColors.shopCategoryColor,
                  height: 1.6,
                ),
              ),
            ],
          ),
          if (isAvailableForPurchase)
            PositionedDirectional(
              start: AppSpacing.screenEdge,
              end: AppSpacing.screenEdge,
              bottom: 0,
              child: SafeArea(
                minimum: const EdgeInsets.only(
                  bottom: AppSpacing.buttonBottomGap,
                ),
                child: CustomButton(
                  hint:
                      _isAddingToCart
                          ? AppStrings.addToCartChecking
                          : AppStrings.addToCart,
                  onTap:
                      _isAddingToCart
                          ? null
                          : () => unawaited(_onAddButtonTap()),
                  preventRapidTaps: true,
                  hasShadowEffect: true,
                  color: widget.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
