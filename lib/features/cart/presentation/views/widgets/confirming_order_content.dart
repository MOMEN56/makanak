import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_state.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/shared/widgets/address_card_widget.dart';
import 'package:makanak/shared/widgets/add_address_button.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';
import 'package:makanak/shared/widgets/order_summary_card_widget.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class ConfirmingOrderContent extends StatelessWidget {
  const ConfirmingOrderContent({
    super.key,
    required this.state,
    required this.addressState,
    required this.primaryColor,
    required this.isLoading,
    required this.onChangeAddress,
    required this.onAddAddress,
  });

  final CartState state;
  final AddressState addressState;
  final Color primaryColor;
  final bool isLoading;
  final VoidCallback onChangeAddress;
  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    if (isLoading && addressState.addresses.isEmpty) {
      return CustomLoadingIndicator(color: primaryColor);
    }

    if (state.product == null) {
      return const StateMessage(message: AppStrings.cartEmpty);
    }

    if (addressState.addresses.isEmpty) {
      return Column(
        children: [
          const Expanded(
            child: StateMessage(message: AppStrings.noSavedAddresses),
          ),
          AddAddressButton(onTap: isLoading ? null : onAddAddress),
        ],
      );
    }

    final selectedAddressIndex =
        addressState.selectedAddressIndex < 0 ||
                addressState.selectedAddressIndex >=
                    addressState.addresses.length
            ? 0
            : addressState.selectedAddressIndex;

    final selectedAddress = addressState.addresses[selectedAddressIndex];

    return ListView(
      children: [
        AddressCard(
          address: selectedAddress,
          canChangeAddress: addressState.addresses.isNotEmpty,
          onChangeAddress: onChangeAddress,
          primaryColor: primaryColor,
        ),
        const Gap(16),
        AddAddressButton(onTap: isLoading ? null : onAddAddress),
        const Gap(16),
        OrderSummaryCard(
          itemsTotal: state.itemsSubtotal,
          shippingPrice: state.shippingPrice,
          orderTotal: state.orderTotal,
          primaryColor: primaryColor,
        ),
      ],
    );
  }
}
