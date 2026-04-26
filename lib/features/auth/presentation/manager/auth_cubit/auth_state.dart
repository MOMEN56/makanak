import 'package:equatable/equatable.dart';
import 'package:makanak/features/auth/domain/entities/profile_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

enum AuthLoadingOperation { signIn, signUp, google, signOut }

class AuthLoading extends AuthState {
  const AuthLoading({this.message, this.operation});

  final String? message;
  final AuthLoadingOperation? operation;

  @override
  List<Object?> get props => [message, operation];
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.profile});

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.message, this.isError = false});

  final String? message;
  final bool isError;

  bool get hasMessage => message != null && message!.trim().isNotEmpty;

  @override
  List<Object?> get props => [message, isError];
}
