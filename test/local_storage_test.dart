import 'dart:io';

import 'package:fishing_diary/data/models/catch_entry.dart';
import 'package:fishing_diary/data/models/trip.dart';
import 'package:fishing_diary/data/repositories/settings_repository.dart';
import 'package:fishing_diary/data/repositories/trips_repository.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Data kept on the device: trips in a JSON file per user, the theme in
/// SharedPreferences.
void main() {
  final seed = [
    Trip(
      id: 'seed-1',
      dateTime: DateTime(2026, 9, 21, 6, 30),
      waterBody: 'Lake Svitiaz',
      weather: const Weather(
        temperatureC: 14,
        pressureHpa: 1016,
        windDirection: 'NW',
        windSpeed: 3,
      ),
      tackle: const ['Spinning rod 2.4 m'],
      catches: const [CatchEntry(species: 'Pike', weightKg: 2.3, count: 1)],
      notes: 'Calm morning.',
    ),
  ];

  group('LocalTripsRepository', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('tunets_test_');
    });
    tearDown(() => dir.delete(recursive: true));

    /// A fresh repository (empty cache) over the same folder — like the app
    /// after a restart.
    LocalTripsRepository open() =>
        LocalTripsRepository(directory: () async => dir, seed: seed);

    File fileOf(String uid) =>
        File('${dir.path}${Platform.pathSeparator}trips_$uid.json');

    test('first load returns the demo trips and creates the file', () async {
      final trips = await open().loadTrips('u1');
      expect(trips.map((t) => t.id), ['seed-1']);
      expect(fileOf('u1').existsSync(), isTrue);
    });

    test('saved trips survive a restart, every field intact', () async {
      final trip = Trip(
        id: 'new',
        dateTime: DateTime(2026, 11, 10, 7, 45),
        waterBody: 'Dnister River',
        weather: const Weather(
          temperatureC: -2,
          pressureHpa: 1030,
          windDirection: '',
          windSpeed: 0,
        ),
        tackle: const ['Feeder 3.6 m', 'Hook #10'],
        catches: const [
          CatchEntry(species: 'Roach', weightKg: 0.25, count: 7),
          CatchEntry(species: 'Bream', weightKg: 1.4, count: 1),
        ],
        notes: 'Ice on the bank.',
      );
      await open().saveTrip('u1', trip);

      final loaded = (await open().loadTrips('u1'))
          .firstWhere((t) => t.id == 'new');
      expect(loaded.toJson(), trip.toJson());
      expect(loaded.totalKg, closeTo(3.15, 1e-9));
    });

    test('update replaces by id, delete removes', () async {
      final repo = open();
      final edited = Trip.fromJson({
        ...seed.first.toJson(),
        'waterBody': 'Shatsk Pond',
      });
      await repo.saveTrip('u1', edited);
      var trips = await open().loadTrips('u1');
      expect(trips, hasLength(1));
      expect(trips.single.waterBody, 'Shatsk Pond');

      await repo.deleteTrip('u1', 'seed-1');
      trips = await open().loadTrips('u1');
      expect(trips, isEmpty);
    });

    test('each user has a separate file', () async {
      final repo = open();
      await repo.deleteTrip('u1', 'seed-1');
      expect(await repo.loadTrips('u1'), isEmpty);
      expect((await repo.loadTrips('u2')).map((t) => t.id), ['seed-1']);
      expect(fileOf('u2').existsSync(), isTrue);
    });

    test('a damaged file is reported as TripsFailure', () async {
      await fileOf('u1').writeAsString('{not json');
      expect(open().loadTrips('u1'), throwsA(isA<TripsFailure>()));
    });
  });

  group('SettingsRepository', () {
    test('theme defaults to system and is saved', () async {
      await initTestPrefs();
      final settings = SettingsRepository(testPrefs);
      expect(settings.themeMode, ThemeMode.system);

      await settings.setThemeMode(ThemeMode.dark);
      expect(settings.themeMode, ThemeMode.dark);
      expect(testPrefs.getString(SettingsRepository.themeModeKey), 'dark');
    });

    test('an unknown stored value falls back to system', () async {
      await initTestPrefs({SettingsRepository.themeModeKey: 'sepia'});
      expect(SettingsRepository(testPrefs).themeMode, ThemeMode.system);
    });
  });
}
