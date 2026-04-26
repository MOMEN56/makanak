import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_cubit.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_state.dart';
import 'package:makanak/features/shop/presentation/widgets/products_list.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';
import 'package:makanak/shared/widgets/search_text_field.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class ProductsListViewBody extends StatelessWidget {
  const ProductsListViewBody({super.key, required this.shopModel});

  final ShopModel shopModel;

  @override
  Widget build(BuildContext context) {
    final shopPrimaryColor = AppColors.fromHex(shopModel.primaryColor);

    return Padding(
      padding: AppResponsive.all(context, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(shopModel.imageUrl),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  shopModel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.bold16.copyWith(
                    color: AppColors.darkerShade(shopPrimaryColor),
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const Gap(30),
          SearchTextField(
            hintText:
                '\u0646\u0641\u0633\u0643 \u062A\u062C\u064A\u0628 \u0627\u064A\u0647\u061F',
            onChanged: (value) {},
          ),
          const Gap(24),
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                return switch (state) {
                  ProductsInitial() ||
                  ProductsLoading() => const CustomLoadingIndicator(),
                  ProductsSuccess(:final products) =>
                    products.isEmpty
                        ? const StateMessage(
                          message:
                              '\u0644\u0627 \u062A\u0648\u062C\u062F \u0645\u0646\u062A\u062C\u0627\u062A \u0645\u062A\u0627\u062D\u0629 \u062D\u0627\u0644\u064A\u0627.',
                        )
                        : ProductsList(
                          products: products,
                          primaryColor: shopPrimaryColor,
                        ),
                  ProductsFailure(:final message) => StateMessage(
                    message: message,
                    onRetry: () {
                      context.read<ProductsCubit>().fetchProducts(
                        shopModel.id ?? '',
                      );
                    },
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
