import 'package:makanak/core/utils/app_strings.dart';

class ConfirmingOrderAddressModel {
  const ConfirmingOrderAddressModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.details,
    required this.notes,
    this.isDefault = false,
  });

  final String id;
  final String title;
  final String phone;
  final String details;
  final String notes;
  final bool isDefault;

  factory ConfirmingOrderAddressModel.fromJson(Map<String, dynamic> json) {
    final street = json['street']?.toString().trim() ?? '';
    final floor = json['floor']?.toString().trim() ?? '';
    final apartmentNumber = json['apartment_number']?.toString().trim() ?? '';
    final building = json['building']?.toString().trim() ?? '';
    final detailsParts = [
      if (street.isNotEmpty) street,
      if (building.isNotEmpty) '${AppStrings.buildingNumber} $building',
      if (floor.isNotEmpty) '${AppStrings.floor} $floor',
      if (apartmentNumber.isNotEmpty)
        '${AppStrings.apartmentNumber} $apartmentNumber',
    ];

    return ConfirmingOrderAddressModel(
      id: json['id']?.toString() ?? '',
      title: street.isEmpty ? AppStrings.deliveryAddress : street,
      phone: json['phone_number']?.toString() ?? '',
      details: detailsParts.join('، '),
      notes: json['address_notes']?.toString() ?? '',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}
