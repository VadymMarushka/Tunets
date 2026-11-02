import 'package:flutter/widgets.dart';

import '../core/services/analytics_service.dart';
import '../core/services/crash_reporter.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/auth_repository.dart';

/// Gives screens access to the repositories and services created in
/// `main.dart`: `AppServices.of(context).auth.signIn(...)`.
class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    required this.auth,
    required this.analytics,
    required this.crashes,
    required super.child,
  });

  final AuthRepository auth;
  final AnalyticsService analytics;
  final CrashReporter crashes;

  static AppServices of(BuildContext context) {
    final services = context.getInheritedWidgetOfExactType<AppServices>();
    assert(services != null, 'AppServices is missing above this widget');
    return services!;
  }

  @override
  bool updateShouldNotify(AppServices oldWidget) =>
      auth != oldWidget.auth ||
      analytics != oldWidget.analytics ||
      crashes != oldWidget.crashes;
}

/// Signed-in user for the screens after sign-in (provided by `AuthGate`).
/// Widgets that read it rebuild when the name or photo changes.
class CurrentUser extends InheritedWidget {
  const CurrentUser({super.key, required this.user, required super.child});

  final UserProfile user;

  static UserProfile of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CurrentUser>();
    assert(scope != null, 'CurrentUser is only available after sign-in');
    return scope!.user;
  }

  @override
  bool updateShouldNotify(CurrentUser oldWidget) =>
      user.uid != oldWidget.user.uid ||
      user.name != oldWidget.user.name ||
      user.email != oldWidget.user.email ||
      user.photoUrl != oldWidget.user.photoUrl;
}
