import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_cubit.dart';
import 'package:makanak/features/shops/presentation/views/widgets/shop_view_body.dart';

class ShopsView extends StatelessWidget {
  const ShopsView({super.key});

  static const String routeName = 'shops_list';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShopsCubit>()..fetchShops(),
      child: const Scaffold(body: ShopsViewBody()),
    );
  }
}
