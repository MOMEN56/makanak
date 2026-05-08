import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/services/service_locator.dart';
import 'package:makanak/features/profile/presentation/views/widgets/profile_view_body.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const String routeName = 'profile';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddressCubit>.value(
      value: getIt<AddressCubit>(),
      child: const Scaffold(body: ProfileViewBody()),
    );
  }
}