// PLATFORM-SPECIFIC CODE: Firebase Analytics on Android, Aptabase on Windows
// (Firebase Analytics has no Windows implementation).

import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Product analytics: what users do in the app.
abstract interface class AnalyticsService {
  Future<void> logLogin();
  Future<void> logSignUp();
  Future<void> logScreen(String name);

  /// Custom event. [name] is snake_case, up to 40 characters.
  Future<void> logEvent(String name, [Map<String, Object>? parameters]);
}

/// Event names used across the app.
abstract final class AnalyticsEvents {
  static const passwordResetRequested = 'password_reset_requested';
  static const profileUpdated = 'profile_updated';
  static const profilePhotoChanged = 'profile_photo_changed';
  static const passwordChanged = 'password_changed';
  static const signOut = 'sign_out';
}

// ===== Android (Material 3) =====

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logLogin() => _analytics.logLogin(loginMethod: 'password');

  @override
  Future<void> logSignUp() => _analytics.logSignUp(signUpMethod: 'password');

  @override
  Future<void> logScreen(String name) =>
      _analytics.logScreenView(screenName: name, screenClass: name);

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) =>
      _analytics.logEvent(name: name, parameters: parameters);
}

// ===== Windows (Fluent) =====

class AptabaseAnalyticsService implements AnalyticsService {
  AptabaseAnalyticsService._();

  /// Returns `null` when no app key was provided at build time.
  static Future<AptabaseAnalyticsService?> init(String appKey) async {
    if (appKey.isEmpty) return null;
    await Aptabase.init(appKey);
    return AptabaseAnalyticsService._();
  }

  // Same names as the recommended Firebase events.
  @override
  Future<void> logLogin() => logEvent('login', {'method': 'password'});

  @override
  Future<void> logSignUp() => logEvent('sign_up', {'method': 'password'});

  @override
  Future<void> logScreen(String name) =>
      logEvent('screen_view', {'screen_name': name});

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) =>
      Aptabase.instance.trackEvent(name, parameters);
}

/// Used in tests and when analytics isn't configured.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logLogin() async {}

  @override
  Future<void> logSignUp() async {}

  @override
  Future<void> logScreen(String name) async {}

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    debugPrint('[analytics disabled] $name $parameters');
  }
}
