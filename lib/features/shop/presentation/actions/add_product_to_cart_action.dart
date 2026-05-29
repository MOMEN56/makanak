import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class AddProductToCartAction {
  const AddProductToCartAction._();

  static Future<AddProductToCartResult> run({
    required BuildContext context,
    required ProductModel product,
    required int quantity,
    required Color primaryColor,
    ShopModel? shopModel,
  }) async {
    final result = await context.read<CartCubit>().addProductSafely(
      CartViewArguments(
        product: product,
        quantity: quantity,
        primaryColor: primaryColor,
        shopModel: shopModel,
      ),
    );

    if (context.mounted && !result.wasAdded && result.message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xffD85B5B),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            content: Text(
              result.message!,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
    }

    return result;
  }
}
