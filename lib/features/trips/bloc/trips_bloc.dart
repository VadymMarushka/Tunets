import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/crash_reporter.dart';
import '../../../core/strings/app_strings.dart';
import '../../../data/models/trip.dart';
import '../../../data/repositories/trips_repository.dart';

part 'trips_event.dart';
part 'trips_state.dart';

/// The signed-in user's trips (FR-3, FR-4): loading the list and
/// create / update / delete. Home, the trips list, details and the form
/// all read this one bloc, so a change shows up on every screen at once.
class TripsBloc extends Bloc<TripsEvent, TripsState> {
  TripsBloc({required this._trips, required this._crashes})
    : super(const TripsState()) {
    on<TripsUserChanged>(_onUserChanged);
    on<TripsRequested>(_onRequested);
    on<TripSaved>(_onSaved);
    on<TripDeleted>(_onDeleted);
  }

  final TripsRepository _trips;
  final CrashReporter _crashes;

  /// Whose trips are shown; `null` when signed out.
  String? _userId;

  Future<void> _onUserChanged(
    TripsUserChanged event,
    Emitter<TripsState> emit,
  ) async {
    if (event.userId == _userId) return;
    _userId = event.userId;
    if (_userId == null) {
      emit(const TripsState());
      return;
    }
    await _load(emit);
  }

  Future<void> _onRequested(TripsRequested event, Emitter<TripsState> emit) =>
      _load(emit);

  Future<void> _onSaved(TripSaved event, Emitter<TripsState> emit) =>
      _change(emit, (userId) => _trips.saveTrip(userId, event.trip));

  Future<void> _onDeleted(TripDeleted event, Emitter<TripsState> emit) =>
      _change(emit, (userId) => _trips.deleteTrip(userId, event.tripId));

  Future<void> _load(Emitter<TripsState> emit) async {
    final userId = _userId;
    if (userId == null) return;
    emit(TripsState(status: TripsStatus.loading, trips: state.trips));
    try {
      final trips = await _trips.loadTrips(userId);
      // Another user may have signed in while this one was loading.
      if (userId != _userId) return;
      emit(TripsState(status: TripsStatus.success, trips: _sorted(trips)));
    } catch (e, stack) {
      if (userId != _userId) return;
      emit(TripsState(status: TripsStatus.failure, error: _message(e)));
      if (e is! TripsFailure) {
        _crashes.recordError(e, stack, reason: 'load_trips');
      }
    }
  }

  /// Runs a save / delete, then shows the stored list. On failure the list
  /// stays as it was and [TripsState.error] is set (shown as a notice).
  Future<void> _change(
    Emitter<TripsState> emit,
    Future<void> Function(String userId) change,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await change(userId);
      final trips = await _trips.loadTrips(userId);
      if (userId != _userId) return;
      emit(TripsState(status: TripsStatus.success, trips: _sorted(trips)));
    } catch (e, stack) {
      if (userId != _userId) return;
      emit(
        TripsState(
          status: state.status,
          trips: state.trips,
          error: _message(e),
        ),
      );
      if (e is! TripsFailure) {
        _crashes.recordError(e, stack, reason: 'save_trip');
      }
    }
  }

  static List<Trip> _sorted(List<Trip> trips) =>
      List.of(trips)..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  static String _message(Object error) =>
      error is TripsFailure ? error.message : AppStrings.unexpectedError;
}
