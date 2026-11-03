import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import 'auth_failure.dart';

/// Authentication and account management (FR-1, FR-2).
///
/// Screens talk to this interface only, so they don't depend on Firebase
/// directly (and tests can pass a fake). Every method throws [AuthFailure]
/// with a user-facing message when the operation fails.
abstract interface class AuthRepository {
  /// Current user, or `null` when signed out. Emits the current state on
  /// listen, then on sign in / sign out and profile changes.
  Stream<UserProfile?> userChanges();

  UserProfile? get currentUser;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> sendPasswordReset({required String email});

  Future<void> signOut();

  /// Updates the display name and/or photo. Pass [clearPhoto] to remove it.
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    bool clearPhoto = false,
  });

  /// Confirms [currentPassword] (re-authentication) and sets [newPassword].
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

/// [AuthRepository] backed by Firebase Authentication (email/password).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Profile edits don't trigger `userChanges` on every platform (Windows),
  /// so the repository re-emits the user itself after an update.
  final _profileUpdated = StreamController<void>.broadcast();

  @override
  Stream<UserProfile?> userChanges() {
    late final StreamController<UserProfile?> controller;
    StreamSubscription<User?>? firebaseSub;
    StreamSubscription<void>? updateSub;
    controller = StreamController<UserProfile?>(
      onListen: () {
        firebaseSub = _auth.userChanges().listen(
          (user) => controller.add(_toProfile(user)),
          onError: controller.addError,
        );
        updateSub = _profileUpdated.stream.listen(
          (_) => controller.add(currentUser),
        );
      },
      onCancel: () async {
        await firebaseSub?.cancel();
        await updateSub?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  UserProfile? get currentUser => _toProfile(_auth.currentUser);

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) => _guard(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    await credential.user?.reload();
    _profileUpdated.add(null);
  });

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() async {
        try {
          await _auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          if (_isWrongCredentials(e)) throw AuthFailure.wrongCredentials;
          rethrow;
        }
      });

  @override
  Future<void> sendPasswordReset({required String email}) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    bool clearPhoto = false,
  }) => _guard(() async {
    final user = _requireUser();
    if (displayName != null) await user.updateDisplayName(displayName.trim());
    if (clearPhoto) {
      await user.updatePhotoURL(null);
    } else if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
    await user.reload();
    _profileUpdated.add(null);
  });

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _guard(() async {
    final user = _requireUser();
    // Firebase requires a recent sign-in for password changes
    // (`requires-recent-login`). Re-authenticating with the current
    // password satisfies that and also checks the user knows it.
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (_isWrongCredentials(e)) {
        throw const AuthFailure(
          'The current password is incorrect.',
          code: 'wrong-current-password',
        );
      }
      rethrow;
    }
    await user.updatePassword(newPassword);
  });

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure(
        'You are signed out. Sign in again.',
        code: 'no-current-user',
      );
    }
    return user;
  }

  /// Whether a sign-in (or re-authentication) was rejected because of a
  /// wrong email or password. The Windows SDK doesn't recognise the
  /// server's reply for this case and may report it as `unknown-error`
  /// without details; connection problems have their own code there.
  static bool _isWrongCredentials(FirebaseAuthException e) {
    final code = AuthFailure.codeOf(e);
    return AuthFailure.isWrongCredentials(code) || code == 'unknown-error';
  }

  /// Runs a Firebase call and converts its errors into [AuthFailure].
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebase(e);
    }
  }

  static UserProfile? _toProfile(User? user) {
    if (user == null) return null;
    final email = user.email ?? '';
    final displayName = user.displayName?.trim() ?? '';
    return UserProfile(
      uid: user.uid,
      email: email,
      name: displayName.isNotEmpty ? displayName : email.split('@').first,
      photoUrl: user.photoURL,
    );
  }
}
