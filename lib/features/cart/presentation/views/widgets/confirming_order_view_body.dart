import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_state.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/actions/cart_route_arguments_builder.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/cart/presentation/manager/checkout_cubit/checkout_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/checkout_cubit/checkout_state.dart';
import 'package:makanak/features/cart/presentation/views/submit_order_view.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_header_widget.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_indicator.dart';
import 'package:makanak/features/cart/presentation/views/widgets/confirming_order_content.dart';
import 'package:makanak/shared/views/add_address_view.dart';
import 'package:makanak/shared/views/no_internet_view.dart';
import 'package:makanak/shared/widgets/address_selector_sheet_widget.dart';
import 'package:makanak/shared/widgets/custom_button.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class ConfirmingOrderViewBody extends StatefulWidget {
  const ConfirmingOrderViewBody({
    super.key,
    this.cartArguments,
    this.bottomContentPadding = 0,
    this.showAddressStep = false,
    this.onBack,
    this.onOrderSubmitted,
  });

  final CartViewArguments? cartArguments;
  final double bottomContentPadding;
  final bool showAddressStep;
  final VoidCallback? onBack;
  final ValueChanged<CartViewArguments?>? onOrderSubmitted;

  @override
  State<ConfirmingOrderViewBody> createState() =>
      _ConfirmingOrderViewBodyState();
}

class _ConfirmingOrderViewBodyState extends State<ConfirmingOrderViewBody> {
  late final CheckoutCubit _checkoutCubit;

  @override
  void initState() {
    super.initState();
    _checkoutCubit = getIt<CheckoutCubit>();
    final cartCubit = context.read<CartCubit>();
    cartCubit.initializeCart(widget.cartArguments);
    unawaited(
      cartCubit.refreshCartAvailability(shopId: widget.cartArguments?.shopId),
    );
    context.read<AddressCubit>().fetchAddresses();
  }

  @override
  void dispose() {
    _checkoutCubit.close();
    super.dispose();
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
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }

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

  void _goToSubmitOrder(AddressState addressState, CartState cartState) {
    if (addressState.addresses.isEmpty) return;

    final selectedAddressIndex =
        addressState.selectedAddressIndex < 0 ||
                addressState.selectedAddressIndex >=
                    addressState.addresses.length
            ? 0
            : addressState.selectedAddressIndex;
    final selectedAddress = addressState.addresses[selectedAddressIndex];
    _checkoutCubit.createOrder(
      addressId: selectedAddress.id,
      cartItems: cartState.items,
      fallbackShippingPrice: cartState.shippingPrice,
    );
  }

  void _retryAddresses() {
    context.read<AddressCubit>().fetchAddresses(forceRefresh: true);
  }

  Future<void> _handleCheckoutFailure(CheckoutFailure state) async {
    final syncedItems = state.syncedItems;
    if (syncedItems != null) {
      await context.read<CartCubit>().applySyncedItems(
        items: syncedItems,
        shopId: state.syncedShopId,
      );
      if (!context.mounted) return;
    }

    _showAddressError(state.message);
  }

  Future<void> _handleCheckoutSubmitted(
    CheckoutSubmitted state,
    Color primaryColor,
  ) async {
    await context.read<CartCubit>().clearItemsForShop(
      shopId: state.shopId,
      shippingPrice: state.shippingPrice,
    );
    if (!context.mounted) return;

    _handleOrderSubmitted(state, primaryColor);
  }

  void _handleOrderSubmitted(CheckoutSubmitted state, Color primaryColor) {
    final routeArguments = CartRouteArgumentsBuilder.fromState(
      state: context.read<CartCubit>().state,
      primaryColor: primaryColor,
      fallback: widget.cartArguments,
      shippingPriceOverride: state.shippingPrice,
    );

    final onOrderSubmitted = widget.onOrderSubmitted;
    if (onOrderSubmitted != null) {
      onOrderSubmitted(routeArguments);
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      SubmitOrderView.routeName,
      arguments: routeArguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.cartArguments?.primaryColor ??
        CartViewArguments.defaultPrimaryColor;

    return BlocProvider<CheckoutCubit>.value(
      value: _checkoutCubit,
      child: BlocBuilder<CartCubit, CartState>(
        buildWhen: _shouldRebuildConfirmingCart,
        builder: (context, cartState) {
          return BlocConsumer<CheckoutCubit, CheckoutState>(
            listenWhen: _shouldListenToCheckoutChanges,
            buildWhen: _shouldRebuildCheckoutState,
            listener: (context, checkoutState) async {
              if (checkoutState is CheckoutFailure) {
                await _handleCheckoutFailure(checkoutState);
                return;
              }

              if (checkoutState is CheckoutSubmitted) {
                await _handleCheckoutSubmitted(checkoutState, primaryColor);
              }
            },
            builder: (context, checkoutState) {
              return BlocConsumer<AddressCubit, AddressState>(
                listenWhen: _shouldListenToAddressChanges,
                buildWhen: _shouldRebuildConfirmingAddress,
                listener: (context, addressState) {
                  if (addressState is AddressError) {
                    if (addressState.addresses.isEmpty) {
                      return;
                    }

                    final route = ModalRoute.of(context);
                    if (route != null && !route.isCurrent) return;

                    _showAddressError(addressState.message);
                  }
                },
                builder: (context, addressState) {
                  final isLoading =
                      checkoutState is CheckoutLoading ||
                      addressState is AddressLoading;

                  if (cartState.product == null) {
                    return const SafeArea(
                      child: StateMessage(message: AppStrings.cartEmpty),
                    );
                  }

                  if (addressState is AddressError &&
                      addressState.addresses.isEmpty) {
                    return addressState.isNetworkFailure
                        ? NoInternetView(onRetry: _retryAddresses)
                        : SafeArea(
                          child: StateMessage(
                            message: addressState.message,
                            onRetry: _retryAddresses,
                          ),
                        );
                  }

                  return SafeArea(
                    bottom: widget.bottomContentPadding == 0,
                    child: Padding(
                      padding: AppResponsive.all(
                        context,
                        AppSpacing.screenEdge,
                      ),
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
                              state: cartState,
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
                                        cartState.product == null
                                    ? null
                                    : () => _goToSubmitOrder(
                                      addressState,
                                      cartState,
                                    ),
                          ),
                          SizedBox(height: widget.bottomContentPadding),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

bool _shouldListenToCheckoutChanges(
  CheckoutState previous,
  CheckoutState current,
) {
  return previous != current &&
      (current is CheckoutFailure || current is CheckoutSubmitted);
}

bool _shouldRebuildConfirmingCart(CartState previous, CartState current) {
  return previous.runtimeType != current.runtimeType ||
      previous.items != current.items ||
      previous.shippingPrice != current.shippingPrice;
}

bool _shouldRebuildCheckoutState(
  CheckoutState previous,
  CheckoutState current,
) {
  return previous is CheckoutLoading ||
      current is CheckoutLoading ||
      previous.runtimeType != current.runtimeType;
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
