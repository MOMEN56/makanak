import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_cubit.dart';
import 'package:makanak/features/shop/presentation/views/widgets/products_view_body.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/keyboard_dismiss_on_tap.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key, required this.shopModel});

  static const String routeName = 'products_list';

  final ShopModel shopModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductsCubit>()..fetchProducts(shopModel.id ?? ''),
      child: Scaffold(
        body: KeyboardDismissOnTap(
          child: ProductsViewBody(shopModel: shopModel),
        ),
      ),
    );
  }
}
