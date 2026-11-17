import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/analytics_service.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// App-wide session state (FR-1): who is signed in, if anyone.
///
/// Follows [AuthRepository.userChanges], so it also picks up the session
/// Firebase restores on launch and profile edits (name, photo).
/// `AuthGate` shows the splash, sign-in or the app depending on the state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this._auth, required this._analytics})
    : super(const AuthState.unknown()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final AuthRepository _auth;
  final AnalyticsService _analytics;

  /// Emits a new state for every value of the auth stream, for as long as
  /// the bloc lives.
  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) => emit.forEach<UserProfile?>(
    _auth.userChanges(),
    onData: (user) => user == null
        ? const AuthState.unauthenticated()
        : AuthState.authenticated(user),
    onError: (_, _) => const AuthState.unauthenticated(),
  );

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _analytics.logEvent(AnalyticsEvents.signOut);
    // The new (signed-out) state comes through the auth stream.
    await _auth.signOut();
  }
}

/// The signed-in user for the screens after sign-in. Widgets that read it
/// rebuild when the user changes (e.g. a new name or photo).
extension CurrentUserContext on BuildContext {
  UserProfile get currentUser =>
      select((AuthBloc bloc) => bloc.state.user) ??
      // Only seen for a frame while signing out.
      const UserProfile(name: '', email: '');
}
