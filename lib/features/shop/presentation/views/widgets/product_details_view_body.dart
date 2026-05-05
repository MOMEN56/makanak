import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/cart_view.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
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
    this.onCartRequested,
    this.onProductAdded,
  });

  final ProductModel product;
  final Color primaryColor;
  final ShopModel? shopModel;
  final int initialQuantity;
  final VoidCallback? onCartRequested;
  final VoidCallback? onProductAdded;

  @override
  State<ProductDetailsViewBody> createState() => _ProductDetailsViewBodyState();
}

class _ProductDetailsViewBodyState extends State<ProductDetailsViewBody> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity < 1 ? 1 : widget.initialQuantity;
  }

  void _onAddButtonTap() {
    final quantity = _quantity < 1 ? 1 : _quantity;

    AddProductToCartAction.run(
      context: context,
      product: widget.product,
      primaryColor: widget.primaryColor,
      shopModel: widget.shopModel,
      quantity: quantity,
      onProductAdded: widget.onProductAdded,
    );

    AppSnackBar.show(
      context: context,
      message: AppStrings.productAddedToCart(
        widget.product.name,
        quantity > 1 ? ' $quantity' : '',
      ),
      badgeText: "السلة",
      backgroundColor: widget.primaryColor,
      onBadgeTap: () => _openCart(quantity),
    );
  }

  void _openCart(int quantity) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final onCartRequested = widget.onCartRequested;
    if (onCartRequested != null) {
      onCartRequested();
      Navigator.maybePop(context);
      return;
    }

    Navigator.pushNamed(
      context,
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
  Widget build(BuildContext context) {
    final darkerPrimaryColor = AppColors.darkerShade(widget.primaryColor);

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
                children: [
                  Expanded(
                    child: Text(
                      widget.product.priceText,
                      style: TextStyles.bold16.copyWith(
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                  QuantitySelector(
                    initialQuantity:
                        widget.initialQuantity < 1 ? 1 : widget.initialQuantity,
                    color: widget.primaryColor,
                    onChanged: (quantity) => _quantity = quantity,
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
                hint: AppStrings.addToCart,
                onTap: _onAddButtonTap,
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
