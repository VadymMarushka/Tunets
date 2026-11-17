import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/services/crash_reporter.dart';
import '../../../core/strings/app_strings.dart';
import '../../../data/repositories/auth_failure.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_form_event.dart';
part 'auth_form_state.dart';

/// State of one auth form: sign in (S-1), registration (S-2) or password
/// reset (S-3). Each screen creates its own instance.
///
/// initial → loading → success | failure. On success after sign in or
/// registration, `AuthBloc` gets the new user from the auth stream and
/// `AuthGate` opens the app.
class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  AuthFormBloc({
    required this._auth,
    required this._analytics,
    required this._crashes,
  }) : super(const AuthFormState.initial()) {
    on<SignInSubmitted>(_onSignIn);
    on<RegisterSubmitted>(_onRegister);
    on<PasswordResetRequested>(_onPasswordReset);
  }

  final AuthRepository _auth;
  final AnalyticsService _analytics;
  final CrashReporter _crashes;

  Future<void> _onSignIn(SignInSubmitted event, Emitter<AuthFormState> emit) =>
      _run(emit, reason: 'sign_in', () async {
        await _auth.signIn(email: event.email, password: event.password);
        _analytics.logLogin();
        return const AuthFormState.success();
      });

  Future<void> _onRegister(
    RegisterSubmitted event,
    Emitter<AuthFormState> emit,
  ) => _run(emit, reason: 'sign_up', () async {
    await _auth.signUp(
      name: event.name,
      email: event.email,
      password: event.password,
    );
    _analytics.logSignUp();
    return const AuthFormState.success();
  });

  Future<void> _onPasswordReset(
    PasswordResetRequested event,
    Emitter<AuthFormState> emit,
  ) => _run(emit, reason: 'password_reset', () async {
    final email = event.email.trim();
    await _auth.sendPasswordReset(email: email);
    _analytics.logEvent(AnalyticsEvents.passwordResetRequested);
    return AuthFormState.success(email: email);
  });

  /// Emits `loading`, runs [request] and emits its result, or `failure`
  /// with a message the user can read.
  Future<void> _run(
    Emitter<AuthFormState> emit,
    Future<AuthFormState> Function() request, {
    required String reason,
  }) async {
    if (state.isLoading) return;
    emit(const AuthFormState.loading());
    try {
      emit(await request());
    } on AuthFailure catch (e) {
      emit(AuthFormState.failure(e.message));
    } catch (e, stack) {
      _crashes.recordError(e, stack, reason: reason);
      emit(const AuthFormState.failure(AppStrings.unexpectedError));
    }
  }
}
