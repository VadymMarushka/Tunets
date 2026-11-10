part of 'theme_bloc.dart';

sealed class ThemeEvent {
  const ThemeEvent();
}

/// The user picked System / Light / Dark in Profile → Appearance.
final class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.mode);

  final ThemeMode mode;
}
