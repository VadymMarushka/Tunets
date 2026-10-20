import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

/// Icon tile + caption + value. Used in the home summary.
class StatRow extends StatelessWidget {
  const StatRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: palette.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.small * 2),
          ),
          child: Icon(icon, size: 18, color: palette.onPrimaryContainer),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption(context)),
              Text(value, style: AppTextStyles.subtitle(context)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card with an icon on top, caption and value (weather readings).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppPalette.of(context).primary),
          const SizedBox(height: AppSpacing.s),
          Text(label, style: AppTextStyles.caption(context)),
          Text(
            value,
            style: AppTextStyles.bodyStrong(context),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
