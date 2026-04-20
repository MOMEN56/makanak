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
      price: json['price'] as int,
      inStock: json['in_stock'] as bool? ?? true,
      stockQuantity: json['stock_quantity'] as int,
      isVisible: json['is_visible'] as bool? ?? true,
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
}
