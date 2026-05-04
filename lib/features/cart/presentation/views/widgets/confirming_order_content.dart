import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/cart/presentation/views/widgets/address_card_widget.dart';
import 'package:makanak/features/cart/presentation/views/widgets/order_summary_card_widget.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';
import 'package:makanak/shared/widgets/state_message.dart';

class ConfirmingOrderContent extends StatelessWidget {
  const ConfirmingOrderContent({
    super.key,
    required this.state,
    required this.primaryColor,
    required this.isLoading,
    required this.onRetry,
    required this.onChangeAddress,
  });

  final CartState state;
  final Color primaryColor;
  final bool isLoading;
  final VoidCallback onRetry;
  final VoidCallback onChangeAddress;

  @override
  Widget build(BuildContext context) {
    if (isLoading && state.addresses.isEmpty) {
      return CustomLoadingIndicator(color: primaryColor);
    }

    if (state.product == null) {
      return const StateMessage(message: AppStrings.cartEmpty);
    }

    if (state.addresses.isEmpty) {
      return StateMessage(
        message: AppStrings.noSavedAddresses,
        onRetry: onRetry,
      );
    }

    final selectedAddressIndex =
        state.selectedAddressIndex < 0 ||
                state.selectedAddressIndex >= state.addresses.length
            ? 0
            : state.selectedAddressIndex;

    final selectedAddress = state.addresses[selectedAddressIndex];

    return ListView(
      children: [
        AddressCard(
          address: selectedAddress,
          canChangeAddress: state.addresses.length > 1,
          onChangeAddress: onChangeAddress,
          primaryColor: primaryColor,
        ),
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
