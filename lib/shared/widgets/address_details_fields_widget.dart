import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/core/utils/address_form_controller.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/shared/widgets/user_address__text_field_widget.dart';

class AddressDetailsFields extends StatelessWidget {
  const AddressDetailsFields({
    super.key,
    required this.floorController,
    required this.buildingController,
    required this.apartmentController,
    required this.notesController,
    this.primaryColor = AppColors.primaryColor,
  });

  final TextEditingController floorController;
  final TextEditingController buildingController;
  final TextEditingController apartmentController;
  final TextEditingController notesController;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: UserAddressTextField(
                controller: floorController,
                hint: AppStrings.floor,
                icon: Icons.stairs_outlined,
                keyboardType: TextInputType.number,
                primaryColor: primaryColor,
                validator: AddressFormController.floorValidator,
              ),
            ),
            const Gap(12),
            Expanded(
              child: UserAddressTextField(
                controller: buildingController,
                hint: AppStrings.buildingNumber,
                label: AppStrings.buildingNumber,
                icon: Icons.apartment_rounded,
                keyboardType: TextInputType.number,
                primaryColor: primaryColor,
                validator: AddressFormController.buildingValidator,
              ),
            ),
          ],
        ),
        const Gap(14),
        UserAddressTextField(
          controller: apartmentController,
          hint: '5',
          label: AppStrings.apartmentNumber,
          icon: Icons.door_front_door_outlined,
          keyboardType: TextInputType.number,
          primaryColor: primaryColor,
          validator: AddressFormController.apartmentValidator,
        ),
        const Gap(14),
        UserAddressTextField(
          controller: notesController,
          hint: AppStrings.deliveryNotesHint,
          label: AppStrings.notes,
          icon: Icons.notes_outlined,
          maxLines: 3,
          isRequired: false,
          primaryColor: primaryColor,
          validator: AddressFormController.notesValidator,
        ),
      ],
    );
  }
}
