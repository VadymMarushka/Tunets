import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

/// App settings kept on the device with SharedPreferences (key–value).
///
/// Currently only the theme: System / Light / Dark (Profile → Appearance).
class SettingsRepository {
  SettingsRepository(this._prefs);

  static const themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  /// Saved theme, or [ThemeMode.system] when nothing (or an unknown value)
  /// is stored.
  ThemeMode get themeMode {
    final name = _prefs.getString(themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(themeModeKey, mode.name);
}
