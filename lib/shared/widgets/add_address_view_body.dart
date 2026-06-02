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
import 'package:makanak/core/utils/app_text_styles.dart';
import 'package:makanak/shared/widgets/add_address_button.dart';
import 'package:makanak/shared/widgets/address_form_fields.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';

class AddAddressViewBody extends StatefulWidget {
  const AddAddressViewBody({super.key});

  @override
  State<AddAddressViewBody> createState() => _AddAddressViewBodyState();
}

class _AddAddressViewBodyState extends State<AddAddressViewBody> {
  late final AddressCubit _addressCubit;
  late final AddressFormController _addressFormController;
  bool _submittedAddress = false;

  @override
  void initState() {
    super.initState();
    _addressCubit = context.read<AddressCubit>();
    _addressFormController = AddressFormController();
  }

  @override
  void dispose() {
    _addressFormController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_addressFormController.validate()) return;

    _submittedAddress = true;
    await _addressFormController.saveAddress(_addressCubit.saveAddress);
  }

  void _showError(AddressError state) {
    if (state.isNetworkFailure) {
      AppSnackBar.showNetwork(context: context, message: state.message);
      return;
    }

    AppSnackBar.show(
      context: context,
      message: state.message,
      badgeText: MaterialLocalizations.of(context).closeButtonTooltip,
      backgroundColor: const Color(0xffD85B5B),
      onBadgeTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressCubit, AddressState>(
      listenWhen:
          (previous, current) =>
              current is AddressError || current is AddressesLoaded,
      listener: (context, state) {
        if (!_submittedAddress) return;

        if (state is AddressError) {
          _submittedAddress = false;
          _showError(state);
        }

        if (state is AddressesLoaded) {
          _submittedAddress = false;
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isSavingAddress = state is AddressLoading;

        return SafeArea(
          child: Padding(
            padding: AppResponsive.all(context, AppSpacing.screenEdge),
            child: Form(
              key: _addressFormController.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AddAddressHeader(),
                  const Gap(20),
                  Expanded(
                    child: ListView(
                      children: [
                        AddressFormFields(
                          addressFormController: _addressFormController,
                        ),
                      ],
                    ),
                  ),
                  const Gap(18),
                  AddAddressButton(
                    hint:
                        isSavingAddress
                            ? AppStrings.saving
                            : AppStrings.addAddress,
                    onTap: isSavingAddress ? null : _saveAddress,
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

class _AddAddressHeader extends StatelessWidget {
  const _AddAddressHeader();

  @override
  Widget build(BuildContext context) {
    final darkerPrimaryColor = AppColors.darkerShade(AppColors.primaryColor);

    return Row(
      children: [
        Material(
          color: AppColors.primaryColor.withValues(alpha: 0.10),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.maybePop(context),
            child: SizedBox(
              height: 44,
              width: 44,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: darkerPrimaryColor,
                size: 18,
              ),
            ),
          ),
        ),
        const Gap(14),
        Expanded(
          child: Text(
            AppStrings.addAddress,
            textAlign: TextAlign.center,
            style: TextStyles.bold24.copyWith(color: AppColors.shopNameColor),
          ),
        ),
        const SizedBox(width: 58),
      ],
    );
  }
}
