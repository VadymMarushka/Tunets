import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app/app_services.dart';
import 'app/tunets_app.dart';
import 'core/platform/platform_style.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crash_reporter.dart';
import 'data/repositories/auth_repository.dart';
import 'firebase_options.dart';

/// Keys for the Windows services, passed at build time:
/// `flutter run --dart-define-from-file=env.json` (see env.example.json).
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');
const _aptabaseAppKey = String.fromEnvironment('APTABASE_APP_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase (Auth on both platforms; Analytics and Crashlytics on Android).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final AnalyticsService analytics;
  final CrashReporter crashes;
  if (PlatformStyle.isFluent) {
    // Windows: Firebase Analytics and Crashlytics are not available there.
    analytics =
        await AptabaseAnalyticsService.init(_aptabaseAppKey) ??
        const NoopAnalyticsService();
    crashes =
        await SentryReporter.init(_sentryDsn) ?? const NoopCrashReporter();
  } else {
    analytics = FirebaseAnalyticsService();
    crashes = CrashlyticsReporter();
  }

  // Errors caught by the Flutter framework (build, layout, callbacks).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    crashes.recordFlutterError(details);
  };
  // Uncaught asynchronous errors outside the framework.
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) debugPrint('Uncaught error: $error\n$stack');
    crashes.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    AppServices(
      auth: FirebaseAuthRepository(),
      analytics: analytics,
      crashes: crashes,
      child: const TunetsApp(),
    ),
  );
}
