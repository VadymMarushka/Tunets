import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/services/crash_reporter.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/widgets/dialogs.dart' show NoticeKind;
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/auth_failure.dart';
import '../../../data/repositories/auth_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Profile screen (S-8, FR-2): loads the user's data, saves the name and
/// photo, changes the password. One request at a time; each ends with a
/// [ProfileResult] that the screen shows as a notice.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this._auth,
    required this._analytics,
    required this._crashes,
  }) : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileNameSaved>(_onNameSaved);
    on<ProfilePhotoChanged>(_onPhotoChanged);
    on<ProfilePasswordChangeRequested>(_onPasswordChange);
  }

  final AuthRepository _auth;
  final AnalyticsService _analytics;
  final CrashReporter _crashes;

  void _onStarted(ProfileStarted event, Emitter<ProfileState> emit) {
    emit(ProfileState(user: _auth.currentUser));
  }

  Future<void> _onNameSaved(
    ProfileNameSaved event,
    Emitter<ProfileState> emit,
  ) async {
    final name = event.name.trim();
    if (name == state.user?.name) {
      emit(
        state.done(
          const ProfileResult(
            ProfileAction.savingName,
            AppStrings.nameUnchanged,
            kind: NoticeKind.info,
          ),
        ),
      );
      return;
    }
    await _run(
      emit,
      ProfileAction.savingName,
      () => _auth.updateProfile(displayName: name),
      success: AppStrings.profileSaved,
      analyticsEvent: AnalyticsEvents.profileUpdated,
    );
  }

  Future<void> _onPhotoChanged(
    ProfilePhotoChanged event,
    Emitter<ProfileState> emit,
  ) {
    final url = event.photoUrl;
    return _run(
      emit,
      ProfileAction.changingPhoto,
      () => url == null
          ? _auth.updateProfile(clearPhoto: true)
          : _auth.updateProfile(photoUrl: url),
      success: url == null ? AppStrings.photoRemoved : AppStrings.photoUpdated,
      analyticsEvent: AnalyticsEvents.profilePhotoChanged,
    );
  }

  Future<void> _onPasswordChange(
    ProfilePasswordChangeRequested event,
    Emitter<ProfileState> emit,
  ) => _run(
    emit,
    ProfileAction.changingPassword,
    () => _auth.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    ),
    success: AppStrings.passwordUpdated,
    analyticsEvent: AnalyticsEvents.passwordChanged,
  );

  /// busy(action) → request → done(success | error).
  Future<void> _run(
    Emitter<ProfileState> emit,
    ProfileAction action,
    Future<void> Function() request, {
    required String success,
    required String analyticsEvent,
  }) async {
    if (state.action != ProfileAction.none) return;
    emit(state.busy(action));
    try {
      await request();
      _analytics.logEvent(analyticsEvent);
      emit(state.done(ProfileResult(action, success), user: _auth.currentUser));
    } on AuthFailure catch (e) {
      emit(
        state.done(ProfileResult(action, e.message, kind: NoticeKind.error)),
      );
    } catch (e, stack) {
      _crashes.recordError(e, stack, reason: 'profile_${action.name}');
      emit(
        state.done(
          ProfileResult(
            action,
            AppStrings.unexpectedError,
            kind: NoticeKind.error,
          ),
        ),
      );
    }
  }
}
