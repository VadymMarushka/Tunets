import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Text styles shared by both design languages.
///
/// No font family is set here: it is inherited from the active theme
/// (Roboto on Android, Segoe UI on Windows).
abstract final class AppTextStyles {
  static TextStyle headline(BuildContext context) => TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w500,
    color: AppPalette.of(context).onSurface,
  );

  static TextStyle title(BuildContext context) => TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    color: AppPalette.of(context).onSurface,
  );

  static TextStyle subtitle(BuildContext context) => TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: AppPalette.of(context).onSurface,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: 14,
    height: 20 / 14,
    color: AppPalette.of(context).onSurface,
  );

  static TextStyle bodyStrong(BuildContext context) =>
      body(context).copyWith(fontWeight: FontWeight.w600);

  static TextStyle secondary(BuildContext context) =>
      body(context).copyWith(color: AppPalette.of(context).secondaryText);

  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: 12,
    height: 16 / 12,
    color: AppPalette.of(context).secondaryText,
  );

  static TextStyle label(BuildContext context) => TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppPalette.of(context).onSurface,
  );
}
