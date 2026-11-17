part of 'auth_bloc.dart';

enum AuthStatus {
  /// Firebase is still restoring the saved session (splash screen).
  unknown,
  authenticated,
  unauthenticated,
}

final class AuthState {
  const AuthState._(this.status, [this.user]);

  const AuthState.unknown() : this._(AuthStatus.unknown);

  const AuthState.authenticated(UserProfile user)
    : this._(AuthStatus.authenticated, user);

  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated);

  final AuthStatus status;

  /// The signed-in user; `null` unless [status] is `authenticated`.
  final UserProfile? user;

  @override
  bool operator ==(Object other) =>
      other is AuthState && other.status == status && other.user == user;

  @override
  int get hashCode => Object.hash(status, user);
}
