import '../models/catch_entry.dart';
import '../models/trip.dart';
import '../models/user_profile.dart';

/// Hardcoded data for the UI prototype (no backend in this lab).
abstract final class MockData {
  static const user = UserProfile(name: 'Vadym', email: 'vadym@example.com');

  /// "Today" for the prototype, so filters and the summary match the mockup.
  static final today = DateTime(2026, 9, 29, 6, 30);

  static const waterBodies = ['Lake Svitiaz', 'Dnister River', 'Shatsk Pond'];

  static const species = [
    'Pike',
    'Perch',
    'Zander',
    'Bream',
    'Roach',
    'Carp',
    'Crucian carp',
  ];

  static const windDirections = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];

  static final trips = <Trip>[
    Trip(
      id: 'trip-1',
      dateTime: DateTime(2026, 9, 21, 6, 30),
      waterBody: 'Lake Svitiaz',
      weather: const Weather(
        temperatureC: 14,
        pressureHpa: 1016,
        windDirection: 'NW',
        windSpeed: 3,
      ),
      tackle: const ['Spinning rod 2.4 m', 'Wobbler 7 cm'],
      catches: const [
        CatchEntry(species: 'Pike', weightKg: 2.3, count: 1),
        CatchEntry(species: 'Perch', weightKg: 0.4, count: 5),
      ],
      notes:
          'Calm morning. Pike took the wobbler near the reeds on the north '
          'shore; perch were schooling at 3 m depth.',
    ),
    Trip(
      id: 'trip-2',
      dateTime: DateTime(2026, 9, 7, 7, 15),
      waterBody: 'Dnister River',
      weather: const Weather(
        temperatureC: 18,
        pressureHpa: 1009,
        windDirection: 'W',
        windSpeed: 5,
      ),
      tackle: const ['Feeder 3.6 m'],
      catches: const [
        CatchEntry(species: 'Bream', weightKg: 1.1, count: 2),
        CatchEntry(species: 'Roach', weightKg: 0.2, count: 8),
      ],
      notes: 'Bites came in waves; bream fed close to the bank.',
    ),
    Trip(
      id: 'trip-3',
      dateTime: DateTime(2026, 8, 24, 5, 45),
      waterBody: 'Shatsk Pond',
      weather: const Weather(
        temperatureC: 24,
        pressureHpa: 1012,
        windDirection: 'S',
        windSpeed: 1,
      ),
      tackle: const ['Float rod 5 m'],
      catches: const [
        CatchEntry(species: 'Crucian carp', weightKg: 0.6, count: 4),
      ],
      notes: 'Hot day, bites stopped after 10:00.',
    ),
    Trip(
      id: 'trip-4',
      dateTime: DateTime(2026, 8, 14, 19, 0),
      waterBody: 'Lake Svitiaz',
      weather: const Weather(
        temperatureC: 21,
        pressureHpa: 1014,
        windDirection: 'E',
        windSpeed: 2,
      ),
      tackle: const ['Spinning rod 2.4 m'],
      notes: 'No bites this evening. Try the south bay next time.',
    ),
  ];
}
