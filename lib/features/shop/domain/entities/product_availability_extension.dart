import 'package:makanak/features/shop/domain/entities/product_entity.dart';

extension ProductAvailabilityExtension on ProductEntity {
  bool get isAvailableForPurchase => isVisible && inStock;
  bool get isUnavailableForPurchase => !isAvailableForPurchase;
  bool get isHiddenFromCustomers => !isVisible;
  bool get isOutOfStock => !inStock;
}
