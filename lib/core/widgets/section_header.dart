import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Section title with an optional trailing action ("See all", "Add catch").
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.subtitle(context),
              semanticsLabel: title,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Icon + title + message (+ optional action) for empty lists.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTextStyles.caption(context).color),
            const SizedBox(height: AppSpacing.m),
            Text(title, style: AppTextStyles.title(context)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.secondary(context),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.m),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Hairline separator in the outline color (works under both themes).
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.spacing = AppSpacing.m});

  /// Total vertical space taken, the line sits in the middle.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: (spacing - 1) / 2),
      child: Container(height: 1, color: AppPalette.of(context).outline),
    );
  }
}
