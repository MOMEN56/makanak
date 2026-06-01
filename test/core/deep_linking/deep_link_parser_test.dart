import 'package:flutter_test/flutter_test.dart';
import 'package:makanak/core/deep_linking/app_deep_link.dart';
import 'package:makanak/core/deep_linking/deep_link_parser.dart';

void main() {
  const parser = DeepLinkParser();

  group('DeepLinkParser', () {
    test('parses a valid custom scheme shop link', () {
      final link = parser.parse(Uri.parse('makanak://shops/SHOP_UUID'));

      expect(link, const AppDeepLink.shop(shopId: 'SHOP_UUID'));
    });

    test('parses a valid custom scheme product link', () {
      final link = parser.parse(
        Uri.parse('makanak://shops/SHOP_UUID/products/PRODUCT_UUID'),
      );

      expect(
        link,
        const AppDeepLink.product(
          shopId: 'SHOP_UUID',
          productId: 'PRODUCT_UUID',
        ),
      );
    });

    test('parses a valid github pages https shop link', () {
      final link = parser.parse(
        Uri.parse('https://momen56.github.io/shops/SHOP_UUID'),
      );

      expect(link, const AppDeepLink.shop(shopId: 'SHOP_UUID'));
    });

    test('parses a valid github pages https product link', () {
      final link = parser.parse(
        Uri.parse(
          'https://momen56.github.io/shops/SHOP_UUID/products/PRODUCT_UUID',
        ),
      );

      expect(
        link,
        const AppDeepLink.product(
          shopId: 'SHOP_UUID',
          productId: 'PRODUCT_UUID',
        ),
      );
    });

    test('rejects missing shop id', () {
      final customSchemeLink = parser.parse(Uri.parse('makanak://shops/'));
      final rootLink = parser.parse(Uri.parse('https://momen56.github.io/'));
      final githubPagesLink = parser.parse(
        Uri.parse('https://momen56.github.io/shops'),
      );

      expect(customSchemeLink, isNull);
      expect(rootLink, isNull);
      expect(githubPagesLink, isNull);
    });

    test('rejects missing product id', () {
      final customSchemeLink = parser.parse(
        Uri.parse('makanak://shops/SHOP_UUID/products/'),
      );
      final githubPagesLink = parser.parse(
        Uri.parse('https://momen56.github.io/shops/SHOP_UUID/products'),
      );

      expect(customSchemeLink, isNull);
      expect(githubPagesLink, isNull);
    });

    test('rejects extra path segments', () {
      final customSchemeLink = parser.parse(
        Uri.parse('makanak://shops/SHOP_UUID/cart'),
      );
      final githubPagesLink = parser.parse(
        Uri.parse('https://momen56.github.io/shops/SHOP_UUID/extra'),
      );
      final customSchemeProductLink = parser.parse(
        Uri.parse('makanak://shops/SHOP_UUID/products/PRODUCT_UUID/extra'),
      );
      final githubPagesProductLink = parser.parse(
        Uri.parse(
          'https://momen56.github.io/shops/SHOP_UUID/products/PRODUCT_UUID/extra',
        ),
      );

      expect(customSchemeLink, isNull);
      expect(githubPagesLink, isNull);
      expect(customSchemeProductLink, isNull);
      expect(githubPagesProductLink, isNull);
    });

    test('ignores unrelated https hosts', () {
      final link = parser.parse(Uri.parse('https://example.com/shops/SHOP_ID'));

      expect(link, isNull);
    });

    test('ignores unrelated schemes', () {
      final link = parser.parse(
        Uri.parse('http://momen56.github.io/shops/abc'),
      );

      expect(link, isNull);
    });

    test('ignores auth callback links', () {
      final link = parser.parse(Uri.parse('makanak://auth-callback/'));

      expect(link, isNull);
    });
  });
}
