import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';

class QuantitySelector extends StatefulWidget {
  const QuantitySelector({
    super.key,
    this.initialQuantity = 1,
    this.minQuantity = 1,
    this.onChanged,
  });

  final int initialQuantity;
  final int minQuantity;
  final ValueChanged<int>? onChanged;

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity =
        widget.initialQuantity < widget.minQuantity
            ? widget.minQuantity
            : widget.initialQuantity;
  }

  void _updateQuantity(int value) {
    setState(() => quantity = value);
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _QuantityButton(icon: Icons.remove, onTap: _decrement),
            SizedBox(
              width: 56,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: TextStyles.bold16.copyWith(color: Colors.black),
              ),
            ),
            _QuantityButton(icon: Icons.add, onTap: _increment),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: 36,
          width: 36,
          child: Icon(icon, color: AppColors.white, size: 20),
        ),
      ),
    );
  }
}
