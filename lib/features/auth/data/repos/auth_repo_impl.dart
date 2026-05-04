import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/services/google_sign_in_service.dart';
import 'package:makanak/core/services/supabase_auth_service.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:makanak/features/auth/data/models/profile_model.dart';
import 'package:makanak/features/auth/data/utils/auth_error_mapper.dart';
import 'package:makanak/features/auth/data/utils/auth_logger.dart';
import 'package:makanak/features/auth/domain/entities/profile_entity.dart';
import 'package:makanak/features/auth/domain/repos/auth_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthRepoImpl implements AuthRepo {
  const AuthRepoImpl(
    this._authService,
    this._databaseService,
    this._googleSignInService,
  );

  final SupabaseAuthService _authService;
  final SupabaseDatabaseService _databaseService;
  final GoogleSignInService _googleSignInService;

  @override
  Stream<supa.AuthState> authStateChanges() => _authService.onAuthStateChange;

  @override
  supa.Session? getCurrentSession() => _authService.currentSession;

  @override
  Future<Either<Failure, AuthOperationResult>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      final session = response.session;
      if (session == null) {
        return left(
          const Failure('تعذر بدء الجلسة الآن. حاول مرة أخرى بعد قليل.'),
        );
      }

      return _buildAuthResult(session);
    } on supa.AuthException catch (error) {
      AuthLogger.logAuthException('Email sign-in', error);
      return left(Failure(AuthErrorMapper.mapAuthError(error)));
    } catch (_) {
      await _rollbackAuthSession();
      return left(
        const Failure('تعذر تسجيل الدخول الآن. حاول مرة أخرى بعد قليل.'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthOperationResult>> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
      );
      final session = response.session;
      if (session == null) {
        return right(
          const AuthOperationResult(
            message:
                'تم إنشاء الحساب بنجاح. راجعي بريدك الإلكتروني لتأكيد الحساب ثم سجلي الدخول.',
          ),
        );
      }

      return _buildAuthResult(session, fallbackFullName: fullName);
    } on supa.AuthException catch (error) {
      AuthLogger.logAuthException('Email sign-up', error);
      return left(Failure(AuthErrorMapper.mapAuthError(error, isSignUp: true)));
    } catch (_) {
      await _rollbackAuthSession();
      return left(
        const Failure('تعذر إنشاء الحساب الآن. حاول مرة أخرى بعد قليل.'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthOperationResult>> signInWithGoogle() async {
    if (_googleSignInService.supportsNativeSignIn &&
        _googleSignInService.hasNativeServerClientId) {
      return _signInWithGoogleNative();
    }

    if (_googleSignInService.supportsNativeSignIn) {
      AuthLogger.logAuthSetupIssue(
        'Google native sign-in is missing GOOGLE_WEB_CLIENT_ID; using OAuth fallback.',
      );
    }

    final fallbackResult = await _launchGoogleOAuthFallback();
    if (fallbackResult != null) return fallbackResult;

    return left(const Failure('تعذر بدء تسجيل الدخول بحساب Google الآن.'));
  }

  @override
  Future<Either<Failure, ProfileEntity?>> syncProfileForSession(
    supa.Session session,
  ) {
    return _syncProfileForSession(session);
  }

  Future<Either<Failure, AuthOperationResult>> _signInWithGoogleNative() async {
    if (!_googleSignInService.hasNativeServerClientId) {
      AuthLogger.logAuthSetupIssue(
        'Google native sign-in cannot start without GOOGLE_WEB_CLIENT_ID.',
      );
      return left(const Failure('تعذر بدء تسجيل الدخول بحساب Google الآن.'));
    }

    try {
      final nativeSignIn = await _googleSignInService.signIn();
      if (nativeSignIn == null) {
        return right(
          const AuthOperationResult(
            message: 'تم إلغاء تسجيل الدخول بحساب Google.',
          ),
        );
      }

      final accessToken = nativeSignIn.authentication.accessToken;
      final idToken = nativeSignIn.authentication.idToken;
      if (accessToken == null || idToken == null) {
        AuthLogger.logAuthSetupIssue(
          'Google native sign-in did not return accessToken/idToken.',
        );
        return left(
          const Failure('تعذر إكمال تسجيل الدخول بحساب Google الآن.'),
        );
      }

      final response = await _authService.signInWithGoogleTokens(
        accessToken: accessToken,
        idToken: idToken,
      );
      final session = response.session;
      if (session == null) {
        return left(
          const Failure('تعذر إكمال تسجيل الدخول بحساب Google الآن.'),
        );
      }

      return _buildAuthResult(session, fallbackFullName: nativeSignIn.fullName);
    } on PlatformException catch (error, stackTrace) {
      AuthLogger.logGooglePlatformException(error, stackTrace);
      if (_isGoogleCancellation(error)) {
        return right(
          const AuthOperationResult(
            message: 'تم إلغاء تسجيل الدخول بحساب Google.',
          ),
        );
      }
      return left(Failure(AuthErrorMapper.mapGooglePlatformError(error)));
    } on supa.AuthException catch (error) {
      return left(Failure(AuthErrorMapper.mapAuthError(error)));
    } catch (error, stackTrace) {
      AuthLogger.logUnexpectedGoogleSignInError(error, stackTrace);
      return left(
        const Failure('تعذر تسجيل الدخول بحساب Google الآن. حاول مرة أخرى.'),
      );
    }
  }

  Future<Either<Failure, ProfileEntity?>> _syncProfileForSession(
    supa.Session session, {
    String? fallbackFullName,
  }) async {
    try {
      final user = session.user;
      final existingProfileData = await _databaseService.fetchProfileById(
        user.id,
      );
      final existingProfile =
          existingProfileData == null
              ? null
              : ProfileModel.fromJson(existingProfileData);

      final profile = ProfileModel(
        id: user.id,
        fullName:
            _resolveFullName(user, fallbackFullName) ??
            existingProfile?.fullName,
        role: existingProfile?.role ?? 'customer',
      );

      final upsertedProfileData = await _databaseService.upsertProfile(
        profile.toJson(),
      );
      return right(ProfileModel.fromJson(upsertedProfileData));
    } on DatabaseException catch (e) {
      AuthLogger.logAuthException('syncProfile', supa.AuthException(e.message));
      return left(
        const Failure('تعذر تجهيز بيانات الحساب الآن. حاول مرة أخرى بعد قليل.'),
      );
    } catch (_) {
      return left(
        const Failure('تعذر تجهيز بيانات الحساب الآن. حاول مرة أخرى بعد قليل.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authService.signOut();
      await _googleSignInService.signOut();
      return right(null);
    } catch (_) {
      return left(
        const Failure('تعذر تسجيل الخروج الآن. حاول مرة أخرى بعد قليل.'),
      );
    }
  }

  Future<Either<Failure, AuthOperationResult>> _buildAuthResult(
    supa.Session session, {
    String? fallbackFullName,
  }) async {
    final profileResult = await _syncProfileForSession(
      session,
      fallbackFullName: fallbackFullName,
    );
    if (profileResult.isLeft()) {
      await _rollbackAuthSession();
    }
    return profileResult.fold(
      left,
      (profile) =>
          right(AuthOperationResult(profile: profile, session: session)),
    );
  }

  Future<void> _rollbackAuthSession() async {
    try {
      await _authService.signOut();
    } catch (_) {}

    try {
      await _googleSignInService.signOut();
    } catch (_) {}
  }

  Future<Either<Failure, AuthOperationResult>?>
  _launchGoogleOAuthFallback() async {
    try {
      final launched = await _authService.signInWithGoogleOAuthFallback();
      if (!launched) {
        return left(
          const Failure('تعذر فتح شاشة تسجيل الدخول بحساب Google الآن.'),
        );
      }

      return right(
        const AuthOperationResult(
          message: 'كمّلي تسجيل الدخول بحساب Google من الشاشة التي فُتحت.',
        ),
      );
    } on supa.AuthException catch (error) {
      return left(Failure(AuthErrorMapper.mapAuthError(error)));
    } catch (_) {
      await _rollbackAuthSession();
      return null;
    }
  }

  bool _isGoogleCancellation(PlatformException error) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();
    return code.contains('cancel') || message.contains('cancel');
  }

  String? _resolveFullName(supa.User user, String? fallbackFullName) {
    final metadata = user.userMetadata;
    final fullName = metadata?['full_name']?.toString().trim();
    final name = metadata?['name']?.toString().trim();
    final displayName = metadata?['display_name']?.toString().trim();
    final fallback = fallbackFullName?.trim();

    for (final candidate in [fullName, name, displayName, fallback]) {
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }

    return null;
  }
}
