import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/domain/entities/product_availability_extension.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_meta_chip.dart';
import 'package:makanak/features/shop/presentation/views/widgets/add_button.dart';
import 'package:makanak/shared/widgets/network_image_with_placeholder.dart';
import 'package:makanak/shared/widgets/quantity_selector.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.primaryColor,
    required this.resetSignal,
    this.onTap,
    this.onQuantityChanged,
  });

  final ProductModel product;
  final int quantity;
  final Color primaryColor;
  final int resetSignal;
  final VoidCallback? onTap;
  final ValueChanged<int>? onQuantityChanged;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _showQuantitySelector;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.product.isAvailableForPurchase ? widget.quantity : 0;
    _showQuantitySelector = _quantity > 0;
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.isUnavailableForPurchase) {
      final shouldClearSelection = _quantity != 0 || _showQuantitySelector;
      _showQuantitySelector = false;
      _quantity = 0;

      if (shouldClearSelection) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onQuantityChanged?.call(0);
        });
      }
      return;
    }

    if (widget.resetSignal != oldWidget.resetSignal) {
      _showQuantitySelector = false;
      _quantity = 0;
      return;
    }

    if (widget.quantity != oldWidget.quantity) {
      _quantity = widget.quantity;
      _showQuantitySelector = _quantity > 0;
    }
  }

  void _showSelector() {
    if (widget.product.isUnavailableForPurchase) return;

    setState(() {
      _quantity = 1;
      _showQuantitySelector = true;
    });
    widget.onQuantityChanged?.call(_quantity);
  }

  void _onQuantityChanged(int quantity) {
    if (widget.product.isUnavailableForPurchase) return;

    setState(() {
      _quantity = quantity;
      _showQuantitySelector = quantity > 0;
    });
    widget.onQuantityChanged?.call(_quantity);
  }

  @override
  Widget build(BuildContext context) {
    final darkerPrimaryColor = AppColors.darkerShade(widget.primaryColor);
    final isAvailableForPurchase = widget.product.isAvailableForPurchase;
    final availabilityLabel = AppStrings.productOutOfStock;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: NetworkImageWithPlaceholder(
                  imageUrl: widget.product.imageUrl,
                  width: double.infinity,
                  cacheWidth: 400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 8,
                left: 4,
                top: 0,
                bottom: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.bold16.copyWith(
                      color: AppColors.shopNameColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.priceText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.semiBold14.copyWith(
                      color: darkerPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        axisAlignment: -1,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child:
                        isAvailableForPurchase
                            ? _showQuantitySelector
                                ? QuantitySelector(
                                  key: const ValueKey('quantity-selector'),
                                  initialQuantity: _quantity,
                                  minQuantity: 0,
                                  color: widget.primaryColor,
                                  buttonSize: 28,
                                  iconSize: 18,
                                  valueWidth: 34,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  onChanged: _onQuantityChanged,
                                )
                                : AddButton(
                                  key: const ValueKey('add-button'),
                                  color: widget.primaryColor,
                                  onTap: _showSelector,
                                )
                            : OrderMetaChip(
                              key: const ValueKey('availability-badge'),
                              label: availabilityLabel,
                              backgroundColor: const Color(0xffFCE8E8),
                              foregroundColor: const Color(0xffD85B5B),
                              compact: false,
                              maxTextWidth: 120,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
