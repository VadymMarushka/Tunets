part of 'profile_bloc.dart';

/// Request in progress (its button shows a spinner).
enum ProfileAction { none, savingName, changingPhoto, changingPassword }

/// Outcome of the last request, shown once as a notice.
final class ProfileResult {
  const ProfileResult(
    this.action,
    this.message, {
    this.kind = NoticeKind.success,
  });

  final ProfileAction action;
  final String message;
  final NoticeKind kind;

  bool get isSuccess => kind != NoticeKind.error;
}

final class ProfileState {
  const ProfileState({
    this.user,
    this.action = ProfileAction.none,
    this.result,
  });

  /// `null` until [ProfileStarted] loads it.
  final UserProfile? user;
  final ProfileAction action;
  final ProfileResult? result;

  bool get isLoading => user == null;

  /// Starts [action]; the previous result is cleared.
  ProfileState busy(ProfileAction action) =>
      ProfileState(user: user, action: action);

  /// Ends the current request with [result] (and the fresh [user]).
  ProfileState done(ProfileResult result, {UserProfile? user}) =>
      ProfileState(user: user ?? this.user, result: result);
}
