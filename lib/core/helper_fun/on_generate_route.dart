import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/routing/app_route_arguments.dart';
import 'package:makanak/core/routing/route_error_view.dart';
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
import 'package:makanak/features/order_history/presentation/manager/order_details_cubit/order_details_cubit.dart';
import 'package:makanak/features/order_history/presentation/views/order_details_view.dart';
import 'package:makanak/features/order_history/presentation/views/order_history_view.dart';
import 'package:makanak/features/profile/presentation/views/profile_view.dart';
import 'package:makanak/features/shop/presentation/views/product_details_view.dart';
import 'package:makanak/features/shop/presentation/views/products_view.dart';
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
      if (arguments != null && arguments is! CartViewArguments) {
        return _invalidRoute(settings, AppStrings.routeDataUnavailable);
      }
      final cartArgs = arguments as CartViewArguments?;
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => _CartFlowProviders(
              shopId: cartArgs?.shopId,
              child: CartView(cartArguments: cartArgs),
            ),
      );
    case AddUserAddressView.routeName:
      final arguments = settings.arguments;
      if (arguments != null && arguments is! CartViewArguments) {
        return _invalidRoute(settings, AppStrings.routeDataUnavailable);
      }
      final cartArgs = arguments as CartViewArguments?;
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => _CartFlowProviders(
              shopId: cartArgs?.shopId,
              child: AddUserAddressView(cartArguments: cartArgs),
            ),
      );
    case ConfirmingOrderView.routeName:
      final arguments = settings.arguments;
      if (arguments != null && arguments is! CartViewArguments) {
        return _invalidRoute(settings, AppStrings.routeDataUnavailable);
      }
      final cartArgs = arguments as CartViewArguments?;
      return _fadeRoute(
        settings: settings,
        builder:
            (_) => _CartFlowProviders(
              shopId: cartArgs?.shopId,
              child: ConfirmingOrderView(cartArguments: cartArgs),
            ),
      );
    case SubmitOrderView.routeName:
      final arguments = settings.arguments;
      if (arguments != null && arguments is! CartViewArguments) {
        return _invalidRoute(settings, AppStrings.routeDataUnavailable);
      }
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
      if (arguments is OrderDetailsRouteArguments && arguments.isValid) {
        return _fadeRoute(
          settings: settings,
          builder:
              (_) => BlocProvider<OrderDetailsCubit>(
                create:
                    (_) =>
                        getIt<OrderDetailsCubit>()
                          ..fetchOrder(arguments.orderId),
                child: OrderDetailsView(orderId: arguments.orderId),
              ),
        );
      }
      return _invalidRoute(settings, AppStrings.orderDetailsUnavailable);
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

      if (arguments is ProductDetailsRouteArguments && arguments.isValid) {
        final shopId =
            arguments.shop?.shopId.trim().isNotEmpty == true
                ? arguments.shop!.shopId
                : arguments.product.shopId;

        return _fadeRoute(
          settings: settings,
          builder:
              (_) => _CartCubitProvider(
                shopId: shopId,
                child: ProductDetailsView(
                  product: arguments.product.toModel(),
                  primaryColor: arguments.primaryColor,
                  shopModel: arguments.shop?.toModel(),
                  initialQuantity: arguments.initialQuantity,
                  returnToCartTab: arguments.returnToCartTab,
                ),
              ),
        );
      }

      return _invalidRoute(settings, AppStrings.productDataUnavailable);
    case ProductsView.routeName:
      final arguments = settings.arguments;
      if (arguments is ProductsRouteArguments && arguments.isValid) {
        return _fadeRoute(
          settings: settings,
          builder:
              (_) => ProductsView(
                shopModel: arguments.shop.toModel(),
                initialNavigationIndex: arguments.initialNavigationIndex,
              ),
        );
      }
      return _invalidRoute(settings, AppStrings.shopDataUnavailable);
    default:
      return _invalidRoute(settings, AppStrings.routeNotFound);
  }
}

Route<dynamic> _invalidRoute(RouteSettings settings, String message) {
  return _fadeRoute(
    settings: settings,
    builder:
        (context) => RouteErrorView(
          message: '$message (${settings.name})',
          actionLabel: AppStrings.home,
          onActionPressed:
              () => Navigator.of(context).pushNamedAndRemoveUntil(
                AuthGateView.routeName,
                (route) => false,
              ),
        ),
  );
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
