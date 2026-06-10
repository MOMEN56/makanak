import 'package:makanak/core/deep_linking/app_deep_link.dart';

class InstallReferrerParser {
  const InstallReferrerParser();

  AppDeepLink? parse(String rawReferrer) {
    final referrer = rawReferrer.trim();
    if (referrer.isEmpty) {
      return null;
    }

    final Map<String, String> params;
    try {
      params = Uri.splitQueryString(referrer);
    } catch (_) {
      return null;
    }

    final shopId = params['shopId']?.trim() ?? '';
    if (shopId.isEmpty) {
      return null;
    }

    if (!params.containsKey('productId')) {
      return AppDeepLink.shop(shopId: shopId);
    }

    final productId = params['productId']?.trim() ?? '';
    if (productId.isEmpty) {
      return null;
    }

    return AppDeepLink.product(shopId: shopId, productId: productId);
  }
}
