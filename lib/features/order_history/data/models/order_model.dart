import 'package:equatable/equatable.dart';
import 'package:makanak/core/models/user_address_model.dart';
import 'package:makanak/features/order_history/data/models/order_item_model.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';

class OrderModel extends Equatable {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.items,
    required this.itemsTotal,
    required this.shippingPrice,
    required this.orderTotal,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
    this.address,
  });

  static const int defaultShippingPrice = 0;

  final String id;
  final String userId;
  final String shopId;
  final List<OrderItemModel> items;
  final int itemsTotal;
  final int shippingPrice;
  final int orderTotal;
  final String status;
  final DateTime? createdAt;
  final String? rejectionReason;
  final UserAddressModel? address;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final items = _parseItems(json);
    final addressMap = _readMap(json['user_address'] ?? json['user_addresses']);
    final resolvedItemsTotal =
        _readNullableInt(json['items_total']) ??
        items.fold<int>(0, (total, item) => total + item.totalPrice);
    final resolvedShippingPrice =
        _readNullableInt(json['shipping_price']) ?? defaultShippingPrice;

    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      shopId: json['shop_id']?.toString() ?? '',
      items: items,
      itemsTotal: resolvedItemsTotal,
      shippingPrice: resolvedShippingPrice,
      orderTotal:
          _readNullableInt(json['order_total']) ??
          (resolvedItemsTotal + resolvedShippingPrice),
      status: _normalizeStatus(json['status']),
      createdAt: _readDateTime(json['created_at']),
      rejectionReason: _readNullableText(
        json['rejection_reason'] ??
            json['rejectionReason'] ??
            json['cancellation_reason'] ??
            json['cancellationReason'] ??
            json['cancel_reason'] ??
            json['cancelReason'] ??
            json['rejected_reason'] ??
            json['rejectedReason'],
      ),
      address:
          addressMap.isEmpty ? null : UserAddressModel.fromJson(addressMap),
    );
  }

  ProductModel? get previewProduct =>
      items.isEmpty ? null : items.first.product;

  String get previewImageUrl => previewProduct?.imageUrl ?? '';

  String get previewName => previewProduct?.name.trim() ?? '';

  int get totalItemsCount {
    return items.fold<int>(0, (total, item) => total + item.quantity);
  }

  int get totalPaid => orderTotal > 0 ? orderTotal : itemsTotal + shippingPrice;

  static List<OrderItemModel> _parseItems(Map<String, dynamic> json) {
    final rawItems = _readList(json['order_details'] ?? json['order_items']);
    if (rawItems.isNotEmpty) {
      return rawItems
          .map(OrderItemModel.fromJson)
          .where((item) => item.quantity > 0)
          .toList(growable: false);
    }

    final productMap = _readMap(json['product'] ?? json['products']);
    if (productMap.isEmpty) {
      return const [];
    }

    return [
      OrderItemModel.fromSingleProduct(
        product: ProductModel.fromJson(productMap),
        quantity: _readInt(json['quantity'], defaultValue: 1),
      ),
    ];
  }

  static List<Map<String, dynamic>> _readList(Object? value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    return const [];
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

  static String? _readNullableText(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static DateTime? _readDateTime(Object? value) {
    final rawDate = value?.toString().trim();
    if (rawDate == null || rawDate.isEmpty) return null;

    return DateTime.tryParse(rawDate)?.toLocal();
  }

  static String _normalizeStatus(Object? value) {
    final status = value?.toString().trim() ?? '';

    switch (status) {
      case 'pending':
      case 'قيد المراجعة':
      case 'تحت المراجعة':
        return 'تحت المراجعة';
      case 'accepted':
      case 'تم القبول ويتم التحضير':
      case 'يتم تحضيره':
        return 'يتم تحضيره';
      case 'out_for_delivery':
      case 'خرج للتوصيل':
        return 'خرج للتوصيل';
      case 'delivered':
      case 'تم التوصيل':
      case 'تم توصيله':
        return 'تم توصيله';
      case 'rejected':
      case 'تم رفض':
      case 'تم الرفض':
      case 'ملغي':
        return 'ملغي';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    shopId,
    items,
    itemsTotal,
    shippingPrice,
    orderTotal,
    status,
    createdAt,
    rejectionReason,
    address,
  ];
}
