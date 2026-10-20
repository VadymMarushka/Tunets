// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Surface container used for list items and content sections.
///
/// Android: elevated Material card with ink ripple.
/// Windows: Fluent layer with a hairline border, hover and pressed states
/// and a visible keyboard focus ring.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.padding = const EdgeInsets.all(AppSpacing.m),
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return PlatformStyle.isFluent
        ? _buildFluent(context)
        : _buildMaterial(context);
  }

  // ===== Android (Material 3) =====

  Widget _buildMaterial(BuildContext context) {
    final palette = AppPalette.of(context);
    final radius = BorderRadius.circular(AppRadius.material);
    return Card(
      color: selected ? palette.surfaceVariant : null,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: selected
            ? BorderSide(color: palette.primary, width: 1.5)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }

  // ===== Windows (Fluent) =====

  Widget _buildFluent(BuildContext context) {
    final palette = AppPalette.of(context);
    final radius = BorderRadius.circular(AppRadius.fluent);

    Widget layer(Set<WidgetState> states) {
      var background = selected ? palette.surfaceVariant : palette.surface;
      if (onTap != null && states.isPressed) {
        background = Color.alphaBlend(palette.subtleHover, background);
        background = Color.alphaBlend(palette.subtleHover, background);
      } else if (onTap != null && states.isHovered) {
        background = Color.alphaBlend(palette.subtleHover, background);
      }
      return fl.FocusBorder(
        focused: states.isFocused,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: padding,
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            border: Border.all(
              color: selected ? palette.primary : palette.layerBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: child,
        ),
      );
    }

    if (onTap == null) return layer(const {});
    return fl.HoverButton(
      onPressed: onTap,
      cursor: SystemMouseCursors.click,
      builder: (context, states) => layer(states),
    );
  }
}
