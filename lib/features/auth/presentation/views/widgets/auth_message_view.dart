import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:makanak/features/auth/presentation/views/widgets/auth_status_card.dart';

class AuthMessageView extends StatelessWidget {
  const AuthMessageView({super.key, required this.messageState});

  final AuthUnauthenticated? messageState;

  @override
  Widget build(BuildContext context) {
    final state = messageState;
    if (state == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(20),
        AuthStatusCard(message: state.message!, isError: state.isError),
      ],
    );
  }
}
