import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:makanak/core/utils/app_keys.dart';

typedef GoogleNativeSignInResult =
    ({GoogleSignInAuthentication authentication, String? fullName});

class GoogleSignInService {
  GoogleSignInService()
    : _webClientId = AppKeys.googleWebClientId.trim(),
      _iosClientId = AppKeys.googleIosClientId.trim() {
    _googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: _webClientId.isEmpty ? null : _webClientId,
      clientId: _iosClientId.isEmpty ? null : _iosClientId,
    );
  }

  final String _webClientId;
  final String _iosClientId;

  late final GoogleSignIn _googleSignIn;

  bool get supportsNativeSignIn {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  bool get hasNativeServerClientId => _webClientId.isNotEmpty;

  Future<GoogleNativeSignInResult?> signIn() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final authentication = await googleUser.authentication;
    return (authentication: authentication, fullName: googleUser.displayName);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
