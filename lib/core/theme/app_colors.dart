import 'package:flutter/widgets.dart';

/// Color tokens shared by the Material and Fluent themes.
///
/// Values come from the design mockup (light and dark themes generated from
/// one base color — sea teal).
@immutable
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.surface,
    required this.surface2,
    required this.surfaceVariant,
    required this.onSurface,
    required this.secondaryText,
    required this.outline,
    required this.layerBorder,
    required this.subtleHover,
    required this.error,
    required this.success,
    required this.warning,
    required this.infoBackground,
    required this.errorBackground,
    required this.mica,
  });

  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color background;
  final Color surface;
  final Color surface2;
  final Color surfaceVariant;
  final Color onSurface;
  final Color secondaryText;
  final Color outline;
  final Color layerBorder;
  final Color subtleHover;
  final Color error;
  final Color success;
  final Color warning;
  final Color infoBackground;
  final Color errorBackground;

  /// Gradient used as the Windows window backdrop (Mica imitation).
  final List<Color> mica;

  bool get isDark => brightness == Brightness.dark;

  static const light = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFF0B7A75),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFBFEDE9),
    onPrimaryContainer: Color(0xFF00201E),
    background: Color(0xFFF6FAFA),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF0F6F5),
    surfaceVariant: Color(0xFFEAF4F3),
    onSurface: Color(0xFF10201F),
    secondaryText: Color(0xFF4A6360),
    outline: Color(0xFFC5D6D4),
    layerBorder: Color(0x1410201F),
    subtleHover: Color(0x0F10201F),
    error: Color(0xFFB3261E),
    success: Color(0xFF2E7D32),
    warning: Color(0xFF8A5300),
    infoBackground: Color(0xFFE3F2F1),
    errorBackground: Color(0xFFFDE7E9),
    mica: [Color(0xFFE4EFEE), Color(0xFFEEF3F3), Color(0xFFE8EEF2)],
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF6FD6CE),
    onPrimary: Color(0xFF00332F),
    primaryContainer: Color(0xFF005F59),
    onPrimaryContainer: Color(0xFFBFEDE9),
    background: Color(0xFF0E1717),
    surface: Color(0xFF162221),
    surface2: Color(0xFF1A2827),
    surfaceVariant: Color(0xFF1F2E2D),
    onSurface: Color(0xFFE2EEEC),
    secondaryText: Color(0xFFA9C0BD),
    outline: Color(0xFF3A4F4D),
    layerBorder: Color(0x12FFFFFF),
    subtleHover: Color(0x0FFFFFFF),
    error: Color(0xFFF2B8B5),
    success: Color(0xFF81C995),
    warning: Color(0xFFF5C77E),
    infoBackground: Color(0xFF15302E),
    errorBackground: Color(0xFF3B1D1C),
    mica: [Color(0xFF0C1616), Color(0xFF111A1B), Color(0xFF0E1519)],
  );

  static AppPalette forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// The theme follows the system setting, so the palette does too.
  static AppPalette of(BuildContext context) =>
      forBrightness(MediaQuery.platformBrightnessOf(context));
}
