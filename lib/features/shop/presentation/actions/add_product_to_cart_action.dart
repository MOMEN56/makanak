import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';

class AddProductToCartAction {
  const AddProductToCartAction._();

  static void run({
    required BuildContext context,
    required ProductModel product,
    required int quantity,
    required Color primaryColor,
    ShopModel? shopModel,
  }) {
    context.read<CartCubit>().addProduct(
      CartViewArguments(
        product: product,
        quantity: quantity,
        primaryColor: primaryColor,
        shopModel: shopModel,
      ),
    );
  }
}
