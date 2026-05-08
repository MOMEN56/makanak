import 'package:flutter/services.dart';
import 'package:makanak/core/utils/app_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

abstract final class AuthErrorMapper {
  static String mapAuthError(
    supa.AuthException error, {
    bool isSignUp = false,
  }) {
    final message = error.message.toLowerCase();
    final code = error.code?.toLowerCase();

    if (code == 'over_email_send_rate_limit') {
      return AppStrings.authEmailSendRateLimit;
    }

    if (message.contains('invalid login credentials')) {
      return AppStrings.authInvalidCredentials;
    }

    if (message.contains('email not confirmed')) {
      return AppStrings.authEmailNotConfirmed;
    }

    if (message.contains('user already registered') ||
        message.contains('already been registered')) {
      return AppStrings.authUserAlreadyRegistered;
    }

    if (message.contains('password should be at least') ||
        message.contains('weak password')) {
      return AppStrings.authWeakPassword;
    }

    if (message.contains('network') || message.contains('socket')) {
      return AppStrings.authNetworkError;
    }

    if (message.contains('signup') &&
        (message.contains('disabled') || message.contains('not allowed'))) {
      return AppStrings.authSignUpDisabled;
    }

    if (message.contains('email') &&
        (message.contains('invalid') || message.contains('not valid'))) {
      return AppStrings.authInvalidEmail;
    }

    if (message.contains('rate limit') ||
        message.contains('too many') ||
        message.contains('security purposes')) {
      return AppStrings.authTooManyRequests;
    }

    if (message.contains('database') ||
        message.contains('saving') ||
        message.contains('trigger')) {
      return AppStrings.authProfileSyncError;
    }

    if (isSignUp) {
      return AppStrings.authSignUpFailed;
    }

    return AppStrings.authRequestFailed;
  }

  static String mapGooglePlatformError(PlatformException error) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();
    final details = '${error.details ?? ''}'.toLowerCase();
    final combined = '$code $message $details';

    if (combined.contains('10') || combined.contains('developer_error')) {
      return AppStrings.googleSignInStartLaterError;
    }

    if (combined.contains('12500') ||
        combined.contains('sign_in_failed') ||
        combined.contains('sign in failed')) {
      return AppStrings.googleSignInStartLaterError;
    }

    if (combined.contains('network')) {
      return AppStrings.googleSignInNetworkError;
    }

    return AppStrings.googleSignInStartLaterError;
  }
}
