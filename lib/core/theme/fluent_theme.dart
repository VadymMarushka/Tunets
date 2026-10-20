import 'package:fluent_ui/fluent_ui.dart';

import 'app_colors.dart';

/// Brand accent (sea teal) expressed as a Fluent accent swatch.
///
/// Fluent paints controls with the `dark` shade in the light theme and the
/// `lighter` shade in the dark theme, so those two match the mockup's
/// primary colors exactly.
final AccentColor brandAccent = AccentColor.swatch(const <String, Color>{
  'darkest': Color(0xFF05504C),
  'darker': Color(0xFF086561),
  'dark': Color(0xFF0B7A75),
  'normal': Color(0xFF14918B),
  'light': Color(0xFF3DB3AB),
  'lighter': Color(0xFF6FD6CE),
  'lightest': Color(0xFF9FE6E0),
});

/// Fluent Design theme for Windows.
///
/// Deliberate deviation (documented in LR2): the brand palette replaces the
/// standard Windows accent colors so both platforms look like one product.
FluentThemeData buildFluentTheme(Brightness brightness) {
  final p = AppPalette.forBrightness(brightness);

  return FluentThemeData(
    brightness: brightness,
    accentColor: brandAccent,
    // Windows UI font (LR2). Set explicitly so it is the same everywhere.
    fontFamily: 'Segoe UI',
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: p.background,
    micaBackgroundColor: p.mica.first,
    cardColor: p.surface,
    menuColor: p.surface,
    // Pane uses the brand "mica" tint instead of the neutral Windows gray,
    // so it matches the window backdrop of the auth screens.
    // Subtle scrollbars: translucent thumb instead of the solid gray one,
    // barely visible track on hover.
    scrollbarTheme: ScrollbarThemeData(
      scrollbarColor: p.onSurface.withValues(alpha: 0.25),
      scrollbarPressingColor: p.onSurface.withValues(alpha: 0.45),
      backgroundColor: p.subtleHover,
    ),
    navigationPaneTheme: NavigationPaneThemeData(
      backgroundColor: p.mica.first,
      overlayBackgroundColor: p.mica.first,
      highlightColor: p.primary,
    ),
  );
}
