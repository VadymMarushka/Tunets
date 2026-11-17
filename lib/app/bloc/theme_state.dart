part of 'theme_bloc.dart';

final class ThemeState {
  const ThemeState(this.mode);

  final ThemeMode mode;

  @override
  bool operator ==(Object other) => other is ThemeState && other.mode == mode;

  @override
  int get hashCode => mode.hashCode;
}
