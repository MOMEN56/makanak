import 'package:flutter/material.dart';
import 'package:makanak/features/profile/presentation/views/widgets/profile_view_body.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, this.addAddressBottomPadding = 0});

  static const String routeName = 'profile';
  final double addAddressBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileViewBody(addAddressBottomPadding: addAddressBottomPadding),
    );
  }
}
