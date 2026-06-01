import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makanak/core/deep_linking/app_deep_link.dart';
import 'package:makanak/core/deep_linking/deep_link_navigator.dart';
import 'package:makanak/core/deep_linking/pending_deep_link_manager.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/services/supabase_auth_service.dart';
import 'package:makanak/core/utils/app_navigator_key.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/shop/data/models/product_model.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
  });

  group('DeepLinkNavigator', () {
    testWidgets('stores a pending link and routes to auth when logged out', (
      tester,
    ) async {
      final pendingManager = PendingDeepLinkManager();
      final navigator = DeepLinkNavigator(
        _FakeSupabaseAuthService(null),
        _FakeShopsRepo(),
        _FakeProductsRepo(),
        pendingManager,
      );
      final routedNames = <String?>[];

      await tester.pumpWidget(
        _TestApp(initialRoute: '/start', routedNames: routedNames),
      );

      await navigator.handle(const AppDeepLink.shop(shopId: 'shop-1'));
      await tester.pumpAndSettle();

      expect(pendingManager.peek(), const AppDeepLink.shop(shopId: 'shop-1'));
      expect(routedNames, contains('/'));
    });

    testWidgets('opens the requested shop when authenticated and ready', (
      tester,
    ) async {
      final pendingManager = PendingDeepLinkManager();
      final navigator = DeepLinkNavigator(
        _FakeSupabaseAuthService(_authenticatedSession()),
        _FakeShopsRepo(
          shopResult: right(
            const ShopModel(
              id: 'shop-1',
              ownerId: 'owner-1',
              name: 'Test Shop',
              category: 'Groceries',
            ),
          ),
        ),
        _FakeProductsRepo(),
        pendingManager,
      );
      final routedNames = <String?>[];
      final routedArguments = <Object?>[];

      await tester.pumpWidget(
        _TestApp(
          initialRoute: '/start',
          routedNames: routedNames,
          routedArguments: routedArguments,
        ),
      );

      await navigator.openPendingAfterLogin();
      await navigator.handle(const AppDeepLink.shop(shopId: 'shop-1'));
      await tester.pumpAndSettle();

      expect(routedNames, contains('products_list'));
      expect(routedArguments.last, isA<ProductsRouteArguments>());
      expect(pendingManager.hasPending, isFalse);
    });

    testWidgets('does not navigate to products when the shop is missing', (
      tester,
    ) async {
      final navigator = DeepLinkNavigator(
        _FakeSupabaseAuthService(_authenticatedSession()),
        _FakeShopsRepo(shopResult: const Right(null)),
        _FakeProductsRepo(),
        PendingDeepLinkManager(),
      );
      final routedNames = <String?>[];

      await tester.pumpWidget(
        _TestApp(initialRoute: '/start', routedNames: routedNames),
      );

      await navigator.openPendingAfterLogin();
      await navigator.handle(const AppDeepLink.shop(shopId: 'missing-shop'));
      await tester.pumpAndSettle();

      expect(routedNames.where((name) => name == 'products_list'), isEmpty);
      expect(find.text(AppStrings.shopDataUnavailable), findsOneWidget);
    });

    testWidgets('does not navigate to products when the repo fails', (
      tester,
    ) async {
      final navigator = DeepLinkNavigator(
        _FakeSupabaseAuthService(_authenticatedSession()),
        _FakeShopsRepo(
          shopResult: const Left(Failure(AppStrings.shopsLoadError)),
        ),
        _FakeProductsRepo(),
        PendingDeepLinkManager(),
      );
      final routedNames = <String?>[];

      await tester.pumpWidget(
        _TestApp(initialRoute: '/start', routedNames: routedNames),
      );

      await navigator.openPendingAfterLogin();
      await navigator.handle(const AppDeepLink.shop(shopId: 'shop-1'));
      await tester.pumpAndSettle();

      expect(routedNames.where((name) => name == 'products_list'), isEmpty);
      expect(find.text(AppStrings.shopsLoadError), findsOneWidget);
    });

    testWidgets(
      'stores a pending product link and routes to auth when logged out',
      (tester) async {
        final pendingManager = PendingDeepLinkManager();
        final navigator = DeepLinkNavigator(
          _FakeSupabaseAuthService(null),
          _FakeShopsRepo(),
          _FakeProductsRepo(),
          pendingManager,
        );
        final routedNames = <String?>[];

        await tester.pumpWidget(
          _TestApp(initialRoute: '/start', routedNames: routedNames),
        );

        await navigator.handle(
          const AppDeepLink.product(shopId: 'shop-1', productId: 'product-1'),
        );
        await tester.pumpAndSettle();

        expect(
          pendingManager.peek(),
          const AppDeepLink.product(shopId: 'shop-1', productId: 'product-1'),
        );
        expect(routedNames, contains('/'));
      },
    );

    testWidgets(
      'opens product details when authenticated product link is valid',
      (tester) async {
        final pendingManager = PendingDeepLinkManager();
        final navigator = DeepLinkNavigator(
          _FakeSupabaseAuthService(_authenticatedSession()),
          _FakeShopsRepo(
            shopResult: right(
              const ShopModel(
                id: 'shop-1',
                ownerId: 'owner-1',
                name: 'Test Shop',
                category: 'Groceries',
              ),
            ),
          ),
          _FakeProductsRepo(
            productResult: right(
              const ProductModel(
                id: 'product-1',
                shopId: 'shop-1',
                name: 'Test Product',
                price: 50,
              ),
            ),
          ),
          pendingManager,
        );
        final routedNames = <String?>[];
        final routedArguments = <Object?>[];

        await tester.pumpWidget(
          _TestApp(
            initialRoute: '/start',
            routedNames: routedNames,
            routedArguments: routedArguments,
          ),
        );

        await navigator.openPendingAfterLogin();
        await navigator.handle(
          const AppDeepLink.product(shopId: 'shop-1', productId: 'product-1'),
        );
        await tester.pumpAndSettle();

        expect(routedNames, contains('product_details'));
        expect(routedArguments.last, isA<ProductDetailsRouteArguments>());
        expect(pendingManager.hasPending, isFalse);
      },
    );

    testWidgets('does not navigate when the product is missing', (
      tester,
    ) async {
      final navigator = DeepLinkNavigator(
        _FakeSupabaseAuthService(_authenticatedSession()),
        _FakeShopsRepo(
          shopResult: right(
            const ShopModel(
              id: 'shop-1',
              ownerId: 'owner-1',
              name: 'Test Shop',
              category: 'Groceries',
            ),
          ),
        ),
        _FakeProductsRepo(productResult: const Right(null)),
        PendingDeepLinkManager(),
      );
      final routedNames = <String?>[];

      await tester.pumpWidget(
        _TestApp(initialRoute: '/start', routedNames: routedNames),
      );

      await navigator.openPendingAfterLogin();
      await navigator.handle(
        const AppDeepLink.product(shopId: 'shop-1', productId: 'missing'),
      );
      await tester.pumpAndSettle();

      expect(routedNames.where((name) => name == 'product_details'), isEmpty);
      expect(find.text(AppStrings.productDataUnavailable), findsOneWidget);
    });

    testWidgets(
      'does not navigate when the shop is missing for a product link',
      (tester) async {
        final navigator = DeepLinkNavigator(
          _FakeSupabaseAuthService(_authenticatedSession()),
          _FakeShopsRepo(shopResult: const Right(null)),
          _FakeProductsRepo(
            productResult: right(
              const ProductModel(
                id: 'product-1',
                shopId: 'shop-1',
                name: 'Test Product',
                price: 50,
              ),
            ),
          ),
          PendingDeepLinkManager(),
        );
        final routedNames = <String?>[];

        await tester.pumpWidget(
          _TestApp(initialRoute: '/start', routedNames: routedNames),
        );

        await navigator.openPendingAfterLogin();
        await navigator.handle(
          const AppDeepLink.product(shopId: 'shop-1', productId: 'product-1'),
        );
        await tester.pumpAndSettle();

        expect(routedNames.where((name) => name == 'product_details'), isEmpty);
        expect(find.text(AppStrings.shopDataUnavailable), findsOneWidget);
      },
    );

    testWidgets('does not navigate when the product repo fails', (
      tester,
    ) async {
      final navigator = DeepLinkNavigator(
        _FakeSupabaseAuthService(_authenticatedSession()),
        _FakeShopsRepo(
          shopResult: right(
            const ShopModel(
              id: 'shop-1',
              ownerId: 'owner-1',
              name: 'Test Shop',
              category: 'Groceries',
            ),
          ),
        ),
        _FakeProductsRepo(
          productResult: const Left(
            Failure(AppStrings.productAvailabilityCheckFailed),
          ),
        ),
        PendingDeepLinkManager(),
      );
      final routedNames = <String?>[];

      await tester.pumpWidget(
        _TestApp(initialRoute: '/start', routedNames: routedNames),
      );

      await navigator.openPendingAfterLogin();
      await navigator.handle(
        const AppDeepLink.product(shopId: 'shop-1', productId: 'product-1'),
      );
      await tester.pumpAndSettle();

      expect(routedNames.where((name) => name == 'product_details'), isEmpty);
      expect(
        find.text(AppStrings.productAvailabilityCheckFailed),
        findsOneWidget,
      );
    });
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.initialRoute,
    required this.routedNames,
    this.routedArguments,
  });

  final String initialRoute;
  final List<String?> routedNames;
  final List<Object?>? routedArguments;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        routedNames.add(settings.name);
        routedArguments?.add(settings.arguments);

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) {
            return Scaffold(
              body: Center(child: Text(settings.name ?? 'unknown-route')),
            );
          },
        );
      },
    );
  }
}

class _FakeSupabaseAuthService implements SupabaseAuthService {
  _FakeSupabaseAuthService(this._session);

  final supa.Session? _session;

  @override
  supa.Session? get currentSession => _session;

  @override
  Stream<supa.AuthState> get onAuthStateChange => const Stream.empty();

  @override
  Future<supa.AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<supa.AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<supa.AuthResponse> signInWithGoogleTokens({
    required String accessToken,
    required String idToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> signInWithGoogleOAuthFallback() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }
}

class _FakeShopsRepo implements ShopsRepo {
  _FakeShopsRepo({
    Either<Failure, ShopModel?>? shopResult,
    Either<Failure, List<ShopModel>>? shopsResult,
  }) : _shopResult = shopResult ?? const Right(null),
       _shopsResult = shopsResult ?? const Right([]);

  final Either<Failure, ShopModel?> _shopResult;
  final Either<Failure, List<ShopModel>> _shopsResult;

  @override
  Future<Either<Failure, ShopModel?>> fetchShopById(String shopId) async {
    return _shopResult;
  }

  @override
  Future<Either<Failure, List<ShopModel>>> fetchShops({
    String query = '',
  }) async {
    return _shopsResult;
  }
}

class _FakeProductsRepo implements ProductsRepo {
  _FakeProductsRepo({
    Either<Failure, ProductModel?>? productResult,
    Either<Failure, List<ProductModel>>? productsByIdsResult,
    Either<Failure, List<ProductModel>>? productsByShopResult,
  }) : _productResult = productResult ?? const Right(null),
       _productsByIdsResult = productsByIdsResult ?? const Right([]),
       _productsByShopResult = productsByShopResult ?? const Right([]);

  final Either<Failure, ProductModel?> _productResult;
  final Either<Failure, List<ProductModel>> _productsByIdsResult;
  final Either<Failure, List<ProductModel>> _productsByShopResult;

  @override
  Future<Either<Failure, ProductModel?>> fetchProductByShopAndId({
    required String shopId,
    required String productId,
  }) async {
    return _productResult;
  }

  @override
  Future<Either<Failure, List<ProductModel>>> fetchProductsByIds({
    required String shopId,
    required List<String> productIds,
  }) async {
    return _productsByIdsResult;
  }

  @override
  Future<Either<Failure, List<ProductModel>>> fetchProductsByShopId(
    String shopId, {
    String query = '',
    ProductPriceSort priceSort = ProductPriceSort.none,
  }) async {
    return _productsByShopResult;
  }
}

supa.Session _authenticatedSession() {
  return supa.Session(
    accessToken: 'header.payload.signature',
    refreshToken: 'refresh-token',
    tokenType: 'bearer',
    user: supa.User(
      id: 'user-1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-06-01T00:00:00.000Z',
    ),
  );
}
