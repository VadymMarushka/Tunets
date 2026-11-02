// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'progress.dart';

enum AppButtonVariant {
  /// Main action of a screen (filled, accent color).
  primary,

  /// Secondary action (outlined on Android, standard button on Windows).
  secondary,

  /// Low-emphasis action / link.
  text,

  /// Destructive low-emphasis action (sign out, delete).
  danger,
}

/// Button that renders with the platform's own components.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.expand = false,
    this.loading = false,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.loading = false,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.loading = false,
  }) : variant = AppButtonVariant.text;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.loading = false,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;

  /// Stretch to the full available width.
  final bool expand;

  /// Request in progress: shows a spinner and ignores taps, so the same
  /// request can't be sent twice.
  final bool loading;

  VoidCallback? get _onPressed => loading ? null : onPressed;

  @override
  Widget build(BuildContext context) {
    final button = PlatformStyle.isFluent
        ? _buildFluent(context)
        : _buildMaterial(context);
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  // ===== Android (Material 3) =====

  Widget _buildMaterial(BuildContext context) {
    final palette = AppPalette.of(context);
    final iconWidget = loading
        ? const AppProgressIndicator(size: 16)
        : icon == null
        ? null
        : Icon(icon, size: 18);
    final text = Text(label);
    switch (variant) {
      case AppButtonVariant.primary:
        return iconWidget == null
            ? FilledButton(onPressed: _onPressed, child: text)
            : FilledButton.icon(
                onPressed: _onPressed,
                icon: iconWidget,
                label: text,
              );
      case AppButtonVariant.secondary:
        return iconWidget == null
            ? OutlinedButton(onPressed: _onPressed, child: text)
            : OutlinedButton.icon(
                onPressed: _onPressed,
                icon: iconWidget,
                label: text,
              );
      case AppButtonVariant.text:
      case AppButtonVariant.danger:
        final style = variant == AppButtonVariant.danger
            ? TextButton.styleFrom(foregroundColor: palette.error)
            : null;
        return iconWidget == null
            ? TextButton(onPressed: _onPressed, style: style, child: text)
            : TextButton.icon(
                onPressed: _onPressed,
                style: style,
                icon: iconWidget,
                label: text,
              );
    }
  }

  // ===== Windows (Fluent) =====

  Widget _buildFluent(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = variant == AppButtonVariant.danger ? palette.error : null;
    final Widget child = loading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppProgressIndicator(size: 14),
              const SizedBox(width: AppSpacing.s),
              Text(label),
            ],
          )
        : icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: AppSpacing.s),
              Text(label, style: TextStyle(color: color)),
            ],
          );
    switch (variant) {
      case AppButtonVariant.primary:
        return fl.FilledButton(onPressed: _onPressed, child: child);
      case AppButtonVariant.secondary:
        return fl.Button(onPressed: _onPressed, child: child);
      case AppButtonVariant.text:
        return fl.HyperlinkButton(onPressed: _onPressed, child: child);
      case AppButtonVariant.danger:
        return fl.Button(
          onPressed: _onPressed,
          style: const fl.ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          ),
          child: child,
        );
    }
  }
}

/// Icon-only button with a tooltip (accessible label).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // ----- Windows (Fluent); the Android (Material 3) version follows -----
    if (PlatformStyle.isFluent) {
      return fl.Tooltip(
        message: tooltip,
        child: fl.IconButton(
          icon: Icon(icon, size: 16, color: color),
          onPressed: onPressed,
        ),
      );
    }
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }
}
