import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

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
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
  }) : variant = AppButtonVariant.text;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;

  /// Stretch to the full available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = PlatformStyle.isFluent
        ? _buildFluent(context)
        : _buildMaterial(context);
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildMaterial(BuildContext context) {
    final palette = AppPalette.of(context);
    final iconWidget = icon == null ? null : Icon(icon, size: 18);
    final text = Text(label);
    switch (variant) {
      case AppButtonVariant.primary:
        return iconWidget == null
            ? FilledButton(onPressed: onPressed, child: text)
            : FilledButton.icon(
                onPressed: onPressed,
                icon: iconWidget,
                label: text,
              );
      case AppButtonVariant.secondary:
        return iconWidget == null
            ? OutlinedButton(onPressed: onPressed, child: text)
            : OutlinedButton.icon(
                onPressed: onPressed,
                icon: iconWidget,
                label: text,
              );
      case AppButtonVariant.text:
      case AppButtonVariant.danger:
        final style = variant == AppButtonVariant.danger
            ? TextButton.styleFrom(foregroundColor: palette.error)
            : null;
        return iconWidget == null
            ? TextButton(onPressed: onPressed, style: style, child: text)
            : TextButton.icon(
                onPressed: onPressed,
                style: style,
                icon: iconWidget,
                label: text,
              );
    }
  }

  Widget _buildFluent(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = variant == AppButtonVariant.danger ? palette.error : null;
    final Widget child = icon == null
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
        return fl.FilledButton(onPressed: onPressed, child: child);
      case AppButtonVariant.secondary:
        return fl.Button(onPressed: onPressed, child: child);
      case AppButtonVariant.text:
        return fl.HyperlinkButton(onPressed: onPressed, child: child);
      case AppButtonVariant.danger:
        return fl.Button(
          onPressed: onPressed,
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
