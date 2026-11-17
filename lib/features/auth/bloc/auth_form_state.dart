part of 'auth_form_bloc.dart';

enum AuthFormStatus { initial, loading, success, failure }

final class AuthFormState {
  const AuthFormState._(this.status, {this.message, this.email});

  const AuthFormState.initial() : this._(AuthFormStatus.initial);

  const AuthFormState.loading() : this._(AuthFormStatus.loading);

  /// [email] is where the reset link went (password reset only).
  const AuthFormState.success({String? email})
    : this._(AuthFormStatus.success, email: email);

  const AuthFormState.failure(String message)
    : this._(AuthFormStatus.failure, message: message);

  final AuthFormStatus status;

  /// Error text for the user (failure only).
  final String? message;

  final String? email;

  bool get isLoading => status == AuthFormStatus.loading;

  @override
  bool operator ==(Object other) =>
      other is AuthFormState &&
      other.status == status &&
      other.message == message &&
      other.email == email;

  @override
  int get hashCode => Object.hash(status, message, email);
}
