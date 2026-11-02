// PLATFORM-SPECIFIC CODE: Firebase Crashlytics on Android, Sentry on Windows
// (Crashlytics has no Windows implementation).

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Error and crash reporting.
abstract interface class CrashReporter {
  /// Reports an error. Non-fatal errors are ones the app handled and kept
  /// working after; fatal ones are uncaught errors.
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  });

  /// Error caught by the Flutter framework (build, layout, gestures...).
  Future<void> recordFlutterError(FlutterErrorDetails details);

  /// Breadcrumb attached to later reports. Never put passwords or tokens here.
  Future<void> log(String message);

  /// Links reports to a user (Firebase uid), `null` after sign out.
  Future<void> setUser(String? uid);

  /// Crashes the app on purpose to check the integration.
  void testCrash();
}

// ===== Android (Material 3) =====

class CrashlyticsReporter implements CrashReporter {
  CrashlyticsReporter([FirebaseCrashlytics? crashlytics])
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) =>
      _crashlytics.recordError(error, stackTrace, reason: reason, fatal: fatal);

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) =>
      _crashlytics.recordFlutterFatalError(details);

  @override
  Future<void> log(String message) => _crashlytics.log(message);

  @override
  Future<void> setUser(String? uid) =>
      _crashlytics.setUserIdentifier(uid ?? '');

  /// Native crash: the app closes, the report is sent on the next launch.
  @override
  void testCrash() => _crashlytics.crash();
}

// ===== Windows (Fluent) =====

class SentryReporter implements CrashReporter {
  SentryReporter._();

  /// Returns `null` when no DSN was provided at build time.
  static Future<SentryReporter?> init(String dsn) async {
    if (dsn.isEmpty) return null;
    await SentryFlutter.init((options) {
      options.dsn = dsn;
      options.environment = kReleaseMode ? 'release' : 'debug';
      // Don't attach IP address or other personal data automatically.
      options.sendDefaultPii = false;
    });
    return SentryReporter._();
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) => Sentry.captureException(
    error,
    stackTrace: stackTrace,
    withScope: (scope) {
      scope.level = fatal ? SentryLevel.fatal : SentryLevel.error;
      if (reason != null) scope.setTag('reason', reason);
    },
  );

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) => recordError(
    details.exception,
    details.stack,
    reason: details.context?.toDescription(),
    fatal: true,
  );

  @override
  Future<void> log(String message) =>
      Sentry.addBreadcrumb(Breadcrumb(message: message));

  @override
  Future<void> setUser(String? uid) async => Sentry.configureScope(
    (scope) => scope.setUser(uid == null ? null : SentryUser(id: uid)),
  );

  /// Uncaught Dart error; reported by the global handler in main.dart.
  @override
  void testCrash() => throw StateError('Test crash from the Profile screen');
}

/// Used in tests and when crash reporting isn't configured.
class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async => debugPrint('[crash reporting disabled] $error');

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setUser(String? uid) async {}

  @override
  void testCrash() => throw StateError('Test crash');
}
