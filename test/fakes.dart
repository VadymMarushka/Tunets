import 'dart:async';

import 'package:fishing_diary/app/app_providers.dart';
import 'package:fishing_diary/app/tunets_app.dart';
import 'package:fishing_diary/core/services/analytics_service.dart';
import 'package:fishing_diary/core/services/crash_reporter.dart';
import 'package:fishing_diary/data/mock/mock_data.dart';
import 'package:fishing_diary/data/models/trip.dart';
import 'package:fishing_diary/data/models/user_profile.dart';
import 'package:fishing_diary/data/repositories/auth_failure.dart';
import 'package:fishing_diary/data/repositories/auth_repository.dart';
import 'package:fishing_diary/data/repositories/settings_repository.dart';
import 'package:fishing_diary/data/repositories/trips_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// In-memory [TripsRepository]: every user starts with [seed] (the demo
/// trips by default). Set [failWith] to make every call throw it.
class FakeTripsRepository implements TripsRepository {
  FakeTripsRepository({List<Trip>? seed}) : _seed = seed ?? MockData.trips;

  final List<Trip> _seed;
  final _byUser = <String, List<Trip>>{};

  TripsFailure? failWith;

  List<Trip> _trips(String userId) =>
      _byUser.putIfAbsent(userId, () => List.of(_seed));

  void _check() {
    if (failWith != null) throw failWith!;
  }

  @override
  Future<List<Trip>> loadTrips(String userId) async {
    _check();
    return List.of(_trips(userId));
  }

  @override
  Future<void> saveTrip(String userId, Trip trip) async {
    _check();
    final trips = _trips(userId);
    final index = trips.indexWhere((t) => t.id == trip.id);
    if (index == -1) {
      trips.add(trip);
    } else {
      trips[index] = trip;
    }
  }

  @override
  Future<void> deleteTrip(String userId, String tripId) async {
    _check();
    _trips(userId).removeWhere((t) => t.id == tripId);
  }
}

/// SharedPreferences backed by memory; [initTestPrefs] resets it.
late SharedPreferences testPrefs;

Future<void> initTestPrefs([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  testPrefs = await SharedPreferences.getInstance();
}

/// The app with fake repositories and services, as `main.dart` builds it
/// with real ones. Call [initTestPrefs] first (e.g. in `setUp`).
Widget testApp({AuthRepository? auth, TripsRepository? trips}) => AppProviders(
  auth: auth ?? FakeAuthRepository(),
  trips: trips ?? FakeTripsRepository(),
  settings: SettingsRepository(testPrefs),
  analytics: const NoopAnalyticsService(),
  crashes: const NoopCrashReporter(),
  child: const TunetsApp(),
);
