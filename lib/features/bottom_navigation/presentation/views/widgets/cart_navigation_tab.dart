import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/core/utils/app_spacing.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/views/cart_view.dart';

class CartNavigationTab extends StatelessWidget {
  const CartNavigationTab({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartCubit>.value(
      value: getIt<CartCubit>(),
      child: CartView(
        bottomContentPadding:
            AppSpacing.buttonBottomExtraGapWithLiquidGlassNavigation,
        onBack: onBack,
      ),
    );
  }
}
