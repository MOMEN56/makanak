import 'package:flutter/foundation.dart';
import 'package:makanak/core/utils/endpoints.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class SupabaseAuthService {
  const SupabaseAuthService(this._client);

  final supa.SupabaseClient _client;

  Stream<supa.AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;

  supa.Session? get currentSession => _client.auth.currentSession;

  Future<supa.AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<supa.AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (fullName != null && fullName.trim().isNotEmpty)
          'full_name': fullName.trim(),
      },
    );
  }

  Future<supa.AuthResponse> signInWithGoogleTokens({
    required String accessToken,
    required String idToken,
  }) {
    return _client.auth.signInWithIdToken(
      provider: supa.OAuthProvider.google,
      accessToken: accessToken,
      idToken: idToken,
    );
  }

  Future<bool> signInWithGoogleOAuthFallback() {
    return _client.auth.signInWithOAuth(
      supa.OAuthProvider.google,
      redirectTo: kIsWeb ? Uri.base.origin : Endpoints.mobileRedirectUrl,
      authScreenLaunchMode:
          kIsWeb
              ? supa.LaunchMode.platformDefault
              : supa.LaunchMode.inAppWebView,
      queryParams: const {'prompt': 'select_account'},
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}
