part of 'auth_form_bloc.dart';

sealed class AuthFormEvent {
  const AuthFormEvent();
}

/// "Sign in" pressed on S-1 (the form is already validated).
final class SignInSubmitted extends AuthFormEvent {
  const SignInSubmitted({required this.email, required this.password});

  final String email;
  final String password;
}

/// "Register" pressed on S-2.
final class RegisterSubmitted extends AuthFormEvent {
  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;
}

/// "Send reset link" pressed on S-3.
final class PasswordResetRequested extends AuthFormEvent {
  const PasswordResetRequested({required this.email});

  final String email;
}
