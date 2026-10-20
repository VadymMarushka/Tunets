import 'package:flutter/material.dart';

import '../../data/models/trip.dart';
import '../strings/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'brand.dart';
import 'info_chips.dart';

/// Trip summary card used on Home and in the Trips list (S-4, S-5).
class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.selected = false,
  });

  final Trip trip;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppCard(
      onTap: onTap,
      selected: selected,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.calendar,
                          size: 12,
                          color: palette.secondaryText,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            Formatters.tripDateTime(trip.dateTime),
                            style: AppTextStyles.caption(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      trip.waterBody,
                      style: AppTextStyles.subtitle(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const FishThumbnail(size: 48),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          WeatherChips(weather: trip.weather),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              FishIcon(size: 20, color: palette.primary),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  catchSummary(trip),
                  style: AppTextStyles.body(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// `Pike 2.3 kg × 1 · Perch 0.4 kg × 5`
  static String catchSummary(Trip trip) {
    if (!trip.hasCatch) return AppStrings.noCatch;
    return trip.catches
        .map((c) => '${c.species} ${Formatters.kg(c.weightKg)} × ${c.count}')
        .join(' · ');
  }
}
