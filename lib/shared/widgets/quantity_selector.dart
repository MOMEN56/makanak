import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class QuantitySelector extends StatefulWidget {
  const QuantitySelector({
    super.key,
    this.initialQuantity = 1,
    this.minQuantity = 1,
    this.onChanged,
    this.color,
    this.buttonSize = 36,
    this.iconSize = 20,
    this.valueWidth = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  });

  final int initialQuantity;
  final int minQuantity;
  final ValueChanged<int>? onChanged;
  final Color? color;
  final double buttonSize;
  final double iconSize;
  final double valueWidth;
  final EdgeInsetsGeometry padding;

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = _clampedQuantity(widget.initialQuantity);
  }

  @override
  void didUpdateWidget(covariant QuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuantity != oldWidget.initialQuantity ||
        widget.minQuantity != oldWidget.minQuantity) {
      quantity = _clampedQuantity(widget.initialQuantity);
    }
  }

  int _clampedQuantity(int value) {
    return value < widget.minQuantity ? widget.minQuantity : value;
  }

  void _updateQuantity(int value) {
    final updatedQuantity = _clampedQuantity(value);
    setState(() => quantity = updatedQuantity);
    widget.onChanged?.call(quantity);
  }

  void _increment() {
    _updateQuantity(quantity + 1);
  }

  void _decrement() {
    if (quantity == widget.minQuantity) return;
    _updateQuantity(quantity - 1);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = widget.color ?? AppColors.primaryColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: widget.padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _QuantityButton(
              icon: Icons.remove,
              onTap: _decrement,
              color: resolvedColor,
              size: widget.buttonSize,
              iconSize: widget.iconSize,
            ),
            SizedBox(
              width: widget.valueWidth,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: TextStyles.bold16.copyWith(color: Colors.black),
              ),
            ),
            _QuantityButton(
              icon: Icons.add,
              onTap: _increment,
              color: resolvedColor,
              size: widget.buttonSize,
              iconSize: widget.iconSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: size,
          width: size,
          child: Icon(icon, color: AppColors.white, size: iconSize),
        ),
      ),
    );
  }
}
