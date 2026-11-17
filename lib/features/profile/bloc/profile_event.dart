part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

/// The profile screen opened: load the user's data.
final class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

final class ProfileNameSaved extends ProfileEvent {
  const ProfileNameSaved(this.name);

  final String name;
}

/// A new photo was picked; `null` removes the photo.
final class ProfilePhotoChanged extends ProfileEvent {
  const ProfilePhotoChanged(this.photoUrl);

  final String? photoUrl;
}

final class ProfilePasswordChangeRequested extends ProfileEvent {
  const ProfilePasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}
