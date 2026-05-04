import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/cart/presentation/views/submit_order_view.dart';
import 'package:makanak/features/cart/presentation/views/widgets/address_selector_sheet_widget.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_header_widget.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_indicator.dart';
import 'package:makanak/features/cart/presentation/views/widgets/confirming_order_content.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class ConfirmingOrderViewBody extends StatefulWidget {
  const ConfirmingOrderViewBody({super.key, this.cartArguments});

  final CartViewArguments? cartArguments;

  @override
  State<ConfirmingOrderViewBody> createState() =>
      _ConfirmingOrderViewBodyState();
}

class _ConfirmingOrderViewBodyState extends State<ConfirmingOrderViewBody> {
  @override
  void initState() {
    super.initState();
    final cartCubit = context.read<CartCubit>();
    cartCubit.initializeCart(widget.cartArguments);
    cartCubit.fetchAddresses();
  }

  void _showAddressError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xffD85B5B),
        ),
      );
  }

  void _goBackToPreviousStep() {
    Navigator.maybePop(context);
  }

  void _openAddressSelector(CartState state, Color primaryColor) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (bottomSheetContext) => AddressSelectorSheet(
            addresses: state.addresses,
            selectedIndex: state.selectedAddressIndex,
            primaryColor: primaryColor,
            onAddressSelected: (index) {
              context.read<CartCubit>().selectAddress(index);
              Navigator.pop(bottomSheetContext);
            },
            onMainAddressSelected: (index) async {
              final cartCubit = context.read<CartCubit>();
              await cartCubit.setDefaultAddress(index);
            },
          ),
    );
  }

  void _goToSubmitOrder() {
    context.read<CartCubit>().createOrder();
  }

  CartViewArguments? _routeArguments(CartState state, Color primaryColor) {
    final product = state.product ?? widget.cartArguments?.product;
    if (product == null) return widget.cartArguments;

    return CartViewArguments(
      product: product,
      quantity: state.quantity,
      primaryColor: primaryColor,
      shopModel: widget.cartArguments?.shopModel,
      shippingPrice: state.shippingPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.cartArguments?.primaryColor ??
        CartViewArguments.defaultPrimaryColor;

    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartError) {
          _showAddressError(state.message);
        }

        if (state is CartOrderSubmitted) {
          Navigator.pushReplacementNamed(
            context,
            SubmitOrderView.routeName,
            arguments: _routeArguments(state, primaryColor),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CartLoading;

        return SafeArea(
          child: Padding(
            padding: AppResponsive.all(context, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CartStepHeaderWidget(
                  title: AppStrings.confirmOrder,
                  onBack: _goBackToPreviousStep,
                  primaryColor: primaryColor,
                ),
                const Gap(20),
                CartStepIndicator(
                  currentStep: 2,
                  primaryColor: primaryColor,
                  showAddressStep: !state.hasSavedAddress,
                ),
                const Gap(20),
                Expanded(
                  child: ConfirmingOrderContent(
                    state: state,
                    primaryColor: primaryColor,
                    isLoading: isLoading,
                    onRetry: _goBackToPreviousStep,
                    onChangeAddress:
                        () => _openAddressSelector(state, primaryColor),
                  ),
                ),
                const Gap(18),
                CustomButton(
                  hint:
                      isLoading
                          ? AppStrings.confirmingOrder
                          : AppStrings.confirmOrder,
                  hasShadowEffect: true,
                  color: primaryColor,
                  onTap:
                      isLoading ||
                              state.addresses.isEmpty ||
                              state.product == null
                          ? null
                          : _goToSubmitOrder,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
