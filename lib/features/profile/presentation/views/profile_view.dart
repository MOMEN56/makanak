import 'package:flutter/material.dart';
import 'package:makanak/features/profile/presentation/views/widgets/profile_view_body.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const String routeName = 'profile';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ProfileViewBody());
  }
}
