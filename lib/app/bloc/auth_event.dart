part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

/// Start following the session (sent once, when the bloc is created).
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
