import 'package:makanak/features/shop/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    super.id,
    super.shopId = '',
    required super.name,
    super.description,
    super.imageUrl,
    required super.price,
    super.inStock = true,
    super.stockQuantity = 0,
    super.isVisible = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      shopId: json['shop_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString() ?? '',
      price: _readInt(json['price']),
      inStock: _readBool(json['in_stock']),
      stockQuantity: _readInt(json['stock_quantity']),
      isVisible: _readBool(json['is_visible']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'is_visible': isVisible,
    }..removeWhere((key, value) => value == null);
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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
