import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/cart_view.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/domain/entities/product_availability_extension.dart';
import 'package:makanak/features/shop/presentation/actions/add_product_to_cart_action.dart';
import 'package:makanak/features/shop/presentation/views/widgets/product_details_image.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';
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

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity < 1 ? 1 : widget.initialQuantity;
  }

  void _onAddButtonTap() {
    if (!mounted || _isDisposed || widget.product.isUnavailableForPurchase) {
      return;
    }

    final quantity = _quantity < 1 ? 1 : _quantity;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    AddProductToCartAction.run(
      context: context,
      product: widget.product,
      primaryColor: widget.primaryColor,
      shopModel: widget.shopModel,
      quantity: quantity,
    );

    AppSnackBar.show(
      context: context,
      message: AppStrings.productAddedToCart(
        widget.product.name,
        quantity > 1 ? ' $quantity' : '',
      ),
      badgeText: AppStrings.cart,
      backgroundColor: widget.primaryColor,
      onBadgeTap:
          () => _openCart(
            quantity: quantity,
            navigator: navigator,
            scaffoldMessenger: scaffoldMessenger,
          ),
    );
  }

  void _openCart({
    required int quantity,
    required NavigatorState navigator,
    required ScaffoldMessengerState scaffoldMessenger,
  }) {
    if (!mounted || _isDisposed) return;

    scaffoldMessenger.hideCurrentSnackBar();

    if (widget.returnToCartTab) {
      navigator.pop(ProductDetailsRouteResult.openCart);
      return;
    }

    navigator.pushNamed(
      CartView.routeName,
      arguments: CartViewArguments(
        product: widget.product,
        quantity: quantity,
        primaryColor: widget.primaryColor,
        shopModel: widget.shopModel,
      ),
    );
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
    final availabilityLabel =
        widget.product.isOutOfStock
            ? AppStrings.productOutOfStock
            : AppStrings.productUnavailableNow;

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
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
                      style: TextStyles.bold16.copyWith(
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                  const Gap(12),
                  if (isAvailableForPurchase)
                    QuantitySelector(
                      initialQuantity:
                          widget.initialQuantity < 1 ? 1 : widget.initialQuantity,
                      color: widget.primaryColor,
                      onChanged: (quantity) => _quantity = quantity,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFCE8E8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        availabilityLabel,
                        style: TextStyles.semiBold14.copyWith(
                          color: const Color(0xffD85B5B),
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
                    isAvailableForPurchase
                        ? AppStrings.addToCart
                        : availabilityLabel,
                onTap: isAvailableForPurchase ? _onAddButtonTap : null,
                preventRapidTaps: true,
                hasShadowEffect: isAvailableForPurchase,
                color:
                    isAvailableForPurchase
                        ? widget.primaryColor
                        : AppColors.searchFieldBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
