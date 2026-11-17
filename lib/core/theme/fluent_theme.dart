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
    // Pages lie on the lighter content layer, the pane and the title bar
    // on the mica backdrop (mockup).
    scaffoldBackgroundColor: p.layer,
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
    // Dialogs as in the mockup (.f-dialog): surface card with an outline,
    // 24 px insets, 20 px title, footer on surface-2 with two equal buttons.
    dialogTheme: ContentDialogThemeData(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          // Outline as a 1 px spread: a real border would be covered by the
          // footer background.
          BoxShadow(color: p.outline, spreadRadius: 1),
          BoxShadow(
            color: Color(p.isDark ? 0x99000000 : 0x38000000),
            blurRadius: 48,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsetsDirectional.all(24),
      titlePadding: const EdgeInsetsDirectional.only(bottom: 12),
      titleStyle: TextStyle(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: p.onSurface,
      ),
      actionsSpacing: 8,
      actionsDecoration: BoxDecoration(
        color: p.surface2,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      actionsPadding: const EdgeInsetsDirectional.all(24),
    ),
    navigationPaneTheme: NavigationPaneThemeData(
      // Transparent: the pane shows the window's mica gradient, the same
      // as the title bar (WindowFrame). The pane opened over the content
      // needs a solid color.
      backgroundColor: const Color(0x00000000),
      overlayBackgroundColor: p.mica.first,
      highlightColor: p.primary,
    ),
  );
}
