import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/presentation/views/product_details_view.dart';
import 'package:makanak/features/shop/presentation/widgets/product_card.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({
    super.key,
    required this.products,
    required this.primaryColor,
    required this.priceSort,
    required this.onPriceSortChanged,
  });

  final List<ProductModel> products;
  final Color primaryColor;
  final ProductPriceSort priceSort;
  final ValueChanged<ProductPriceSort> onPriceSortChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ProductPriceSort>(
              value: priceSort,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.searchFieldGrey,
              ),
              style: TextStyles.regular14.copyWith(
                color: AppColors.searchFieldGrey,
              ),
              onChanged: (value) {
                if (value == null) return;
                onPriceSortChanged(value);
              },
              items: const [
                DropdownMenuItem(
                  value: ProductPriceSort.none,
                  child: Text('الترتيب الافتراضي'),
                ),
                DropdownMenuItem(
                  value: ProductPriceSort.lowToHigh,
                  child: Text('السعر: من الأقل للأعلى'),
                ),
                DropdownMenuItem(
                  value: ProductPriceSort.highToLow,
                  child: Text('السعر: من الأعلى للأقل'),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final product = products[index];

              return ProductCard(
                product: product,
                primaryColor: primaryColor,
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 300),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 300,
                      ),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return ProductDetailsView(
                          product: product,
                          primaryColor: primaryColor,
                        );
                      },
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                  if (!context.mounted) return;
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onAdd: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}
