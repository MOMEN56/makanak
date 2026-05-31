import 'package:flutter/material.dart';
import 'package:makanak/features/app_remote_config/presentation/views/widgets/app_remote_config_gate_view_body.dart';

class AppRemoteConfigGateView extends StatelessWidget {
  const AppRemoteConfigGateView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppRemoteConfigGateViewBody(child: child);
  }
}
