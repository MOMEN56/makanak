import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

abstract final class AuthLogger {
  static void logGooglePlatformException(
    PlatformException error,
    StackTrace stackTrace,
  ) {
    if (!kDebugMode) return;

    debugPrint(
      'Google sign-in PlatformException: '
      'code=${error.code}, message=${error.message}, details=${error.details}',
    );
    debugPrintStack(stackTrace: stackTrace);
  }

  static void logUnexpectedGoogleSignInError(
    Object error,
    StackTrace stackTrace,
  ) {
    if (!kDebugMode) return;

    debugPrint('Unexpected Google sign-in error: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  static void logAuthException(String operation, supa.AuthException error) {
    if (!kDebugMode) return;

    debugPrint(
      '$operation AuthException: '
      'message=${error.message}, statusCode=${error.statusCode}, code=${error.code}',
    );
  }

  static void logAuthSetupIssue(String message) {
    if (!kDebugMode) return;

    debugPrint('Auth setup issue: $message');
  }
}
