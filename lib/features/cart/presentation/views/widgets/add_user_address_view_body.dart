import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/address_form_validator.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_responsive.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_state.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/views/confirming_order_view.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_header_widget.dart';
import 'package:makanak/features/cart/presentation/views/widgets/cart_step_indicator.dart';
import 'package:makanak/features/cart/presentation/views/widgets/user_address__text_field_widget.dart';
import 'package:makanak/shared/widgets/custom_button.dart';
import 'package:makanak/shared/widgets/custom_loading_indicator.dart';

class AddUserAddressViewBody extends StatefulWidget {
  const AddUserAddressViewBody({super.key, this.cartArguments});

  final CartViewArguments? cartArguments;

  @override
  State<AddUserAddressViewBody> createState() => _AddUserAddressViewBodyState();
}

class _AddUserAddressViewBodyState extends State<AddUserAddressViewBody> {
  final formKey = GlobalKey<FormState>();
  late final CartCubit _cartCubit;
  late final TextEditingController _addressNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _floorController;
  late final TextEditingController _buildingController;
  late final TextEditingController _apartmentController;
  late final TextEditingController _notesController;
  bool _submittedAddress = false;

  @override
  void initState() {
    super.initState();
    _cartCubit = context.read<CartCubit>();
    _cartCubit.initializeCart(widget.cartArguments);
    final draft = _cartCubit.state.draft;
    _addressNameController = TextEditingController(text: draft.addressName);
    _phoneController = TextEditingController(text: draft.phone);
    _floorController = TextEditingController(text: draft.floor);
    _buildingController = TextEditingController(text: draft.building);
    _apartmentController = TextEditingController(text: draft.apartment);
    _notesController = TextEditingController(text: draft.notes);
  }

  @override
  void dispose() {
    _saveDraft();
    _addressNameController.dispose();
    _phoneController.dispose();
    _floorController.dispose();
    _buildingController.dispose();
    _apartmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveDraft() {
    _cartCubit.saveDraft(
      addressName: _addressNameController.text,
      phone: _phoneController.text,
      floor: _floorController.text,
      building: _buildingController.text,
      apartment: _apartmentController.text,
      notes: _notesController.text,
    );
  }

  Future<void> _goToConfirmingOrder() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    _saveDraft();
    _submittedAddress = true;
    await _cartCubit.saveAddress(
      street: _addressNameController.text,
      floor: _floorController.text,
      building: _buildingController.text,
      apartmentNumber: _apartmentController.text,
      notes: _notesController.text,
      phoneNumber: AddressFormValidator.normalizeDigits(_phoneController.text),
    );
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
          _submittedAddress = false;
          _showAddressSaveError(state.message);
        }

        if (state is CartAddressChecked &&
            state.hasSavedAddress &&
            !_submittedAddress) {
          Navigator.pushReplacementNamed(
            context,
            ConfirmingOrderView.routeName,
            arguments: _routeArguments(state, primaryColor),
          );
          return;
        }

        if (_submittedAddress && state is CartAddressesLoaded) {
          _submittedAddress = false;
          Navigator.pushNamed(
            context,
            ConfirmingOrderView.routeName,
            arguments: _routeArguments(state, primaryColor),
          );
        }
      },
      builder: (context, state) {
        final isSavingAddress = state is CartLoading;

        if (isSavingAddress && state.addresses.isEmpty && !_submittedAddress) {
          return SafeArea(child: CustomLoadingIndicator(color: primaryColor));
        }

        return SafeArea(
          child: Padding(
            padding: AppResponsive.all(context, 20),
            child: Form(
              key: formKey,
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
                        UserAddressTextField(
                          controller: _addressNameController,
                          hint: AppStrings.addressNameHint,
                          label: AppStrings.addressName,
                          icon: Icons.bookmark_border_rounded,
                          primaryColor: primaryColor,
                          validator:
                              (value) => AddressFormValidator.requiredMaxWords(
                                value,
                                maxWords: 50,
                                fieldName: AppStrings.street,
                              ),
                        ),
                        const Gap(14),
                        UserAddressTextField(
                          controller: _phoneController,
                          hint: '01xxxxxxxxx',
                          label: AppStrings.phoneNumber,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          primaryColor: primaryColor,
                          validator: AddressFormValidator.phoneNumber,
                        ),
                        const Gap(14),
                        Row(
                          children: [
                            Expanded(
                              child: UserAddressTextField(
                                controller: _floorController,
                                hint: AppStrings.floor,
                                icon: Icons.stairs_outlined,
                                keyboardType: TextInputType.number,
                                primaryColor: primaryColor,
                                validator:
                                    (value) =>
                                        AddressFormValidator.requiredMaxWords(
                                          value,
                                          maxWords: 10,
                                          fieldName: AppStrings.floor,
                                        ),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: UserAddressTextField(
                                controller: _buildingController,
                                hint: AppStrings.buildingNumber,
                                icon: Icons.apartment_rounded,
                                keyboardType: TextInputType.number,
                                primaryColor: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Gap(14),
                        UserAddressTextField(
                          controller: _apartmentController,
                          hint: '5',
                          label: AppStrings.apartmentNumber,
                          icon: Icons.door_front_door_outlined,
                          keyboardType: TextInputType.number,
                          primaryColor: primaryColor,
                          validator:
                              (value) => AddressFormValidator.requiredMaxWords(
                                value,
                                maxWords: 10,
                                fieldName: AppStrings.apartmentNumber,
                              ),
                        ),
                        const Gap(14),
                        UserAddressTextField(
                          controller: _notesController,
                          hint: AppStrings.deliveryNotesHint,
                          label: AppStrings.notes,
                          icon: Icons.notes_outlined,
                          maxLines: 3,
                          isRequired: false,
                          primaryColor: primaryColor,
                          validator:
                              (value) => AddressFormValidator.optionalMaxWords(
                                value,
                                maxWords: 100,
                                fieldName: AppStrings.notes,
                              ),
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
