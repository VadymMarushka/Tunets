// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';

/// Indeterminate progress spinner: Material [CircularProgressIndicator] on
/// Android, Fluent [fl.ProgressRing] on Windows.
class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({super.key, this.size = 32, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final strokeWidth = size < 24 ? 2.0 : 4.0;
    return SizedBox.square(
      dimension: size,
      // ----- Windows (Fluent); the Android (Material 3) version follows -----
      child: PlatformStyle.isFluent
          ? fl.ProgressRing(strokeWidth: strokeWidth, activeColor: color)
          : CircularProgressIndicator(strokeWidth: strokeWidth, color: color),
    );
  }
}
