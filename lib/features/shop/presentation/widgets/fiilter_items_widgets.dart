import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';

class FilterItemsWidgets extends StatelessWidget {
  const FilterItemsWidgets({
    super.key,
    required this.priceSort,
    required this.onPriceSortChanged,
  });

  final ProductPriceSort priceSort;
  final ValueChanged<ProductPriceSort> onPriceSortChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: PopupMenuButton<ProductPriceSort>(
        initialValue: priceSort,
        tooltip: '\u0641\u0644\u062a\u0631',
        color: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        offset: const Offset(0, 8),
        onSelected: onPriceSortChanged,
        itemBuilder: (context) {
          return _sortItems.map((item) {
            final isSelected = item.value == priceSort;

            return PopupMenuItem<ProductPriceSort>(
              value: item.value,
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_rounded
                        : Icons.filter_list_rounded,
                    size: 18,
                    color: AppColors.searchFieldGrey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.label,
                    style: TextStyles.semiBold14.copyWith(
                      color: AppColors.shopNameColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.searchFieldBackground,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: const Center(
            child: Icon(Icons.tune_rounded, color: AppColors.searchFieldGrey),
          ),
        ),
      ),
    );
  }
}

class _PriceSortItem {
  const _PriceSortItem({required this.value, required this.label});

  final ProductPriceSort value;
  final String label;
}

const _sortItems = [
  _PriceSortItem(
    value: ProductPriceSort.none,
    label:
        '\u0627\u0644\u062a\u0631\u062a\u064a\u0628 \u0627\u0644\u0627\u0641\u062a\u0631\u0627\u0636\u064a',
  ),
  _PriceSortItem(
    value: ProductPriceSort.lowToHigh,
    label:
        '\u0627\u0644\u0633\u0639\u0631: \u0645\u0646 \u0627\u0644\u0623\u0642\u0644 \u0644\u0644\u0623\u0639\u0644\u0649',
  ),
  _PriceSortItem(
    value: ProductPriceSort.highToLow,
    label:
        '\u0627\u0644\u0633\u0639\u0631: \u0645\u0646 \u0627\u0644\u0623\u0639\u0644\u0649 \u0644\u0644\u0623\u0642\u0644',
  ),
];
