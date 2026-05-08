import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:makanak/features/auth/domain/entities/profile_entity.dart';
import 'package:makanak/features/auth/domain/repos/auth_repo.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepo) : super(const AuthLoading());

  final AuthRepo _authRepo;

  StreamSubscription<supa.AuthState>? _authStateSubscription;
  bool _isInitialized = false;
  bool _isAuthRequestInProgress = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _isAuthRequestInProgress = true;
    emit(const AuthLoading());

    _authStateSubscription = _authRepo.authStateChanges().listen((authState) {
      unawaited(
        _handleAuthStateChange(authState).catchError((_) {
          // Keep auth stream failures from breaking the app session.
        }),
      );
    });

    try {
      final session = _authRepo.getCurrentSession();
      if (session == null) {
        emit(const AuthUnauthenticated());
        return;
      }
      await _emitAuthenticatedState(session);
    } finally {
      _isAuthRequestInProgress = false;
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (_isAuthRequestInProgress) return;

    _isAuthRequestInProgress = true;
    emit(
      const AuthLoading(
        message: AppStrings.authSignInLoading,
        operation: AuthLoadingOperation.signIn,
      ),
    );
    try {
      final result = await _authRepo.signInWithEmailPassword(
        email: email,
        password: password,
      );
      _consumeAuthResult(result);
    } finally {
      _isAuthRequestInProgress = false;
    }
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
  }) async {
    if (_isAuthRequestInProgress) return;

    _isAuthRequestInProgress = true;
    emit(
      const AuthLoading(
        message: AppStrings.authSignUpLoading,
        operation: AuthLoadingOperation.signUp,
      ),
    );
    try {
      final result = await _authRepo.signUpWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
      );
      _consumeAuthResult(result);
    } finally {
      _isAuthRequestInProgress = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (_isAuthRequestInProgress) return;

    _isAuthRequestInProgress = true;
    emit(
      const AuthLoading(
        message: AppStrings.authGoogleLoading,
        operation: AuthLoadingOperation.google,
      ),
    );
    try {
      final result = await _authRepo.signInWithGoogle();
      _consumeAuthResult(result);
    } finally {
      _isAuthRequestInProgress = false;
    }
  }

  Future<void> signOut() async {
    if (_isAuthRequestInProgress) return;

    _isAuthRequestInProgress = true;
    emit(
      const AuthLoading(
        message: AppStrings.authSignOutLoading,
        operation: AuthLoadingOperation.signOut,
      ),
    );
    try {
      final result = await _authRepo.signOut();
      result.fold(
        (failure) =>
            emit(AuthUnauthenticated(message: failure.message, isError: true)),
        (_) {
          emit(const AuthUnauthenticated());
        },
      );
    } finally {
      _isAuthRequestInProgress = false;
    }
  }

  void clearMessage() {
    if (state is AuthUnauthenticated &&
        (state as AuthUnauthenticated).hasMessage) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _handleAuthStateChange(supa.AuthState authState) async {
    if (_isAuthRequestInProgress) {
      return;
    }

    switch (authState.event) {
      case supa.AuthChangeEvent.initialSession:
      case supa.AuthChangeEvent.signedIn:
      case supa.AuthChangeEvent.userUpdated:
      case supa.AuthChangeEvent.tokenRefreshed:
      case supa.AuthChangeEvent.mfaChallengeVerified:
        final session = authState.session;
        if (session == null) {
          emit(const AuthUnauthenticated());
          return;
        }
        await _emitAuthenticatedState(session);
        return;
      case supa.AuthChangeEvent.passwordRecovery:
        emit(
          const AuthUnauthenticated(
            message: AppStrings.authPasswordRecoveryMessage,
          ),
        );
        return;
      case supa.AuthChangeEvent.signedOut:
        emit(const AuthUnauthenticated());
        return;
      default:
        return;
    }
  }

  void _consumeAuthResult(Either<Failure, AuthOperationResult> result) {
    result.fold(
      (failure) =>
          emit(AuthUnauthenticated(message: failure.message, isError: true)),
      (authResult) {
        final session = authResult.session;
        if (session == null) {
          emit(
            AuthUnauthenticated(message: authResult.message, isError: false),
          );
          return;
        }

        final profile =
            authResult.profile ?? ProfileEntity(id: session.user.id);
        emit(AuthAuthenticated(profile: profile));
      },
    );
  }

  Future<void> _emitAuthenticatedState(supa.Session session) async {
    if (state is AuthAuthenticated &&
        (state as AuthAuthenticated).profile.id == session.user.id) {
      return;
    }

    final profileResult = await _authRepo.syncProfileForSession(session);
    profileResult.fold(
      (_) {
        final fallback = ProfileEntity(id: session.user.id);
        emit(AuthAuthenticated(profile: fallback));
      },
      (profile) {
        final resolved = profile ?? ProfileEntity(id: session.user.id);
        emit(AuthAuthenticated(profile: resolved));
      },
    );
  }

  @override
  Future<void> close() async {
    await _authStateSubscription?.cancel();
    return super.close();
  }
}
