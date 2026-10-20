/// One kind of fish caught during a trip (a trip has 0…N entries).
class CatchEntry {
  const CatchEntry({
    required this.species,
    required this.weightKg,
    required this.count,
  });

  final String species;

  /// Weight of a single fish.
  final double weightKg;
  final int count;

  double get totalKg => weightKg * count;
}
