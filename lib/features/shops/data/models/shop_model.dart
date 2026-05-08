import 'package:makanak/features/shops/domain/entities/shop_entity.dart';

class ShopModel extends ShopEntity {
  const ShopModel({
    super.id,
    super.ownerId,
    required super.name,
    super.logoUrl,
    required super.category,
    super.isActive = true,
    super.isVisible = true,
    super.isOpen = true,
    super.workingHours = '',
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id']?.toString(),
      ownerId: json['owner_id']?.toString(),
      name: json['name']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString(),
      category: json['category']?.toString() ?? '',
      isActive: _readBool(json['is_active']),
      isVisible: _readBool(json['is_visible']),
      isOpen: _readBool(json['is_open']),
      workingHours: json['working_hours']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'logo_url': logoUrl,
      'category': category,
      'is_active': isActive,
      'is_visible': isVisible,
      'is_open': isOpen,
      'working_hours': workingHours,
    }..removeWhere((key, value) => value == null);
  }

  static bool _readBool(Object? value, {bool defaultValue = true}) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;

    return defaultValue;
  }
}
