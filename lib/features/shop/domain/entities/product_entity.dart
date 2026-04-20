import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
    this.id,
    this.shopId = '',
    required this.name,
    this.description,
    this.imageUrl = '',
    required this.price,
    this.inStock = true,
    this.stockQuantity = 0,
    this.isVisible = true,
  });

  final String? id;
  final String shopId;
  final String name;
  final String? description;
  final String imageUrl;
  final int price;
  final bool inStock;
  final int stockQuantity;
  final bool isVisible;

  String get desc => description ?? '';
  String get priceText => '$price \u062c\u0646\u064a\u0647';

  @override
  List<Object?> get props => [
        id,
        shopId,
        name,
        description,
        imageUrl,
        price,
        inStock,
        stockQuantity,
        isVisible,
      ];
}
