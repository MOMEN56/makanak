import 'package:flutter/services.dart';
import 'package:makanak/core/helper/print_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

abstract final class AuthLogger {
  static void logGooglePlatformException(
    PlatformException error,
    StackTrace stackTrace,
  ) {
    PrintHelper.error(
      'Google sign-in PlatformException.',
      error:
          'code=${error.code}, message=${error.message}, details=${error.details}',
      stackTrace: stackTrace,
      tag: 'Auth',
    );
  }

  static void logUnexpectedGoogleSignInError(
    Object error,
    StackTrace stackTrace,
  ) {
    PrintHelper.error(
      'Unexpected Google sign-in error.',
      error: error,
      stackTrace: stackTrace,
      tag: 'Auth',
    );
  }

  static void logAuthException(String operation, supa.AuthException error) {
    PrintHelper.error(
      '$operation AuthException.',
      error:
          'message=${error.message}, statusCode=${error.statusCode}, code=${error.code}',
      tag: 'Auth',
    );
  }

  static void logAuthSetupIssue(String message) {
    PrintHelper.warning('Auth setup issue: $message', tag: 'Auth');
  }
}
