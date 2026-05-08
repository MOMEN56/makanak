import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_state.dart';
import 'package:makanak/core/utils/address_form_controller.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/actions/cart_route_arguments_builder.dart';
import 'package:makanak/features/cart/presentation/views/confirming_order_view.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_header_widget.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_indicator.dart';
import 'package:makanak/shared/widgets/address_form_fields.dart';
import 'package:makanak/shared/widgets/custom_button.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';

class AddUserAddressViewBody extends StatefulWidget {
  const AddUserAddressViewBody({
    super.key,
    this.cartArguments,
    this.returnOnSave = false,
  });

  final CartViewArguments? cartArguments;
  final bool returnOnSave;

  @override
  State<AddUserAddressViewBody> createState() => _AddUserAddressViewBodyState();
}

class _AddUserAddressViewBodyState extends State<AddUserAddressViewBody> {
  late final CartCubit _cartCubit;
  late final AddressCubit _addressCubit;
  late final AddressFormController _addressFormController;
  bool _submittedAddress = false;

  @override
  void initState() {
    super.initState();
    _cartCubit = context.read<CartCubit>();
    _addressCubit = context.read<AddressCubit>();
    _cartCubit.initializeCart(widget.cartArguments);
    final draft = _addressCubit.state.draft;
    _addressFormController = AddressFormController(
      addressName: draft.addressName,
      phone: draft.phone,
      floor: draft.floor,
      building: draft.building,
      apartment: draft.apartment,
      notes: draft.notes,
    );
  }

  @override
  void dispose() {
    _saveDraft();
    _addressFormController.dispose();
    super.dispose();
  }

  void _saveDraft() {
    _addressFormController.saveDraft(_addressCubit.saveDraft);
  }

  Future<void> _goToConfirmingOrder() async {
    if (!_addressFormController.validate()) return;

    _saveDraft();
    _submittedAddress = true;
    await _addressFormController.saveAddress(_addressCubit.saveAddress);
    if (!mounted) return;
  }

  void _showAddressSaveError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xffD85B5B),
        ),
      );
  }

  void _goToCart() {
    _saveDraft();
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.cartArguments?.primaryColor ??
        CartViewArguments.defaultPrimaryColor;

    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        if (state is AddressError) {
          _submittedAddress = false;
          _showAddressSaveError(state.message);
        }

        if (state is AddressChecked &&
            state.hasSavedAddress &&
            !_submittedAddress) {
          Navigator.pushReplacementNamed(
            context,
            ConfirmingOrderView.routeName,
            arguments: CartRouteArgumentsBuilder.fromState(
                state: _cartCubit.state,
                primaryColor: primaryColor,
                fallback: widget.cartArguments,
            ),
          );
          return;
        }

        if (_submittedAddress && state is AddressesLoaded) {
          _submittedAddress = false;
          if (widget.returnOnSave) {
            Navigator.pop(context);
            return;
          }
          Navigator.pushNamed(
            context,
            ConfirmingOrderView.routeName,
            arguments: CartRouteArgumentsBuilder.fromState(
                state: _cartCubit.state,
                primaryColor: primaryColor,
              fallback: widget.cartArguments,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSavingAddress = state is AddressLoading;

        if (isSavingAddress && state.addresses.isEmpty && !_submittedAddress) {
          return SafeArea(child: CustomLoadingIndicator(color: primaryColor));
        }

        return SafeArea(
          child: Padding(
            padding: AppResponsive.all(context, AppSpacing.screenEdge),
            child: Form(
              key: _addressFormController.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CartStepHeaderWidget(
                    title: AppStrings.addAddress,
                    onBack: _goToCart,
                    primaryColor: primaryColor,
                  ),
                  const Gap(20),
                  CartStepIndicator(currentStep: 1, primaryColor: primaryColor),
                  const Gap(8),
                  Expanded(
                    child: ListView(
                      children: [
                        const Gap(8),
                        AddressFormFields(
                          addressFormController: _addressFormController,
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const Gap(18),
                  CustomButton(
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                    hint:
                        isSavingAddress
                            ? AppStrings.saving
                            : AppStrings.saveAddressAndContinue,
                    onTap: isSavingAddress ? null : _goToConfirmingOrder,
                    hasShadowEffect: false,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
