import 'package:equatable/equatable.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';

sealed class CartState extends Equatable {
  CartState({
    List<CartLocalData> items = const [],
    ProductModel? product,
    int quantity = 1,
    this.shippingPrice = 35,
  }) : items = List.unmodifiable(
         _resolveItems(
           items: items,
           product: product,
           quantity: quantity,
           shippingPrice: shippingPrice,
         ),
       );

  final List<CartLocalData> items;
  final int shippingPrice;

  ProductModel? get product => items.isEmpty ? null : items.first.product;
  int get quantity => items.isEmpty ? 1 : items.first.quantity;
  int get itemCount => items.fold(0, (total, item) => total + item.quantity);
  int get itemsSubtotal {
    return items.fold(
      0,
      (total, item) => total + (item.product.price * item.quantity),
    );
  }

  int get orderTotal => itemsSubtotal + shippingPrice;

  /// Used for optimized [BlocSelector] to detect composition changes
  /// without quantity-driven rebuilds.
  List<String> get itemIds => items.map((i) => i.product.id ?? '').toList();

  @override
  List<Object?> get props => [items, shippingPrice];

  static List<CartLocalData> _resolveItems({
    required List<CartLocalData> items,
    required ProductModel? product,
    required int quantity,
    required int shippingPrice,
  }) {
    if (items.isNotEmpty) return items;
    if (product == null) return const [];

    return [
      CartLocalData(
        product: product,
        quantity: quantity,
        shippingPrice: shippingPrice,
      ),
    ];
  }
}

class CartInitial extends CartState {
  CartInitial({
    super.items,
    super.product,
    super.quantity,
    super.shippingPrice,
  });
}

class CartLoading extends CartState {
  CartLoading({
    super.items,
    super.product,
    super.quantity,
    super.shippingPrice,
  });
}

class CartOrderSubmitted extends CartState {
  CartOrderSubmitted({
    super.items,
    super.product,
    super.quantity,
    super.shippingPrice,
  });
}

class CartError extends CartState {
  CartError(
    this.message, {
    super.items,
    super.product,
    super.quantity,
    super.shippingPrice,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
