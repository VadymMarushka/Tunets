import 'package:firebase_auth/firebase_auth.dart';

/// Error from an auth operation, with a message that can be shown to the
/// user as is (instead of the technical exception text).
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code = 'unknown'});

  /// Wrong email or password.
  static const wrongCredentials = AuthFailure(
    "Couldn't sign in. Check your email and password.",
    code: 'invalid-credential',
  );

  /// Maps Firebase error codes to clear messages.
  factory AuthFailure.fromFirebase(FirebaseAuthException e) {
    final code = codeOf(e);
    if (isWrongCredentials(code)) return wrongCredentials;
    final message = switch (code) {
      'invalid-email' => 'The email address is not valid.',
      'user-disabled' => 'This account has been disabled.',
      'email-already-in-use' => 'An account with this email already exists.',
      'weak-password' => 'The password is too weak. Use at least 8 characters.',
      'too-many-requests' =>
        'Too many attempts. Wait a few minutes and try again.',
      'network-request-failed' =>
        'No connection to the server. Check your internet and try again.',
      'requires-recent-login' =>
        'For security, sign out and sign in again, then retry.',
      'operation-not-allowed' => 'Email sign-in is not enabled for this app.',
      _ => 'Something went wrong. Please try again.',
    };
    return AuthFailure(message, code: code);
  }

  /// The Firebase error code. On Windows the Firebase C++ SDK reports
  /// server errors it doesn't know as `unknown-error` and keeps the server
  /// code only in the message, so it's recovered from there.
  static String codeOf(FirebaseAuthException e) {
    if (e.code != 'unknown-error') return e.code;
    final message = e.message ?? '';
    for (final MapEntry(key: serverCode, value: code) in _serverCodes.entries) {
      if (message.contains(serverCode)) return code;
    }
    return e.code;
  }

  static const _serverCodes = {
    'INVALID_LOGIN_CREDENTIALS': 'invalid-credential',
    'INVALID_PASSWORD': 'wrong-password',
    'EMAIL_NOT_FOUND': 'user-not-found',
    'EMAIL_EXISTS': 'email-already-in-use',
    'WEAK_PASSWORD': 'weak-password',
    'TOO_MANY_ATTEMPTS_TRY_LATER': 'too-many-requests',
    'USER_DISABLED': 'user-disabled',
    'INVALID_EMAIL': 'invalid-email',
    'CREDENTIAL_TOO_OLD_LOGIN_AGAIN': 'requires-recent-login',
  };

  /// Firebase reports one generic code for a wrong email or password (email
  /// enumeration protection); older SDKs report them separately.
  static bool isWrongCredentials(String code) => const {
    'invalid-credential',
    'wrong-password',
    'user-not-found',
    'INVALID_LOGIN_CREDENTIALS',
  }.contains(code);

  final String code;
  final String message;

  @override
  String toString() => 'AuthFailure($code): $message';
}
