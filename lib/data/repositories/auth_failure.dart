import 'package:firebase_auth/firebase_auth.dart';

/// Error from an auth operation, with a message that can be shown to the
/// user as is (instead of the technical exception text).
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code = 'unknown'});

  /// Maps Firebase error codes to clear messages.
  factory AuthFailure.fromFirebase(FirebaseAuthException e) {
    final message = switch (e.code) {
      // Wrong email/password. Firebase reports one generic code for both
      // (email enumeration protection), older SDKs report them separately.
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'INVALID_LOGIN_CREDENTIALS' =>
        "Couldn't sign in. Check your email and password.",
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
      _ => 'Something went wrong (${e.code}). Please try again.',
    };
    return AuthFailure(message, code: e.code);
  }

  final String code;
  final String message;

  @override
  String toString() => 'AuthFailure($code): $message';
}
