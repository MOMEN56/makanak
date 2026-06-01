import 'package:makanak/core/deep_linking/app_deep_link.dart';

class DeepLinkParser {
  const DeepLinkParser();

  AppDeepLink? parse(Uri uri) {
    final pathSegments = _resolveShopPathSegments(uri);
    if (pathSegments == null || pathSegments.isEmpty) {
      return null;
    }

    if (pathSegments.length == 2 && pathSegments.first == 'shops') {
      final shopId = pathSegments.last.trim();
      if (shopId.isEmpty) {
        return null;
      }

      return AppDeepLink.shop(shopId: shopId);
    }

    if (pathSegments.length == 4 &&
        pathSegments.first == 'shops' &&
        pathSegments[2] == 'products') {
      final shopId = pathSegments[1].trim();
      final productId = pathSegments[3].trim();
      if (shopId.isEmpty || productId.isEmpty) {
        return null;
      }

      return AppDeepLink.product(shopId: shopId, productId: productId);
    }

    return null;
  }

  List<String>? _resolveShopPathSegments(Uri uri) {
    if (uri.scheme == 'makanak' && uri.host == 'shops') {
      return <String>['shops', ...uri.pathSegments];
    }

    if (uri.scheme == 'https' && uri.host == 'momen56.github.io') {
      return uri.pathSegments;
    }

    return null;
  }
}
