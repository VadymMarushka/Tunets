import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../mock/mock_data.dart';
import '../models/trip.dart';

/// A trips operation failed (the file couldn't be read or written).
class TripsFailure implements Exception {
  const TripsFailure(this.message);

  final String message;

  @override
  String toString() => 'TripsFailure: $message';
}

/// Storage of the user's trip records (FR-4).
///
/// The BLoC works with this interface only, so the storage can change
/// (local file now, Cloud Firestore later) without touching the UI or BLoC.
/// Methods throw [TripsFailure] when the operation fails.
abstract interface class TripsRepository {
  /// All trips of [userId] (in no particular order).
  Future<List<Trip>> loadTrips(String userId);

  /// Adds [trip], or replaces the stored trip with the same id.
  Future<void> saveTrip(String userId, Trip trip);

  Future<void> deleteTrip(String userId, String tripId);
}

/// [TripsRepository] that keeps each user's trips in a JSON file on the
/// device: `<app support dir>/trips_<uid>.json` (Android and Windows).
///
/// A user without a file yet gets the demo trips from [MockData], so the
/// app isn't empty on the first launch.
class LocalTripsRepository implements TripsRepository {
  LocalTripsRepository({
    Future<Directory> Function()? directory,
    List<Trip>? seed,
  }) : _directory = directory ?? getApplicationSupportDirectory,
       _seed = seed ?? MockData.trips;

  final Future<Directory> Function() _directory;
  final List<Trip> _seed;

  /// Trips already read from disk, by user id.
  final _cache = <String, List<Trip>>{};

  /// Writes run one after another, so two quick saves can't overwrite each
  /// other's file.
  Future<void> _lastWrite = Future.value();

  Future<File> _file(String userId) async {
    final dir = await _directory();
    // The uid comes from Firebase (letters and digits), but keep the file
    // name safe anyway.
    final safeId = userId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return File('${dir.path}${Platform.pathSeparator}trips_$safeId.json');
  }

  @override
  Future<List<Trip>> loadTrips(String userId) async {
    final cached = _cache[userId];
    if (cached != null) return List.of(cached);
    try {
      final file = await _file(userId);
      final List<Trip> trips;
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString()) as List;
        trips = [
          for (final item in json) Trip.fromJson(item as Map<String, dynamic>),
        ];
      } else {
        trips = List.of(_seed);
        await _write(userId, trips);
      }
      _cache[userId] = trips;
      return List.of(trips);
    } on FileSystemException catch (e) {
      throw TripsFailure("Couldn't read your trips: ${e.message}");
    } on FormatException {
      throw const TripsFailure('The trips file is damaged.');
    }
  }

  @override
  Future<void> saveTrip(String userId, Trip trip) async {
    final trips = await loadTrips(userId);
    final index = trips.indexWhere((t) => t.id == trip.id);
    if (index == -1) {
      trips.add(trip);
    } else {
      trips[index] = trip;
    }
    await _write(userId, trips);
    _cache[userId] = trips;
  }

  @override
  Future<void> deleteTrip(String userId, String tripId) async {
    final trips = await loadTrips(userId)
      ..removeWhere((t) => t.id == tripId);
    await _write(userId, trips);
    _cache[userId] = trips;
  }

  Future<void> _write(String userId, List<Trip> trips) {
    final json = jsonEncode([for (final t in trips) t.toJson()]);
    final write = _lastWrite.then((_) async {
      try {
        final file = await _file(userId);
        await file.parent.create(recursive: true);
        await file.writeAsString(json, flush: true);
      } on FileSystemException catch (e) {
        throw TripsFailure("Couldn't save your trips: ${e.message}");
      }
    });
    // A failed write must not block the next ones.
    _lastWrite = write.catchError((_) {});
    return write;
  }
}
