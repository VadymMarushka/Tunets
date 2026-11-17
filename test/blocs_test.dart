import 'package:bloc_test/bloc_test.dart';
import 'package:fishing_diary/app/bloc/auth_bloc.dart';
import 'package:fishing_diary/app/bloc/theme_bloc.dart';
import 'package:fishing_diary/core/services/analytics_service.dart';
import 'package:fishing_diary/core/services/crash_reporter.dart';
import 'package:fishing_diary/data/models/trip.dart';
import 'package:fishing_diary/data/models/user_profile.dart';
import 'package:fishing_diary/data/repositories/settings_repository.dart';
import 'package:fishing_diary/data/repositories/trips_repository.dart';
import 'package:fishing_diary/features/auth/bloc/auth_form_bloc.dart';
import 'package:fishing_diary/features/profile/bloc/profile_bloc.dart';
import 'package:fishing_diary/features/trips/bloc/trips_bloc.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Business logic of every bloc, without any UI: events go in, the
/// expected sequence of states comes out.
void main() {
  const analytics = NoopAnalyticsService();
  const crashes = NoopCrashReporter();
  const vadym = UserProfile(uid: 'u1', name: 'Vadym', email: 'v@example.com');

  Trip trip(String id, DateTime date, {String waterBody = 'Lake Svitiaz'}) =>
      Trip(
        id: id,
        dateTime: date,
        waterBody: waterBody,
        weather: const Weather(
          temperatureC: 15,
          pressureHpa: 1015,
          windDirection: 'N',
          windSpeed: 2,
        ),
      );

  final older = trip('a', DateTime(2026, 5, 1));
  final newer = trip('b', DateTime(2026, 6, 1));

  group('AuthBloc', () {
    late FakeAuthRepository auth;

    blocTest<AuthBloc, AuthState>(
      'follows the session: signed out → signed in → signed out',
      build: () {
        auth = FakeAuthRepository();
        return AuthBloc(auth: auth, analytics: analytics);
      },
      act: (bloc) async {
        bloc.add(const AuthSubscriptionRequested());
        await Future<void>.delayed(Duration.zero);
        // Signing in happens elsewhere (AuthFormBloc); this bloc only
        // follows the repository's stream.
        await auth.signIn(
          email: 'v@example.com',
          password: FakeAuthRepository.password,
        );
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AuthSignOutRequested());
      },
      expect: () => [
        const AuthState.unauthenticated(),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user?.name, 'name', 'Vadym'),
        const AuthState.unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a restored session goes straight to authenticated',
      build: () => AuthBloc(
        auth: FakeAuthRepository(signedIn: vadym),
        analytics: analytics,
      ),
      act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
      expect: () => [const AuthState.authenticated(vadym)],
    );
  });

  group('AuthFormBloc', () {
    AuthFormBloc build() => AuthFormBloc(
      auth: FakeAuthRepository(),
      analytics: analytics,
      crashes: crashes,
    );

    blocTest<AuthFormBloc, AuthFormState>(
      'sign in: loading → success',
      build: build,
      act: (bloc) => bloc.add(
        const SignInSubmitted(
          email: 'v@example.com',
          password: FakeAuthRepository.password,
        ),
      ),
      expect: () => [
        const AuthFormState.loading(),
        const AuthFormState.success(),
      ],
    );

    blocTest<AuthFormBloc, AuthFormState>(
      'wrong password: loading → failure with a readable message',
      build: build,
      act: (bloc) => bloc.add(
        const SignInSubmitted(
          email: 'v@example.com',
          password: FakeAuthRepository.wrongPassword,
        ),
      ),
      expect: () => [
        const AuthFormState.loading(),
        const AuthFormState.failure('Incorrect email or password. Try again.'),
      ],
    );

    blocTest<AuthFormBloc, AuthFormState>(
      'registration: loading → success',
      build: build,
      act: (bloc) => bloc.add(
        const RegisterSubmitted(
          name: 'Olena',
          email: 'olena@example.com',
          password: 'fishing2026',
        ),
      ),
      expect: () => [
        const AuthFormState.loading(),
        const AuthFormState.success(),
      ],
    );

    blocTest<AuthFormBloc, AuthFormState>(
      'password reset: success carries the trimmed email',
      build: build,
      act: (bloc) =>
          bloc.add(const PasswordResetRequested(email: ' v@example.com ')),
      expect: () => [
        const AuthFormState.loading(),
        const AuthFormState.success(email: 'v@example.com'),
      ],
    );
  });

  group('ProfileBloc', () {
    ProfileBloc build() => ProfileBloc(
      auth: FakeAuthRepository(signedIn: vadym),
      analytics: analytics,
      crashes: crashes,
    );

    blocTest<ProfileBloc, ProfileState>(
      'loads the user, then saves a new name',
      build: build,
      act: (bloc) => bloc
        ..add(const ProfileStarted())
        ..add(const ProfileNameSaved('  Vadym M.  ')),
      expect: () => [
        isA<ProfileState>().having((s) => s.user, 'user', vadym),
        isA<ProfileState>().having(
          (s) => s.action,
          'action',
          ProfileAction.savingName,
        ),
        isA<ProfileState>()
            .having((s) => s.user?.name, 'name', 'Vadym M.')
            .having((s) => s.action, 'action', ProfileAction.none)
            .having((s) => s.result?.isSuccess, 'success', true),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'wrong current password ends with an error result',
      build: build,
      seed: () => const ProfileState(user: vadym),
      act: (bloc) => bloc.add(
        const ProfilePasswordChangeRequested(
          currentPassword: 'not-mine',
          newPassword: 'brand-new-pass',
        ),
      ),
      expect: () => [
        isA<ProfileState>().having(
          (s) => s.action,
          'action',
          ProfileAction.changingPassword,
        ),
        isA<ProfileState>()
            .having((s) => s.result?.isSuccess, 'success', false)
            .having(
              (s) => s.result?.message,
              'message',
              'The current password is incorrect.',
            ),
      ],
    );
  });

  group('TripsBloc', () {
    late FakeTripsRepository repository;

    setUp(() => repository = FakeTripsRepository(seed: [older, newer]));

    TripsBloc build() => TripsBloc(trips: repository, crashes: crashes);

    List<String> ids(TripsState state) => [for (final t in state.trips) t.id];

    blocTest<TripsBloc, TripsState>(
      'sign-in loads the trips, newest first',
      build: build,
      act: (bloc) => bloc.add(const TripsUserChanged('u1')),
      expect: () => [
        isA<TripsState>().having(
          (s) => s.status,
          'status',
          TripsStatus.loading,
        ),
        isA<TripsState>()
            .having((s) => s.status, 'status', TripsStatus.success)
            .having(ids, 'ids', ['b', 'a']),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'create, update and delete go through the repository',
      build: build,
      act: (bloc) async {
        bloc.add(const TripsUserChanged('u1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(TripSaved(trip('c', DateTime(2026, 7, 1))));
        await Future<void>.delayed(Duration.zero);
        bloc.add(TripSaved(trip('a', DateTime(2026, 5, 1), waterBody: 'Pond')));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TripDeleted('b'));
      },
      skip: 2, // loading + the first list
      expect: () => [
        isA<TripsState>().having(ids, 'after create', ['c', 'b', 'a']),
        isA<TripsState>()
            .having(ids, 'after update', ['c', 'b', 'a'])
            .having((s) => s.byId('a')?.waterBody, 'updated', 'Pond'),
        isA<TripsState>().having(ids, 'after delete', ['c', 'a']),
      ],
      verify: (_) async {
        final stored = await repository.loadTrips('u1');
        expect(stored.map((t) => t.id), unorderedEquals(['a', 'c']));
      },
    );

    blocTest<TripsBloc, TripsState>(
      'a load error becomes the failure state',
      build: () {
        repository.failWith = const TripsFailure('No access to the disk.');
        return build();
      },
      act: (bloc) => bloc.add(const TripsUserChanged('u1')),
      expect: () => [
        isA<TripsState>().having(
          (s) => s.status,
          'status',
          TripsStatus.loading,
        ),
        isA<TripsState>()
            .having((s) => s.status, 'status', TripsStatus.failure)
            .having((s) => s.error, 'error', 'No access to the disk.'),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'a failed save keeps the list and reports the error',
      build: build,
      act: (bloc) async {
        bloc.add(const TripsUserChanged('u1'));
        await Future<void>.delayed(Duration.zero);
        repository.failWith = const TripsFailure("Couldn't save your trips.");
        bloc.add(TripSaved(trip('c', DateTime(2026, 7, 1))));
      },
      skip: 2,
      expect: () => [
        isA<TripsState>()
            .having((s) => s.status, 'status', TripsStatus.success)
            .having(ids, 'ids', ['b', 'a'])
            .having((s) => s.error, 'error', "Couldn't save your trips."),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'sign-out clears the list',
      build: build,
      act: (bloc) async {
        bloc.add(const TripsUserChanged('u1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TripsUserChanged(null));
      },
      skip: 2,
      expect: () => [
        isA<TripsState>()
            .having((s) => s.status, 'status', TripsStatus.initial)
            .having((s) => s.trips, 'trips', isEmpty),
      ],
    );
  });

  group('ThemeBloc', () {
    setUp(initTestPrefs);

    blocTest<ThemeBloc, ThemeState>(
      'a new mode is applied and saved in SharedPreferences',
      build: () => ThemeBloc(SettingsRepository(testPrefs)),
      act: (bloc) => bloc.add(const ThemeModeChanged(ThemeMode.dark)),
      expect: () => [const ThemeState(ThemeMode.dark)],
      verify: (_) {
        expect(testPrefs.getString(SettingsRepository.themeModeKey), 'dark');
      },
    );

    test('starts with the saved mode', () async {
      await initTestPrefs({SettingsRepository.themeModeKey: 'light'});
      final bloc = ThemeBloc(SettingsRepository(testPrefs));
      expect(bloc.state, const ThemeState(ThemeMode.light));
      await bloc.close();
    });
  });
}
