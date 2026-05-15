import 'package:equatable/equatable.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';

class OrderItemModel extends Equatable {
  const OrderItemModel({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  final ProductModel product;
  final int quantity;
  final int unitPrice;
  final int totalPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final productMap = _readMap(json['product'] ?? json['products']);
    final product = ProductModel.fromJson({
      ...productMap,
      if (productMap['id'] == null && json['product_id'] != null)
        'id': json['product_id'],
    });
    final quantity = _readInt(json['quantity'], defaultValue: 1);
    final resolvedUnitPrice = _readInt(
      json['unit_price'],
      defaultValue: product.price,
    );

    return OrderItemModel(
      product: product,
      quantity: quantity,
      unitPrice: resolvedUnitPrice,
      totalPrice:
          _readNullableInt(json['line_total']) ??
          (resolvedUnitPrice * quantity),
    );
  }

  factory OrderItemModel.fromSingleProduct({
    required ProductModel product,
    required int quantity,
  }) {
    final safeQuantity = quantity < 1 ? 1 : quantity;
    final unitPrice = product.price;

    return OrderItemModel(
      product: product,
      quantity: safeQuantity,
      unitPrice: unitPrice,
      totalPrice: unitPrice * safeQuantity,
    );
  }

  static Map<String, dynamic> _readMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const {};
  }

  static int _readInt(Object? value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [product, quantity, unitPrice, totalPrice];
}
