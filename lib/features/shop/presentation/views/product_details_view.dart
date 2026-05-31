import 'package:flutter/material.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/shop/domain/entities/product_availability_extension.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/presentation/views/widgets/product_details_view_body.dart';
import 'package:makanak/shared/widgets/state_message.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class ProductDetailsView extends StatelessWidget {
  const ProductDetailsView({
    super.key,
    required this.product,
    required this.primaryColor,
    this.shopModel,
    this.initialQuantity = 1,
    this.returnToCartTab = false,
  });

  static const String routeName = 'product_details';

  final ProductModel product;
  final Color primaryColor;
  final ShopModel? shopModel;
  final int initialQuantity;
  final bool returnToCartTab;

  @override
  Widget build(BuildContext context) {
    if (product.isHiddenFromCustomers) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: StateMessage(message: AppStrings.productDataUnavailable),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: ProductDetailsViewBody(
        product: product,
        primaryColor: primaryColor,
        shopModel: shopModel,
        initialQuantity: initialQuantity,
        returnToCartTab: returnToCartTab,
      ),
    );
  }
}
