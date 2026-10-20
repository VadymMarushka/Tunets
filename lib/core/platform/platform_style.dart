import 'package:flutter/foundation.dart';

/// Decides which design language the app renders with.
///
/// Windows uses Fluent Design (`fluent_ui`), every other platform uses
/// Material 3. Based on [defaultTargetPlatform], so tests can switch it with
/// `debugDefaultTargetPlatformOverride`.
abstract final class PlatformStyle {
  static bool get isFluent => defaultTargetPlatform == TargetPlatform.windows;
}

/// Window size classes from the LR2 specification.
abstract final class Breakpoints {
  /// Below this width the layout is a single column (phone).
  static const double compact = 600;

  /// From this width the layout uses side navigation and two columns.
  static const double expanded = 840;

  /// Minimum content width for a list + details (master–detail) split.
  static const double masterDetail = 760;

  /// Minimum content width for splitting a form or details view in two.
  static const double twoColumns = 720;
}
