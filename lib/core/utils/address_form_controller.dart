import 'package:flutter/material.dart';
import 'package:makanak/core/utils/address_form_validator.dart';
import 'package:makanak/core/utils/app_strings.dart';

typedef SaveAddressCallback =
    Future<void> Function({
      required String street,
      required String floor,
      required String building,
      required String apartmentNumber,
      String notes,
      required String phoneNumber,
    });

typedef SaveAddressDraftCallback =
    void Function({
      required String addressName,
      required String phone,
      required String floor,
      required String building,
      required String apartment,
      required String notes,
    });

class AddressFormController {
  AddressFormController({
    String addressName = '',
    String phone = '',
    String floor = '',
    String building = '',
    String apartment = '',
    String notes = '',
  }) : addressNameController = TextEditingController(text: addressName),
       phoneController = TextEditingController(text: phone),
       floorController = TextEditingController(text: floor),
       buildingController = TextEditingController(text: building),
       apartmentController = TextEditingController(text: apartment),
       notesController = TextEditingController(text: notes);

  final formKey = GlobalKey<FormState>();
  final TextEditingController addressNameController;
  final TextEditingController phoneController;
  final TextEditingController floorController;
  final TextEditingController buildingController;
  final TextEditingController apartmentController;
  final TextEditingController notesController;

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  Future<void> saveAddress(SaveAddressCallback saveAddress) {
    return saveAddress(
      street: addressNameController.text,
      floor: floorController.text,
      building: buildingController.text,
      apartmentNumber: apartmentController.text,
      notes: notesController.text,
      phoneNumber: AddressFormValidator.normalizeDigits(phoneController.text),
    );
  }

  void saveDraft(SaveAddressDraftCallback saveDraft) {
    saveDraft(
      addressName: addressNameController.text,
      phone: phoneController.text,
      floor: floorController.text,
      building: buildingController.text,
      apartment: apartmentController.text,
      notes: notesController.text,
    );
  }

  void clear() {
    addressNameController.clear();
    phoneController.clear();
    floorController.clear();
    buildingController.clear();
    apartmentController.clear();
    notesController.clear();
  }

  void dispose() {
    addressNameController.dispose();
    phoneController.dispose();
    floorController.dispose();
    buildingController.dispose();
    apartmentController.dispose();
    notesController.dispose();
  }

  static String? addressNameValidator(String? value) {
    return AddressFormValidator.requiredMaxWords(
      value,
      maxWords: 50,
      fieldName: AppStrings.street,
    );
  }

  static String? phoneValidator(String? value) {
    return AddressFormValidator.phoneNumber(value);
  }

  static String? floorValidator(String? value) {
    return AddressFormValidator.requiredMaxWords(
      value,
      maxWords: 10,
      fieldName: AppStrings.floor,
    );
  }

  static String? apartmentValidator(String? value) {
    return AddressFormValidator.requiredMaxWords(
      value,
      maxWords: 10,
      fieldName: AppStrings.apartmentNumber,
    );
  }

  static String? buildingValidator(String? value) {
    return AddressFormValidator.requiredMaxWords(
      value,
      maxWords: 10,
      fieldName: AppStrings.buildingNumber,
    );
  }

  static String? notesValidator(String? value) {
    return AddressFormValidator.optionalMaxWords(
      value,
      maxWords: 100,
      fieldName: AppStrings.notes,
    );
  }
}
