import 'package:flutter/material.dart';
import 'package:makanak/core/deep_linking/app_deep_link.dart';
import 'package:makanak/core/deep_linking/pending_deep_link_manager.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/services/supabase_auth_service.dart';
import 'package:makanak/core/utils/app_colors.dart';
import 'package:makanak/core/utils/app_navigator_key.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/auth/presentation/views/auth_gate_view.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/presentation/views/product_details_view.dart';
import 'package:makanak/features/shop/presentation/views/products_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';
import 'package:makanak/shared/widgets/app_snack_bar.dart';

class DeepLinkNavigator {
  DeepLinkNavigator(
    this._authService,
    this._shopsRepo,
    this._productsRepo,
    this._pendingDeepLinkManager,
  );

  final SupabaseAuthService _authService;
  final ShopsRepo _shopsRepo;
  final ProductsRepo _productsRepo;
  final PendingDeepLinkManager _pendingDeepLinkManager;

  bool _isAuthenticatedNavigationReady = false;

  Future<void> handle(AppDeepLink link) async {
    if (_authService.currentSession == null) {
      _pendingDeepLinkManager.save(link);
      _navigateToAuthGate();
      return;
    }

    if (!_isAuthenticatedNavigationReady) {
      _pendingDeepLinkManager.save(link);
      return;
    }

    await _openLink(link);
  }

  Future<bool> openPendingAfterLogin() async {
    _isAuthenticatedNavigationReady = _authService.currentSession != null;
    if (!_isAuthenticatedNavigationReady) {
      return false;
    }

    final pendingLink = _pendingDeepLinkManager.take();
    if (pendingLink == null) {
      return false;
    }

    await _openLink(pendingLink);
    return true;
  }

  void resetNavigationReadiness() {
    _isAuthenticatedNavigationReady = false;
  }

  Future<void> _openLink(AppDeepLink link) async {
    switch (link.type) {
      case AppDeepLinkType.shop:
        final shopId = link.shopId?.trim() ?? '';
        if (shopId.isEmpty) {
          _showMessage(AppStrings.shopDataUnavailable);
          return;
        }
        await _openShopById(shopId);
        return;
      case AppDeepLinkType.product:
        final shopId = link.shopId?.trim() ?? '';
        final productId = link.productId?.trim() ?? '';
        if (shopId.isEmpty) {
          _showMessage(AppStrings.shopDataUnavailable);
          return;
        }
        if (productId.isEmpty) {
          _showMessage(AppStrings.productDataUnavailable);
          return;
        }
        await _openProductByIds(shopId: shopId, productId: productId);
        return;
    }
  }

  Future<void> _openShopById(String shopId) async {
    final result = await _shopsRepo.fetchShopById(shopId);
    result.fold(_handleFailure, _handleShopResult);
  }

  void _handleFailure(Failure failure) {
    if (failure.isNetwork) {
      final context = appNavigatorKey.currentState?.context;
      if (context == null) {
        return;
      }

      AppSnackBar.showNetwork(context: context, message: failure.message);
      return;
    }

    _showMessage(failure.message);
  }

  void _handleShopResult(ShopModel? shop) {
    if (shop == null) {
      _showMessage(AppStrings.shopDataUnavailable);
      return;
    }

    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      final shopId = shop.id?.trim();
      if (shopId != null && shopId.isNotEmpty) {
        _pendingDeepLinkManager.save(AppDeepLink.shop(shopId: shopId));
      }
      return;
    }

    navigator.popUntil((route) => route.isFirst);
    navigator.pushNamed(
      ProductsView.routeName,
      arguments: ProductsRouteArguments.fromShop(shop),
    );
  }

  Future<void> _openProductByIds({
    required String shopId,
    required String productId,
  }) async {
    final shopResult = await _shopsRepo.fetchShopById(shopId);
    if (shopResult.isLeft()) {
      shopResult.fold(_handleFailure, (_) {});
      return;
    }

    final shop = shopResult.getOrElse(() => null);
    if (shop == null) {
      _showMessage(AppStrings.shopDataUnavailable);
      return;
    }

    final productResult = await _productsRepo.fetchProductByShopAndId(
      shopId: shopId,
      productId: productId,
    );
    if (productResult.isLeft()) {
      productResult.fold(_handleFailure, (_) {});
      return;
    }

    final product = productResult.getOrElse(() => null);
    if (product == null) {
      _showMessage(AppStrings.productDataUnavailable);
      return;
    }

    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      _pendingDeepLinkManager.save(
        AppDeepLink.product(shopId: shopId, productId: productId),
      );
      return;
    }

    navigator.popUntil((route) => route.isFirst);

    navigator.pushNamed(
      ProductsView.routeName,
      arguments: ProductsRouteArguments.fromShop(shop),
    );

    navigator.pushNamed(
      ProductDetailsView.routeName,
      arguments: ProductDetailsRouteArguments.fromModels(
        product: product,
        primaryColor: AppColors.primaryColor,
        shopModel: shop,
      ),
    );
  }

  void _navigateToAuthGate() {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    navigator.pushNamedAndRemoveUntil(AuthGateView.routeName, (route) => false);
  }

  void _showMessage(String message) {
    final context = appNavigatorKey.currentState?.context;
    if (context == null) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
