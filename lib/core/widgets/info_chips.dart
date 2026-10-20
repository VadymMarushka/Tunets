// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';

import '../../data/models/trip.dart';
import '../platform/platform_style.dart';
import '../strings/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Small read-only tag with an icon (weather reading, tackle item, status).
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    this.icon,
    this.highlighted = false,
    this.onDeleted,
  });

  final String label;

  /// Usually an [Icon] or [FishIcon]; size and color are set by the chip.
  final Widget? icon;

  /// Accent background (e.g. fish count badge).
  final bool highlighted;

  /// Shows a small remove button (editable tackle list).
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final foreground = highlighted
        ? palette.onPrimaryContainer
        : palette.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: highlighted ? palette.primaryContainer : palette.surface2,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: highlighted ? null : Border.all(color: palette.layerBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme.merge(
              data: IconThemeData(
                size: 14,
                color: highlighted ? foreground : palette.primary,
              ),
              child: icon!,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(context)
                  .copyWith(color: foreground, fontWeight: FontWeight.w500),
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Semantics(
              button: true,
              label: '${AppStrings.remove} $label',
              child: GestureDetector(
                onTap: onDeleted,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: palette.secondaryText,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Temperature, pressure and wind of a trip as a row of chips.
class WeatherChips extends StatelessWidget {
  const WeatherChips({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.xs,
      children: [
        InfoChip(
          icon: const Icon(AppIcons.temperature),
          label: weather.temperatureLabel,
        ),
        InfoChip(
          icon: const Icon(AppIcons.pressure),
          label: weather.pressureLabel,
        ),
        InfoChip(icon: const Icon(AppIcons.wind), label: weather.windLabel),
      ],
    );
  }
}

/// Pill showing the sync state (visibility of system status — Nielsen #1).
class SyncBadge extends StatelessWidget {
  const SyncBadge({super.key, this.synced = true});

  final bool synced;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = synced ? palette.onSurface : palette.warning;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(
          PlatformStyle.isFluent ? AppRadius.small : AppRadius.fluent,
        ),
        border: Border.all(color: palette.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            synced ? AppIcons.synced : AppIcons.offline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            synced ? AppStrings.synced : AppStrings.offline,
            style: AppTextStyles.caption(context)
                .copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
