import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_state.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/features/profile/presentation/views/widgets/empty_addresses.dart';
import 'package:makanak/shared/views/add_address_view.dart';
import 'package:makanak/shared/widgets/add_address_button.dart';
import 'package:makanak/shared/widgets/address_card_widget.dart';
import 'package:makanak/shared/widgets/address_selector_sheet_widget.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';

class ProfileAddressesSection extends StatelessWidget {
  const ProfileAddressesSection({super.key, required this.onError});

  final ValueChanged<String> onError;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressCubit, AddressState>(
      listenWhen: (previous, current) => current is AddressError,
      listener: (context, state) {
        if (state is! AddressError) return;

        final route = ModalRoute.of(context);
        if (route != null && !route.isCurrent) return;

        onError(state.message);
      },
      buildWhen:
          (previous, current) =>
              previous.addresses != current.addresses ||
              previous.selectedAddressIndex != current.selectedAddressIndex ||
              previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        final isLoading = state is AddressLoading;

        if (isLoading && state.addresses.isEmpty) {
          return const CustomLoadingIndicator();
        }

        if (state.addresses.isEmpty) {
          return EmptyAddresses(
            onAddAddress: isLoading ? null : () => _openAddAddressView(context),
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
              canChangeAddress: state.addresses.isNotEmpty,
              onChangeAddress: () => _openAddressSelector(context, state),
            ),
            const Gap(14),
            AddAddressButton(
              onTap: isLoading ? null : () => _openAddAddressView(context),
            ),
          ],
        );
      },
    );
  }

  void _openAddressSelector(BuildContext context, AddressState state) {
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
            primaryColor: AppColors.primaryColor,
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
                onError(state.message);
              }

              return didUpdate;
            },
          ),
    );
  }

  void _openAddAddressView(BuildContext context) {
    Navigator.of(
      context,
    ).push(AddAddressView.route(addressCubit: context.read<AddressCubit>()));
  }
}
