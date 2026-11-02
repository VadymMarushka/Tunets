import 'dart:async';

import 'package:fishing_diary/app/app_services.dart';
import 'package:fishing_diary/app/tunets_app.dart';
import 'package:fishing_diary/core/services/analytics_service.dart';
import 'package:fishing_diary/core/services/crash_reporter.dart';
import 'package:fishing_diary/data/models/user_profile.dart';
import 'package:fishing_diary/data/repositories/auth_failure.dart';
import 'package:fishing_diary/data/repositories/auth_repository.dart';
import 'package:flutter/widgets.dart';

/// In-memory [AuthRepository] for widget tests (no Firebase).
/// Accepts any credentials except the password [wrongPassword].
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({UserProfile? signedIn}) : _user = signedIn;

  static const password = 'fishing2026';
  static const wrongPassword = 'wrong-password';

  UserProfile? _user;
  final _changes = StreamController<UserProfile?>.broadcast();

  void _set(UserProfile? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  Stream<UserProfile?> userChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  UserProfile? get currentUser => _user;

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (password == wrongPassword) {
      throw const AuthFailure(
        "Couldn't sign in. Check your email and password.",
      );
    }
    _set(UserProfile(uid: 'u1', name: 'Vadym', email: email));
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async => _set(UserProfile(uid: 'u2', name: name, email: email));

  @override
  Future<void> sendPasswordReset({required String email}) async {}

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    bool clearPhoto = false,
  }) async {
    final user = _user!;
    _set(
      UserProfile(
        uid: user.uid,
        name: displayName ?? user.name,
        email: user.email,
        photoUrl: clearPhoto ? null : photoUrl ?? user.photoUrl,
      ),
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword != password) {
      throw const AuthFailure('The current password is incorrect.');
    }
  }
}

/// The app with fake services, as `main.dart` builds it with real ones.
Widget testApp({AuthRepository? auth}) => AppServices(
  auth: auth ?? FakeAuthRepository(),
  analytics: const NoopAnalyticsService(),
  crashes: const NoopCrashReporter(),
  child: const TunetsApp(),
);
