import 'package:flutter/material.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_gate_view_body.dart';

class AuthGateView extends StatelessWidget {
  const AuthGateView({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AuthGateViewBody());
  }
}
