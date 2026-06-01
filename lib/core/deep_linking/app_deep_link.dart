import 'package:equatable/equatable.dart';

enum AppDeepLinkType { shop, product }

class AppDeepLink extends Equatable {
  const AppDeepLink._({required this.type, this.shopId, this.productId});

  const AppDeepLink.shop({required String shopId})
    : this._(type: AppDeepLinkType.shop, shopId: shopId);

  const AppDeepLink.product({required String shopId, required String productId})
    : this._(
        type: AppDeepLinkType.product,
        shopId: shopId,
        productId: productId,
      );

  final AppDeepLinkType type;
  final String? shopId;
  final String? productId;

  String get dedupeKey {
    return switch (type) {
      AppDeepLinkType.shop => 'shop:${shopId ?? ''}',
      AppDeepLinkType.product => 'product:${shopId ?? ''}:${productId ?? ''}',
    };
  }

  @override
  List<Object?> get props => [type, shopId, productId];
}
