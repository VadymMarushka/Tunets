part of 'trips_bloc.dart';

enum TripsStatus {
  /// Nobody is signed in yet.
  initial,
  loading,

  /// [TripsState.trips] holds the user's trips.
  success,

  /// The list couldn't be loaded ([TripsState.error] says why).
  failure,
}

final class TripsState {
  const TripsState({
    this.status = TripsStatus.initial,
    this.trips = const [],
    this.error,
  });

  final TripsStatus status;

  /// Newest first.
  final List<Trip> trips;

  /// Why the last operation failed: loading (with [TripsStatus.failure])
  /// or saving / deleting (the list stays as it was).
  final String? error;

  Trip? byId(String id) {
    for (final trip in trips) {
      if (trip.id == id) return trip;
    }
    return null;
  }
}
