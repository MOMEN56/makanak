import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/domain/entities/product_availability_extension.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';

class CartAvailabilityService {
  const CartAvailabilityService(this._productsRepo, this._shopsRepo);

  final ProductsRepo _productsRepo;
  final ShopsRepo _shopsRepo;

  String? resolveShopId({required List<CartLocalData> items, String? shopId}) {
    final normalizedShopId = shopId?.trim();
    if (normalizedShopId != null && normalizedShopId.isNotEmpty) {
      return normalizedShopId;
    }

    if (items.isEmpty) return null;

    final itemShopId = items.first.product.shopId.trim();
    return itemShopId.isEmpty ? null : itemShopId;
  }

  Future<CartShopValidationResult> validateShop(
    String shopId, {
    required String fetchFailureMessage,
  }) async {
    final normalizedShopId = shopId.trim();
    if (normalizedShopId.isEmpty) {
      return const CartShopValidationResult.failure(
        message: AppStrings.invalidProduct,
        status: CartShopValidationStatus.verificationFailed,
      );
    }

    final result = await _shopsRepo.fetchShopById(normalizedShopId);
    return result.fold(
      (failure) => CartShopValidationResult.failure(
        message: failure.isNetwork ? failure.message : fetchFailureMessage,
        status: CartShopValidationStatus.verificationFailed,
      ),
      (shop) {
        if (shop == null || !shop.isActive || !shop.isVisible) {
          return const CartShopValidationResult.failure(
            message: AppStrings.shopUnavailableNow,
            status: CartShopValidationStatus.unavailable,
          );
        }

        if (!shop.isOpen) {
          return const CartShopValidationResult.failure(
            message: AppStrings.shopClosedNow,
            status: CartShopValidationStatus.shopClosed,
          );
        }

        return CartShopValidationResult.valid(
          shippingPrice: shop.shippingPrice,
        );
      },
    );
  }

  Future<CartAvailabilitySyncResult> syncItems({
    required List<CartLocalData> sourceItems,
    String? shopId,
  }) async {
    final resolvedShopId = resolveShopId(items: sourceItems, shopId: shopId);
    if (sourceItems.isEmpty) {
      return CartAvailabilitySyncResult(
        shopId: resolvedShopId,
        availableItems: const [],
        removedItems: const [],
        didFetchLatestProducts: true,
        syncFailed: false,
      );
    }

    if (resolvedShopId == null || resolvedShopId.isEmpty) {
      return CartAvailabilitySyncResult(
        shopId: resolvedShopId,
        availableItems: sourceItems,
        removedItems: const [],
        didFetchLatestProducts: false,
        syncFailed: true,
      );
    }

    final productIds = sourceItems
        .map((item) => item.product.id?.trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (productIds.length != sourceItems.length) {
      return CartAvailabilitySyncResult(
        shopId: resolvedShopId,
        availableItems: const [],
        removedItems: sourceItems
            .map(
              (item) => CartRemovedItem(
                productName: _productNameFrom(item.product),
                reason: CartRemovedItemReason.unavailable,
              ),
            )
            .toList(growable: false),
        didFetchLatestProducts: true,
        syncFailed: false,
      );
    }

    final result = await _productsRepo.fetchProductsByIds(
      shopId: resolvedShopId,
      productIds: productIds,
    );
    final shippingPrice = await _resolveShippingPrice(
      shopId: resolvedShopId,
      fallbackPrice: sourceItems.first.shippingPrice,
    );
    return result.fold(
      (failure) => CartAvailabilitySyncResult(
        shopId: resolvedShopId,
        availableItems: sourceItems,
        removedItems: const [],
        didFetchLatestProducts: false,
        syncFailed: true,
        failureMessage: failure.isNetwork ? failure.message : null,
      ),
      (products) {
        final productsById = <String, ProductModel>{
          for (final product in products)
            if ((product.id ?? '').trim().isNotEmpty)
              product.id!.trim(): product,
        };
        final availableItems = <CartLocalData>[];
        final removedItems = <CartRemovedItem>[];

        for (final item in sourceItems) {
          final productId = item.product.id?.trim() ?? '';
          final latestProduct = productsById[productId];
          final productName = _productNameFrom(latestProduct ?? item.product);

          if (latestProduct == null || latestProduct.isHiddenFromCustomers) {
            removedItems.add(
              CartRemovedItem(
                productName: productName,
                reason: CartRemovedItemReason.unavailable,
              ),
            );
            continue;
          }

          if (latestProduct.isOutOfStock) {
            removedItems.add(
              CartRemovedItem(
                productName: productName,
                reason: CartRemovedItemReason.outOfStock,
              ),
            );
            continue;
          }

          availableItems.add(
            CartLocalData(
              product: latestProduct,
              quantity: item.quantity,
              shippingPrice: shippingPrice,
            ),
          );
        }

        return CartAvailabilitySyncResult(
          shopId: resolvedShopId,
          availableItems: availableItems,
          removedItems: removedItems,
          didFetchLatestProducts: true,
          syncFailed: false,
        );
      },
    );
  }

  String messageForRemovedItems(List<CartRemovedItem> removedItems) {
    if (removedItems.length == 1) {
      final removedItem = removedItems.first;
      return switch (removedItem.reason) {
        CartRemovedItemReason.outOfStock =>
          AppStrings.outOfStockProductRemovedFromCart(removedItem.productName),
        CartRemovedItemReason.unavailable =>
          AppStrings.unavailableProductRemovedFromCart(removedItem.productName),
      };
    }

    final allOutOfStock = removedItems.every(
      (item) => item.reason == CartRemovedItemReason.outOfStock,
    );
    if (allOutOfStock) {
      return AppStrings.outOfStockProductsRemovedFromCart;
    }

    return AppStrings.unavailableProductsRemovedFromCart;
  }

  String _productNameFrom(ProductModel product) {
    final productName = product.name.trim();
    if (productName.isNotEmpty) {
      return productName;
    }

    return AppStrings.product;
  }

  Future<int> _resolveShippingPrice({
    required String shopId,
    required int fallbackPrice,
  }) async {
    final result = await _shopsRepo.fetchShopById(shopId);
    return result.fold(
      (_) => fallbackPrice,
      (shop) => shop?.shippingPrice ?? fallbackPrice,
    );
  }
}

class CartAvailabilitySyncResult {
  const CartAvailabilitySyncResult({
    required this.shopId,
    required this.availableItems,
    required this.removedItems,
    required this.didFetchLatestProducts,
    this.syncFailed = false,
    this.failureMessage,
  });

  final String? shopId;
  final List<CartLocalData> availableItems;
  final List<CartRemovedItem> removedItems;
  final bool didFetchLatestProducts;
  final bool syncFailed;
  final String? failureMessage;
}

class CartRemovedItem {
  const CartRemovedItem({required this.productName, required this.reason});

  final String productName;
  final CartRemovedItemReason reason;
}

enum CartRemovedItemReason { outOfStock, unavailable }

enum CartShopValidationStatus {
  valid,
  shopClosed,
  unavailable,
  verificationFailed,
}

class CartShopValidationResult {
  const CartShopValidationResult._({
    required this.isValid,
    required this.message,
    required this.status,
    required this.shippingPrice,
  });

  const CartShopValidationResult.valid({required int shippingPrice})
    : this._(
        isValid: true,
        message: '',
        status: CartShopValidationStatus.valid,
        shippingPrice: shippingPrice,
      );

  const CartShopValidationResult.failure({
    required String message,
    required CartShopValidationStatus status,
  }) : this._(
         isValid: false,
         message: message,
         status: status,
         shippingPrice: 0,
       );

  final bool isValid;
  final String message;
  final CartShopValidationStatus status;
  final int shippingPrice;
}
