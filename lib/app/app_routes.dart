// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../core/platform/platform_style.dart';

/// Page route with the platform's own transition
/// (Material on Android, Fluent drill-in on Windows).
Route<T> appRoute<T>(WidgetBuilder builder) => PlatformStyle.isFluent
    ? fl.FluentPageRoute<T>(builder: builder)
    : MaterialPageRoute<T>(builder: builder);

/// Navigator shortcuts used by the screens.
extension AppNavigation on BuildContext {
  /// Opens [page] on top of the current section (inside the shell, so the
  /// navigation bar / pane stays visible).
  Future<T?> pushPage<T>(Widget page) =>
      Navigator.of(this).push<T>(appRoute((_) => page));

  /// Opens [page] over the whole app (no navigation bar on Android).
  Future<T?> pushFullScreen<T>(Widget page) => Navigator.of(
    this,
    rootNavigator: !PlatformStyle.isFluent,
  ).push<T>(appRoute((_) => page));

  /// Replaces the whole stack with [page] (sign in / sign out).
  void resetTo(Widget page) => Navigator.of(
    this,
    rootNavigator: true,
  ).pushAndRemoveUntil(appRoute((_) => page), (_) => false);
}
