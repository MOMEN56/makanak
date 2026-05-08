import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_state.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/core/utils/assets.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/actions/cart_route_arguments_builder.dart';
import 'package:makanak/features/cart/presentation/views/add_user_address_view.dart';
import 'package:makanak/features/cart/presentation/views/confirming_order_view.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_header_widget.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_item_card.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_indicator.dart';
import 'package:makanak/shared/widgets/custom_button.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class CartViewBody extends StatefulWidget {
  const CartViewBody({
    super.key,
    this.cartArguments,
    this.bottomContentPadding = 0,
    this.onBack,
  });

  final CartViewArguments? cartArguments;
  final double bottomContentPadding;
  final VoidCallback? onBack;

  @override
  State<CartViewBody> createState() => _CartViewBodyState();
}

class _CartViewBodyState extends State<CartViewBody> {
  @override
  void initState() {
    super.initState();
    final cartCubit = context.read<CartCubit>();
    cartCubit.initializeCart(widget.cartArguments);
    context.read<AddressCubit>().checkSavedAddresses();
  }

  void _goToNextStep(
    CartState cartState,
    AddressState addressState,
    Color primaryColor,
  ) {
    final product = cartState.product;
    if (product == null) return;

    final routeArguments = CartRouteArgumentsBuilder.fromState(
      state: cartState,
      primaryColor: primaryColor,
      fallback: widget.cartArguments,
    );

    Navigator.pushNamed(
      context,
      addressState.hasSavedAddress
          ? ConfirmingOrderView.routeName
          : AddUserAddressView.routeName,
      arguments: routeArguments,
    );
  }

  void _goBack() {
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }

    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.cartArguments?.primaryColor ??
        CartViewArguments.defaultPrimaryColor;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        return BlocBuilder<AddressCubit, AddressState>(
          builder: (context, addressState) {
            if (addressState is AddressLoading &&
                addressState.addresses.isEmpty) {
              return CustomLoadingIndicator(color: primaryColor);
            }

            final cartItems = cartState.items;

            return SafeArea(
              bottom: widget.bottomContentPadding == 0,
              child: Padding(
                padding: AppResponsive.all(context, AppSpacing.screenEdge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CartHeaderWidget(
                      primaryColor: primaryColor,
                      itemCount: cartState.itemCount,
                      onBack: _goBack,
                    ),
                    const Gap(20),
                    CartStepIndicator(
                      currentStep: 0,
                      primaryColor: primaryColor,
                      showAddressStep: !addressState.hasSavedAddress,
                    ),
                    const Gap(12),
                    Expanded(
                      child:
                          cartItems.isEmpty
                              ? Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 250,
                                      width: 250,
                                      child: Image.asset(
                                        Assets.assetsIconsEmptyCartIcon,
                                      ),
                                    ),
                                    const StateMessage(
                                      message: AppStrings.cartEmpty,
                                    ),
                                  ],
                                ),
                              )
                              : ListView(
                                children:
                                    cartItems.map((item) {
                                      final productId = item.product.id;

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: CartItemCard(
                                          product: item.product,
                                          quantity: item.quantity,
                                          primaryColor: primaryColor,
                                          onRemove:
                                              productId == null ||
                                                      productId.isEmpty
                                                  ? null
                                                  : () => context
                                                      .read<CartCubit>()
                                                      .removeItem(productId),
                                          onQuantityChanged:
                                              productId == null ||
                                                      productId.isEmpty
                                                  ? null
                                                  : (quantity) => context
                                                      .read<CartCubit>()
                                                      .updateQuantity(
                                                        productId,
                                                        quantity,
                                                      ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                    ),
                    if (cartItems.isNotEmpty) ...[
                      const Gap(12),
                      CustomButton(
                        hint: AppStrings.continueText,
                        color: primaryColor,
                        onTap:
                            () => _goToNextStep(
                              cartState,
                              addressState,
                              primaryColor,
                            ),
                        hasShadowEffect: false,
                      ),
                      SizedBox(height: widget.bottomContentPadding),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
