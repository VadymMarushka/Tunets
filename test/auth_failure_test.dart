import 'package:firebase_auth/firebase_auth.dart';
import 'package:fishing_diary/data/repositories/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';

/// Firebase error codes become clear messages, including the Windows SDK's
/// `unknown-error` that carries the real server code in its message.
void main() {
  AuthFailure map(String code, [String? message]) => AuthFailure.fromFirebase(
    FirebaseAuthException(code: code, message: message),
  );

  test('wrong email or password, any platform', () {
    for (final code in ['invalid-credential', 'wrong-password']) {
      expect(map(code).message, AuthFailure.wrongCredentials.message);
    }
    expect(
      map('unknown-error', 'INVALID_LOGIN_CREDENTIALS').message,
      AuthFailure.wrongCredentials.message,
    );
  });

  test('Windows unknown-error with a server code in the message', () {
    expect(map('unknown-error', 'EMAIL_EXISTS').code, 'email-already-in-use');
    expect(
      map('unknown-error', 'TOO_MANY_ATTEMPTS_TRY_LATER : Try again').code,
      'too-many-requests',
    );
  });

  test('unrecognised errors show a generic message without the code', () {
    final failure = map('unknown-error', 'An internal error has occurred.');
    expect(failure.message, 'Something went wrong. Please try again.');
    expect(failure.code, 'unknown-error');
  });
}
