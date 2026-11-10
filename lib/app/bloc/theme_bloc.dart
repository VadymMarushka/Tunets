import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/settings_repository.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// App theme: follows the system or is forced light / dark.
///
/// Starts with the mode saved in [SettingsRepository] (SharedPreferences),
/// so the choice survives restarts; every change is saved right away.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(this._settings) : super(ThemeState(_settings.themeMode)) {
    on<ThemeModeChanged>(_onModeChanged);
  }

  final SettingsRepository _settings;

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    // Update the UI first; saving is fast, but the theme shouldn't wait.
    emit(ThemeState(event.mode));
    await _settings.setThemeMode(event.mode);
  }
}
