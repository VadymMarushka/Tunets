/// One kind of fish caught during a trip (a trip has 0…N entries).
class CatchEntry {
  const CatchEntry({
    required this.species,
    required this.weightKg,
    required this.count,
  });

  factory CatchEntry.fromJson(Map<String, dynamic> json) => CatchEntry(
    species: json['species'] as String,
    weightKg: (json['weightKg'] as num).toDouble(),
    count: json['count'] as int,
  );

  final String species;

  /// Weight of a single fish.
  final double weightKg;
  final int count;

  double get totalKg => weightKg * count;

  Map<String, dynamic> toJson() => {
    'species': species,
    'weightKg': weightKg,
    'count': count,
  };
}
