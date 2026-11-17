import 'catch_entry.dart';

class Weather {
  const Weather({
    required this.temperatureC,
    required this.pressureHpa,
    required this.windDirection,
    required this.windSpeed,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    temperatureC: json['temperatureC'] as int,
    pressureHpa: json['pressureHpa'] as int,
    windDirection: json['windDirection'] as String,
    windSpeed: json['windSpeed'] as int,
  );

  final int temperatureC;
  final int pressureHpa;

  /// Compass point (N, NE…); empty when not set.
  final String windDirection;

  /// Wind speed in m/s.
  final int windSpeed;

  String get temperatureLabel => '$temperatureC°C';
  String get pressureLabel => '$pressureHpa hPa';
  String get windLabel => '$windDirection $windSpeed m/s'.trim();

  Map<String, dynamic> toJson() => {
    'temperatureC': temperatureC,
    'pressureHpa': pressureHpa,
    'windDirection': windDirection,
    'windSpeed': windSpeed,
  };
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

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    waterBody: json['waterBody'] as String,
    weather: Weather.fromJson(json['weather'] as Map<String, dynamic>),
    tackle: [for (final t in json['tackle'] as List) t as String],
    catches: [
      for (final c in json['catches'] as List)
        CatchEntry.fromJson(c as Map<String, dynamic>),
    ],
    notes: json['notes'] as String? ?? '',
  );

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'waterBody': waterBody,
    'weather': weather.toJson(),
    'tackle': tackle,
    'catches': [for (final c in catches) c.toJson()],
    'notes': notes,
  };
}
