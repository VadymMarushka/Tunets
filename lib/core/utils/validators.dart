import '../strings/app_strings.dart';

/// Local form validation (before any request is sent). Each function
/// returns an error message, or `null` when the value is valid.
///
/// These checks only catch input mistakes; whether the account exists and
/// the password is right is decided by Firebase Authentication.
abstract final class Validators {
  static const minPasswordLength = 8;
  static const maxNameLength = 50;

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return AppStrings.nameRequired;
    if (name.length > maxNameLength) return AppStrings.nameTooLong;
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return AppStrings.emailRequired;
    if (!_email.hasMatch(email)) return AppStrings.emailInvalid;
    return null;
  }

  /// Sign in: only checks that something was entered (the length rule may
  /// have been different when the account was created).
  static String? passwordEntered(String? value) =>
      (value == null || value.isEmpty) ? AppStrings.passwordRequired : null;

  /// New password (registration, password change).
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value.length < minPasswordLength) return AppStrings.passwordTooShort;
    if (value.trim() != value) return AppStrings.passwordSpaces;
    return null;
  }

  /// Repeated password must match [original].
  static String? Function(String?) confirmPassword(
    String Function() original,
  ) => (value) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }
    if (value != original()) return AppStrings.passwordsDontMatch;
    return null;
  };
}
