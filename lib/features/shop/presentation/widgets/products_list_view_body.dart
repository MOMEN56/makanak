import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
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
    return Padding(
      padding: const EdgeInsets.all(20),
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
                    color: AppColors.primaryDarkColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const Gap(30),
          SearchTextField(
            hintText: 'نفسك تجيب ايه؟',
            onChanged: (value) {},
          ),
          const Gap(24),
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                return switch (state) {
                  ProductsInitial() || ProductsLoading() =>
                    const CustomLoadingIndicator(),
                  ProductsSuccess(:final products) => products.isEmpty
                      ? const StateMessage(
                          message: 'لا توجد منتجات متاحة حاليا.',
                        )
                      : ProductsList(products: products),
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
