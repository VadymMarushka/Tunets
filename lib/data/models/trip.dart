import 'catch_entry.dart';

class Weather {
  const Weather({
    required this.temperatureC,
    required this.pressureHpa,
    required this.windDirection,
    required this.windSpeed,
  });

  final int temperatureC;
  final int pressureHpa;
  final String windDirection;

  /// Wind speed in m/s.
  final int windSpeed;

  String get temperatureLabel => '$temperatureC°C';
  String get pressureLabel => '$pressureHpa hPa';
  String get windLabel => '$windDirection $windSpeed m/s';
}

/// A fishing trip record (FR-4).
class Trip {
  const Trip({
    required this.id,
    required this.dateTime,
    required this.waterBody,
    required this.weather,
    this.tackle = const [],
    this.catches = const [],
    this.notes = '',
  });

  final String id;
  final DateTime dateTime;
  final String waterBody;
  final Weather weather;
  final List<String> tackle;
  final List<CatchEntry> catches;
  final String notes;

  bool get hasCatch => catches.isNotEmpty;

  int get fishCount => catches.fold(0, (sum, c) => sum + c.count);

  double get totalKg => catches.fold(0.0, (sum, c) => sum + c.totalKg);
}
