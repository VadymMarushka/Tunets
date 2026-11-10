import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/services/analytics_service.dart';
import '../core/services/crash_reporter.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/trips_repository.dart';
import '../features/trips/bloc/trips_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/theme_bloc.dart';

/// Dependency injection for the whole app.
///
/// * `RepositoryProvider`s give every widget and bloc the data sources and
///   services: `context.read<AuthRepository>()`.
/// * `BlocProvider`s create the app-wide blocs. They sit **above**
///   `MaterialApp` / `FluentApp`, because the trip form and dialogs open on
///   the root navigator, next to (not under) the home page, and still need
///   them.
///
/// `main.dart` passes the real implementations, tests pass fakes.
class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.auth,
    required this.trips,
    required this.settings,
    required this.analytics,
    required this.crashes,
    required this.child,
  });

  final AuthRepository auth;
  final TripsRepository trips;
  final SettingsRepository settings;
  final AnalyticsService analytics;
  final CrashReporter crashes;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: auth),
        RepositoryProvider<TripsRepository>.value(value: trips),
        RepositoryProvider<SettingsRepository>.value(value: settings),
        RepositoryProvider<AnalyticsService>.value(value: analytics),
        RepositoryProvider<CrashReporter>.value(value: crashes),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              auth: context.read<AuthRepository>(),
              analytics: context.read<AnalyticsService>(),
            )..add(const AuthSubscriptionRequested()),
          ),
          BlocProvider(
            create: (context) => ThemeBloc(context.read<SettingsRepository>()),
          ),
          BlocProvider(
            create: (context) => TripsBloc(
              trips: context.read<TripsRepository>(),
              crashes: context.read<CrashReporter>(),
            ),
          ),
        ],
        child: _SessionSync(child: child),
      ),
    );
  }
}

/// Keeps the other blocs and services in step with the session: loads the
/// signed-in user's trips (clears them on sign out) and links crash reports
/// to the user (uid only, no email).
class _SessionSync extends StatelessWidget {
  const _SessionSync({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.user?.uid != current.user?.uid,
      listener: (context, state) {
        final uid = state.user?.uid;
        context.read<TripsBloc>().add(TripsUserChanged(uid));
        context.read<CrashReporter>().setUser(uid);
      },
      child: child,
    );
  }
}
