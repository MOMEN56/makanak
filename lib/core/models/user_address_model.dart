import 'package:equatable/equatable.dart';
import 'package:makanak/core/utils/app_strings.dart';

class UserAddressModel extends Equatable {
  const UserAddressModel({
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

  factory UserAddressModel.fromStoredJson(Map<String, dynamic> json) {
    final title = json['title']?.toString().trim() ?? '';

    return UserAddressModel(
      id: json['id']?.toString() ?? '',
      title: title.isEmpty ? AppStrings.deliveryAddress : title,
      phone: json['phone']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      isDefault: _readBool(json['is_default'], defaultValue: false),
    );
  }

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    final street = json['street']?.toString().trim() ?? '';
    final floor = json['floor']?.toString().trim() ?? '';
    final apartmentNumber = json['apartment_number']?.toString().trim() ?? '';
    final building = json['building_number']?.toString().trim() ?? '';
    final detailsParts = [
      if (building.isNotEmpty) '${AppStrings.buildingNumber} $building',
      if (floor.isNotEmpty) '${AppStrings.floor} $floor',
      if (apartmentNumber.isNotEmpty)
        '${AppStrings.apartmentNumber} $apartmentNumber',
    ];

    return UserAddressModel(
      id: json['id']?.toString() ?? '',
      title: street.isEmpty ? AppStrings.deliveryAddress : street,
      phone: json['phone_number']?.toString() ?? '',
      details: detailsParts.join(', '),
      notes: json['address_notes']?.toString() ?? '',
      isDefault: _readBool(json['is_default'], defaultValue: false),
    );
  }

  Map<String, dynamic> toStoredJson() {
    return {
      'id': id,
      'title': title,
      'phone': phone,
      'details': details,
      'notes': notes,
      'is_default': isDefault,
    };
  }

  UserAddressModel copyWith({
    String? id,
    String? title,
    String? phone,
    String? details,
    String? notes,
    bool? isDefault,
  }) {
    return UserAddressModel(
      id: id ?? this.id,
      title: title ?? this.title,
      phone: phone ?? this.phone,
      details: details ?? this.details,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static bool _readBool(Object? value, {bool defaultValue = true}) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;

    return defaultValue;
  }

  @override
  List<Object?> get props => [id, title, phone, details, notes, isDefault];
}
