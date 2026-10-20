/// Spacing scale (multiples of 8, plus 4 for tight gaps).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double sm = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadius {
  /// Material cards and fields.
  static const double material = 12;

  /// Fluent cards and layers.
  static const double fluent = 8;

  /// Small elements: chips, thumbnails, fluent controls.
  static const double small = 4;
}

/// Maximum content widths so text lines stay readable on wide windows.
abstract final class AppSizes {
  static const double authCard = 400;
  static const double contentMax = 1200;
  static const double masterPane = 380;
  static const double summaryPane = 300;
  static const double minTouchTarget = 48;
}
