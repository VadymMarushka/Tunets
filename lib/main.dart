import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app_providers.dart';
import 'app/tunets_app.dart';
import 'core/platform/platform_style.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crash_reporter.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/trips_repository.dart';
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

  if (PlatformStyle.isFluent) {
    // Windows: hide the system title bar; the app draws its own
    // (WindowFrame, as in the LR2 mockup). The window keeps its borders,
    // so it can still be resized.
    await windowManager.ensureInitialized();
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setMinimumSize(const Size(480, 560));
  }

  // Read the saved settings before the first frame, so the chosen theme
  // is there from the start (no flash of the system theme).
  final prefs = await SharedPreferences.getInstance();

  runApp(
    AppProviders(
      auth: FirebaseAuthRepository(),
      trips: LocalTripsRepository(),
      settings: SettingsRepository(prefs),
      analytics: analytics,
      crashes: crashes,
      child: TunetsApp(windowFrame: PlatformStyle.isFluent),
    ),
  );
}
