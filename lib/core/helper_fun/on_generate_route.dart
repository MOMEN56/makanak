import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/admin_notifications/presentation/manager/admin_send_notification_cubit/admin_send_notification_cubit.dart';
import 'package:makanak/features/admin_notifications/presentation/views/admin_send_notification_view.dart';
import 'package:makanak/features/auth/presentation/views/auth_gate_view.dart';
import 'package:makanak/features/auth/presentation/views/sign_in_view.dart';
import 'package:makanak/features/auth/presentation/views/sign_up_view.dart';
import 'package:makanak/features/bottom_navigation/presentation/views/bottom_navigation_view.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit_registry.dart';
import 'package:makanak/features/cart/presentation/views/add_user_address_view.dart';
import 'package:makanak/features/cart/presentation/views/cart_view.dart';
import 'package:makanak/features/cart/presentation/views/confirming_order_view.dart';
import 'package:makanak/features/cart/presentation/views/submit_order_view.dart';
import 'package:makanak/features/notifications/presentation/views/notifications_history_view.dart';
import 'package:makanak/features/order_history/data/models/order_model.dart';
import 'package:makanak/features/order_history/presentation/views/order_details_view.dart';
import 'package:makanak/features/order_history/presentation/views/order_history_view.dart';
import 'package:makanak/features/profile/presentation/views/profile_view.dart';
import 'package:makanak/features/shop/presentation/views/product_details_view.dart';
import 'package:makanak/features/shop/presentation/views/products_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/presentation/views/shops_view.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AuthGateView.routeName:
      return _fadeRoute(
        settings: settings,
        builder: (_) => const AuthGateView(),
      );
    case SignInView.routeName:
      return _fadeRoute(settings: settings, builder: (_) => const SignInView());
    case SignUpView.routeName:
      return _fadeRoute(settings: settings, builder: (_) => const SignUpView());
    case BottomNavigationView.routeName:
      return _fadeRoute(
        settings: settings,
        builder: (_) => const BottomNavigationView(),
      );
    case CartView.routeName:
      final arguments = settings.arguments;
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => _CartFlowProviders(
              shopId:
                  arguments is CartViewArguments
                      ? _shopIdFromCartArguments(arguments)
                      : null,
              child: CartView(
                cartArguments:
                    arguments is CartViewArguments ? arguments : null,
              ),
            ),
      );
    case AddUserAddressView.routeName:
      final arguments = settings.arguments;
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => _CartFlowProviders(
              shopId:
                  arguments is CartViewArguments
                      ? _shopIdFromCartArguments(arguments)
                      : null,
              child: AddUserAddressView(
                cartArguments:
                    arguments is CartViewArguments ? arguments : null,
              ),
            ),
      );
    case ConfirmingOrderView.routeName:
      final arguments = settings.arguments;
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => _CartFlowProviders(
              shopId:
                  arguments is CartViewArguments
                      ? _shopIdFromCartArguments(arguments)
                      : null,
              child: ConfirmingOrderView(
                cartArguments:
                    arguments is CartViewArguments ? arguments : null,
              ),
            ),
      );
    case SubmitOrderView.routeName:
      final arguments = settings.arguments;
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => SubmitOrderView(
              cartArguments: arguments is CartViewArguments ? arguments : null,
            ),
      );
    case ShopsView.routeName:
      return _fadeRoute(settings: settings, builder: (_) => const ShopsView());
    case OrderHistoryView.routeName:
      return _fadeRoute(
        settings: settings,
        builder: (_) => const OrderHistoryView(),
      );
    case NotificationsHistoryView.routeName:
      return _fadeRoute(
        settings: settings,
        builder: (_) => const NotificationsHistoryView(),
      );
    case AdminSendNotificationView.routeName:
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => BlocProvider<AdminSendNotificationCubit>(
              create: (_) => getIt<AdminSendNotificationCubit>(),
              child: const AdminSendNotificationView(),
            ),
      );
    case OrderDetailsView.routeName:
      final arguments = settings.arguments;
      if (arguments is OrderModel) {
        return _fadeRoute(
          settings: settings,
          builder: (_) => OrderDetailsView(order: arguments),
        );
      }
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => const Scaffold(
              body: Center(child: Text(AppStrings.orderDetailsUnavailable)),
            ),
      );
    case ProfileView.routeName:
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => BlocProvider<AddressCubit>(
              create: (_) => getIt<AddressCubit>(),
              child: const ProfileView(),
            ),
      );
    case ProductDetailsView.routeName:
      final arguments = settings.arguments;

      if (arguments is ProductDetailsViewArguments) {
        return _fadeRoute(
          settings: settings,
          builder:
              (_) => _CartCubitProvider(
                shopId: _shopIdFromProductDetailsArguments(arguments),
                child: ProductDetailsView(
                  product: arguments.product,
                  primaryColor: arguments.primaryColor,
                  shopModel: arguments.shopModel,
                  initialQuantity: arguments.initialQuantity,
                  onCartRequested: arguments.onCartRequested,
                  onProductAdded: arguments.onProductAdded,
                ),
              ),
        );
      }

      return _fadeRoute(
        settings: settings,
        builder:
            (_) => const Scaffold(
              body: Center(child: Text(AppStrings.productDataUnavailable)),
            ),
      );
    case ProductsView.routeName:
      final shopModel = settings.arguments;
      if (shopModel is ShopModel) {
        return _fadeRoute(
          settings: settings,
          builder: (_) => ProductsView(shopModel: shopModel),
        );
      }
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => const Scaffold(
              body: Center(child: Text(AppStrings.shopDataUnavailable)),
            ),
      );
    default:
      return _fadeRoute(
        settings: settings,
        builder: (_) => const AuthGateView(),
      );
  }
}

String? _shopIdFromCartArguments(CartViewArguments? arguments) {
  final shopId =
      arguments?.shopModel?.id?.trim() ?? arguments?.product?.shopId.trim();
  if (shopId == null || shopId.isEmpty) {
    return null;
  }

  return shopId;
}

String? _shopIdFromProductDetailsArguments(
  ProductDetailsViewArguments arguments,
) {
  final shopId =
      arguments.shopModel?.id?.trim() ?? arguments.product.shopId.trim();
  if (shopId.isEmpty) {
    return null;
  }

  return shopId;
}

Route<dynamic> _fadeRoute({
  required RouteSettings settings,
  required WidgetBuilder builder,
}) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _CartCubitProvider extends StatelessWidget {
  const _CartCubitProvider({required this.child, this.shopId});

  final Widget child;
  final String? shopId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartCubit>.value(
      value: _currentUserCartCubit(shopId),
      child: child,
    );
  }
}

class _CartFlowProviders extends StatelessWidget {
  const _CartFlowProviders({required this.child, this.shopId});

  final Widget child;
  final String? shopId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>.value(value: _currentUserCartCubit(shopId)),
        BlocProvider<AddressCubit>(create: (_) => getIt<AddressCubit>()),
      ],
      child: child,
    );
  }
}

CartCubit _currentUserCartCubit(String? shopId) {
  final cubit = getIt<CartCubitRegistry>().forUser(
    requireAuthenticatedUserId(),
  );
  unawaited(cubit.restoreSavedCart(shopId: shopId));
  return cubit;
}
