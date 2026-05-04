import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/auth/presentation/views/auth_gate_view.dart';
import 'package:makanak/features/auth/presentation/views/sign_in_view.dart';
import 'package:makanak/features/auth/presentation/views/sign_up_view.dart';
import 'package:makanak/features/cart/data/models/cart_view_arguments.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/views/add_user_address_view.dart';
import 'package:makanak/features/cart/presentation/views/cart_view.dart';
import 'package:makanak/features/cart/presentation/views/confirming_order_view.dart';
import 'package:makanak/features/cart/presentation/views/submit_order_view.dart';
import 'package:makanak/features/shop/presentation/views/products_view.dart';
import 'package:makanak/features/shops/data/models/shop_model.dart';
import 'package:makanak/features/shops/presentation/views/shops_view.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AuthGateView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const AuthGateView(),
      );
    case SignInView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const SignInView(),
      );
    case SignUpView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const SignUpView(),
      );
    case CartView.routeName:
      final arguments = settings.arguments;
      return MaterialPageRoute(
        settings: settings,
        builder:
            (_) => _CartCubitProvider(
              child: CartView(
                cartArguments:
                    arguments is CartViewArguments ? arguments : null,
              ),
            ),
      );
    case AddUserAddressView.routeName:
      final arguments = settings.arguments;
      return MaterialPageRoute(
        settings: settings,
        builder:
            (_) => _CartCubitProvider(
              child: AddUserAddressView(
                cartArguments:
                    arguments is CartViewArguments ? arguments : null,
              ),
            ),
      );
    case ConfirmingOrderView.routeName:
      final arguments = settings.arguments;
      return MaterialPageRoute(
        settings: settings,
        builder:
            (_) => _CartCubitProvider(
              child: ConfirmingOrderView(
                cartArguments:
                    arguments is CartViewArguments ? arguments : null,
              ),
            ),
      );
    case SubmitOrderView.routeName:
      final arguments = settings.arguments;
      return MaterialPageRoute(
        settings: settings,
        builder:
            (_) => _CartCubitProvider(
              child: SubmitOrderView(
                cartArguments:
                    arguments is CartViewArguments ? arguments : null,
              ),
            ),
      );
    case ShopsView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const ShopsView(),
      );
    case ProductsView.routeName:
      final shopModel = settings.arguments;
      if (shopModel is ShopModel) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductsView(shopModel: shopModel),
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder:
            (_) => const Scaffold(
              body: Center(child: Text(AppStrings.shopDataUnavailable)),
            ),
      );
    default:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const AuthGateView(),
      );
  }
}

class _CartCubitProvider extends StatelessWidget {
  const _CartCubitProvider({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartCubit>.value(
      value: getIt<CartCubit>(),
      child: child,
    );
  }
}
