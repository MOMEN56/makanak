import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/address_form_controller.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/shared/widgets/address_details_fields_widget.dart';
import 'package:makanak/shared/widgets/user_address__text_field_widget.dart';

class AddressFormFields extends StatelessWidget {
  const AddressFormFields({
    super.key,
    required this.addressFormController,
    this.primaryColor = AppColors.primaryColor,
  });

  final AddressFormController addressFormController;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserAddressTextField(
          controller: addressFormController.addressNameController,
          hint: AppStrings.addressNameHint,
          label: AppStrings.addressName,
          icon: Icons.bookmark_border_rounded,
          primaryColor: primaryColor,
          validator: AddressFormController.addressNameValidator,
        ),
        const Gap(14),
        UserAddressTextField(
          controller: addressFormController.phoneController,
          hint: '01xxxxxxxxx',
          label: AppStrings.phoneNumber,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          primaryColor: primaryColor,
          validator: AddressFormController.phoneValidator,
        ),
        const Gap(14),
        AddressDetailsFields(
          floorController: addressFormController.floorController,
          buildingController: addressFormController.buildingController,
          apartmentController: addressFormController.apartmentController,
          notesController: addressFormController.notesController,
          primaryColor: primaryColor,
        ),
      ],
    );
  }
}
