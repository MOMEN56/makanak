import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';

class AuthFormStateData {
  const AuthFormStateData({
    required this.authCubit,
    required this.isLoading,
    required this.loadingOperation,
    required this.messageState,
  });

  final AuthCubit authCubit;
  final bool isLoading;
  final AuthLoadingOperation? loadingOperation;
  final AuthUnauthenticated? messageState;
}

class AuthFormStateBuilder extends StatelessWidget {
  const AuthFormStateBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, AuthFormStateData data) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: _shouldRebuildAuthForm,
      builder: (context, state) {
        final data = AuthFormStateData(
          authCubit: context.read<AuthCubit>(),
          isLoading: state is AuthLoading,
          loadingOperation: state is AuthLoading ? state.operation : null,
          messageState:
              state is AuthUnauthenticated && state.hasMessage ? state : null,
        );

        return builder(context, data);
      },
    );
  }
}

bool _shouldRebuildAuthForm(AuthState previous, AuthState current) {
  return _isLoading(previous) != _isLoading(current) ||
      _loadingOperation(previous) != _loadingOperation(current) ||
      _messageState(previous) != _messageState(current);
}

bool _isLoading(AuthState state) => state is AuthLoading;

AuthLoadingOperation? _loadingOperation(AuthState state) {
  return state is AuthLoading ? state.operation : null;
}

AuthUnauthenticated? _messageState(AuthState state) {
  return state is AuthUnauthenticated && state.hasMessage ? state : null;
}
