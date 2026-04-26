import 'package:flutter/material.dart';
import 'package:makanak/features/auth/presentation/views/widgets/sign_in_view_body.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  static const String routeName = 'sign-in';

  @override
  Widget build(BuildContext context) {
    return const SignInViewBody();
  }
}
