import 'package:flutter/material.dart';
import 'package:makanak/features/order_history/presentation/views/widgets/order_meta_chip.dart';
import 'package:makanak/features/shop/presentation/views/widgets/add_button.dart';
import 'package:makanak/shared/widgets/quantity_selector.dart';

class ProductCardActionSwitcher extends StatelessWidget {
  const ProductCardActionSwitcher({
    super.key,
    required this.canPurchase,
    required this.showQuantitySelector,
    required this.quantity,
    required this.primaryColor,
    required this.statusLabel,
    required this.statusBackgroundColor,
    required this.statusForegroundColor,
    this.onAddTap,
    this.onQuantityChanged,
  });

  final bool canPurchase;
  final bool showQuantitySelector;
  final int quantity;
  final Color primaryColor;
  final String statusLabel;
  final Color statusBackgroundColor;
  final Color statusForegroundColor;
  final VoidCallback? onAddTap;
  final ValueChanged<int>? onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
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
          canPurchase
              ? showQuantitySelector
                  ? QuantitySelector(
                    key: const ValueKey('quantity-selector'),
                    initialQuantity: quantity,
                    minQuantity: 0,
                    color: primaryColor,
                    buttonSize: 28,
                    iconSize: 18,
                    valueWidth: 34,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    onChanged: onQuantityChanged,
                  )
                  : AddButton(
                    key: const ValueKey('add-button'),
                    color: primaryColor,
                    onTap: onAddTap,
                  )
              : OrderMetaChip(
                key: const ValueKey('availability-badge'),
                label: statusLabel,
                backgroundColor: statusBackgroundColor,
                foregroundColor: statusForegroundColor,
                compact: false,
                maxTextWidth: 120,
              ),
    );
  }
}
