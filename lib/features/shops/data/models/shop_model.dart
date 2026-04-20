import 'package:makanak/features/shops/domain/entities/shop_entity.dart';

class ShopModel extends ShopEntity {
  const ShopModel({
    super.id,
    super.ownerId,
    required super.name,
    super.logoUrl,
    super.primaryColor = '#004AAD',
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
      primaryColor: json['primary_color']?.toString() ?? '#004AAD',
      category: json['category']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      isVisible: json['is_visible'] as bool? ?? true,
      isOpen: json['is_open'] as bool? ?? true,
      workingHours: json['working_hours']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'logo_url': logoUrl,
      'primary_color': primaryColor,
      'category': category,
      'is_active': isActive,
      'is_visible': isVisible,
      'is_open': isOpen,
      'working_hours': workingHours,
    }..removeWhere((key, value) => value == null);
  }
}
