part of 'trips_bloc.dart';

sealed class TripsEvent {
  const TripsEvent();
}

/// Someone signed in (load their trips) or signed out (`null`: clear).
final class TripsUserChanged extends TripsEvent {
  const TripsUserChanged(this.userId);

  final String? userId;
}

/// Load the list again (the "Retry" button after an error).
final class TripsRequested extends TripsEvent {
  const TripsRequested();
}

/// Create a trip or update the one with the same id (form S-6).
final class TripSaved extends TripsEvent {
  const TripSaved(this.trip);

  final Trip trip;
}

final class TripDeleted extends TripsEvent {
  const TripDeleted(this.tripId);

  final String tripId;
}
