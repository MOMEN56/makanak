import 'package:flutter/material.dart';
import 'package:makanak/core/utils/assets.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/presentation/views/product_details_view.dart';
import 'package:makanak/features/shop/presentation/widgets/product_card.dart';
import 'package:makanak/shared/widgets/message_emoji_widget.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({
    super.key,
    required this.products,
    required this.primaryColor,
  });

  final List<ProductModel> products;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const MessageEmojiWidget(
        image: Assets.assetsIconsIdkEmoji,
        text:
            '\u0644\u0627 \u062a\u0648\u062c\u062f \u0645\u0646\u062a\u062c\u0627\u062a \u0645\u062a\u0627\u062d\u0629 \u062d\u0627\u0644\u064a\u0627.',
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                reverseTransitionDuration: const Duration(milliseconds: 300),
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
    );
  }
}
