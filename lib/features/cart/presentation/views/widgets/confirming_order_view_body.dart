import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_state.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/actions/cart_route_arguments_builder.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/cart/presentation/views/submit_order_view.dart';
import 'package:makanak/shared/widgets/address_selector_sheet_widget.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_header_widget.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_indicator.dart';
import 'package:makanak/features/cart/presentation/views/widgets/confirming_order_content.dart';
import 'package:makanak/shared/views/add_address_view.dart';
import 'package:makanak/shared/widgets/custom_button.dart';

class ConfirmingOrderViewBody extends StatefulWidget {
  const ConfirmingOrderViewBody({
    super.key,
    this.cartArguments,
    this.showAddressStep = false,
  });

  final CartViewArguments? cartArguments;
  final bool showAddressStep;

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
    context.read<AddressCubit>().fetchAddresses();
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

  void _openAddressSelector(AddressState state, Color primaryColor) {
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
              context.read<AddressCubit>().selectAddress(index);
              Navigator.pop(bottomSheetContext);
            },
            onMainAddressSelected: (index) async {
              final addressCubit = context.read<AddressCubit>();
              final didUpdate = await addressCubit.setDefaultAddress(index);

              if (!bottomSheetContext.mounted) return didUpdate;

              final state = addressCubit.state;
              if (state is AddressError) {
                _showAddressError(state.message);
              }

              return didUpdate;
            },
          ),
    );
  }

  void _openAddAddressView() {
    Navigator.of(
      context,
    ).push(AddAddressView.route(addressCubit: context.read<AddressCubit>()));
  }

  void _goToSubmitOrder(AddressState addressState) {
    if (addressState.addresses.isEmpty) return;
    final selectedAddressIndex =
        addressState.selectedAddressIndex < 0 ||
                addressState.selectedAddressIndex >=
                    addressState.addresses.length
            ? 0
            : addressState.selectedAddressIndex;
    final selectedAddress = addressState.addresses[selectedAddressIndex];
    context.read<CartCubit>().createOrder(addressId: selectedAddress.id);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.cartArguments?.primaryColor ??
        CartViewArguments.defaultPrimaryColor;

    return BlocConsumer<CartCubit, CartState>(
      listenWhen: _shouldListenToCartChanges,
      buildWhen: _shouldRebuildConfirmingCart,
      listener: (context, state) {
        if (state is CartError) {
          _showAddressError(state.message);
        }

        if (state is CartOrderSubmitted) {
          Navigator.pushReplacementNamed(
            context,
            SubmitOrderView.routeName,
            arguments: CartRouteArgumentsBuilder.fromState(
              state: state,
              primaryColor: primaryColor,
              fallback: widget.cartArguments,
            ),
          );
        }
      },
      builder: (context, state) {
        return BlocConsumer<AddressCubit, AddressState>(
          listenWhen: _shouldListenToAddressChanges,
          buildWhen: _shouldRebuildConfirmingAddress,
          listener: (context, addressState) {
            if (addressState is AddressError) {
              final route = ModalRoute.of(context);
              if (route != null && !route.isCurrent) return;

              _showAddressError(addressState.message);
            }
          },
          builder: (context, addressState) {
            final isLoading =
                state is CartLoading || addressState is AddressLoading;

            return SafeArea(
              child: Padding(
                padding: AppResponsive.all(context, AppSpacing.screenEdge),
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
                      showAddressStep: widget.showAddressStep,
                    ),
                    const Gap(20),
                    Expanded(
                      child: ConfirmingOrderContent(
                        state: state,
                        addressState: addressState,
                        primaryColor: primaryColor,
                        isLoading: isLoading,
                        onChangeAddress:
                            () => _openAddressSelector(
                              addressState,
                              primaryColor,
                            ),
                        onAddAddress: _openAddAddressView,
                      ),
                    ),
                    const Gap(18),
                    CustomButton(
                      hint:
                          isLoading
                              ? AppStrings.confirmingOrder
                              : AppStrings.confirmOrder,
                      preventRapidTaps: true,
                      hasShadowEffect: true,
                      color: primaryColor,
                      onTap:
                          isLoading ||
                                  addressState.addresses.isEmpty ||
                                  state.product == null
                              ? null
                              : () => _goToSubmitOrder(addressState),
                    ),
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

bool _shouldListenToCartChanges(CartState previous, CartState current) {
  return previous != current &&
      (current is CartError || current is CartOrderSubmitted);
}

bool _shouldRebuildConfirmingCart(CartState previous, CartState current) {
  return previous.runtimeType != current.runtimeType ||
      previous.items != current.items ||
      previous.shippingPrice != current.shippingPrice;
}

bool _shouldListenToAddressChanges(
  AddressState previous,
  AddressState current,
) {
  return previous != current && current is AddressError;
}

bool _shouldRebuildConfirmingAddress(
  AddressState previous,
  AddressState current,
) {
  return previous.runtimeType != current.runtimeType ||
      previous.addresses != current.addresses ||
      previous.selectedAddressIndex != current.selectedAddressIndex;
}
