import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/platform/platform_style.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/info_chips.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_tile.dart';
import '../../data/models/catch_entry.dart';
import '../../data/models/trip.dart';
import 'trip_form_screen.dart';

/// Asks for confirmation and "deletes" the trip (FR-4). Data is hardcoded in
/// this lab, so only the confirmation and the notice are shown.
Future<bool> confirmDeleteTrip(BuildContext context) async {
  final confirmed = await showConfirmDialog(
    context,
    title: AppStrings.deleteTripTitle,
    message: AppStrings.deleteTripMessage,
    confirmLabel: AppStrings.delete,
  );
  if (confirmed && context.mounted) {
    showNotice(context, AppStrings.tripDeleted);
  }
  return confirmed;
}

/// S-7. Trip details as a separate page (narrow layout, or "Open" from the
/// Windows master–detail view).
class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: PlatformStyle.isFluent ? trip.waterBody : AppStrings.tripDetails,
      parentTitle: AppStrings.navTrips,
      actions: [
        PageAction(
          label: AppStrings.edit,
          icon: AppIcons.edit,
          onPressed: () => context.pushFullScreen(TripFormScreen(trip: trip)),
        ),
        PageAction(
          label: AppStrings.delete,
          icon: AppIcons.delete,
          destructive: true,
          onPressed: () async {
            if (await confirmDeleteTrip(context) && context.mounted) {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: pagePadding(),
        child: ContentConstraint(
          child: TripDetailsView(
            trip: trip,
            showTitle: !PlatformStyle.isFluent,
          ),
        ),
      ),
    );
  }
}

/// Content of a trip: photo, weather, tackle, catch and notes.
/// Reused by [TripDetailsScreen] and the details pane of the trips list.
class TripDetailsView extends StatelessWidget {
  const TripDetailsView({super.key, required this.trip, this.showTitle = true});

  final Trip trip;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= Breakpoints.twoColumns;
        final overview = _Overview(trip: trip, showTitle: showTitle);
        final left = [
          _WeatherSection(weather: trip.weather),
          _TackleSection(tackle: trip.tackle),
          if (trip.notes.isNotEmpty) _NotesSection(notes: trip.notes),
        ];
        final catchSection = _CatchSection(trip: trip);

        if (!twoColumns) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              overview,
              ...left.take(2),
              catchSection,
              ...left.skip(2),
            ].separated(AppSpacing.l),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            overview,
            const SizedBox(height: AppSpacing.l),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: left.separated(AppSpacing.l),
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(child: catchSection),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.trip, required this.showTitle});

  final Trip trip;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final dateRow = Row(
      children: [
        Icon(AppIcons.calendar, size: 14, color: palette.secondaryText),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            Formatters.tripDateTime(trip.dateTime),
            style: AppTextStyles.secondary(context),
          ),
        ),
      ],
    );

    if (!PlatformStyle.isFluent) {
      return AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TripPhoto(height: 140),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showTitle)
                    Text(
                      trip.waterBody,
                      style: AppTextStyles.headline(context),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  dateRow,
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Windows: compact header card — thumbnail, date, water body, fish badge.
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          const TripPhoto(height: 56, width: 96),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle)
                  Text(trip.waterBody, style: AppTextStyles.subtitle(context)),
                dateRow,
                if (!showTitle)
                  Row(
                    children: [
                      Icon(
                        AppIcons.waterBody,
                        size: 14,
                        color: palette.secondaryText,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        trip.waterBody,
                        style: AppTextStyles.secondary(context),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          InfoChip(
            icon: AppIcons.fish,
            label: AppStrings.fishCount(trip.fishCount),
            highlighted: true,
          ),
        ],
      ),
    );
  }
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: AppStrings.weather),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: AppIcons.temperature,
                label: AppStrings.temperature,
                value: weather.temperatureLabel,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: StatCard(
                icon: AppIcons.pressure,
                label: AppStrings.pressure,
                value: weather.pressureLabel,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: StatCard(
                icon: AppIcons.wind,
                label: AppStrings.wind,
                value: weather.windLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TackleSection extends StatelessWidget {
  const _TackleSection({required this.tackle});

  final List<String> tackle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: AppStrings.tackle),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final item in tackle)
              InfoChip(icon: AppIcons.tackle, label: item),
          ],
        ),
      ],
    );
  }
}

class _CatchSection extends StatelessWidget {
  const _CatchSection({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: trip.hasCatch
              ? AppStrings.catchWithCount(trip.fishCount)
              : AppStrings.catchTitle,
        ),
        if (!trip.hasCatch)
          AppCard(
            child: Text(
              AppStrings.noCatchMessage,
              style: AppTextStyles.secondary(context),
            ),
          ),
        for (final entry in trip.catches) ...[
          _CatchTile(entry: entry),
          const SizedBox(height: AppSpacing.s),
        ],
      ],
    );
  }
}

class _CatchTile extends StatelessWidget {
  const _CatchTile({required this.entry});

  final CatchEntry entry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          const FishThumbnail(size: 48),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.species, style: AppTextStyles.bodyStrong(context)),
                Text(
                  '${Formatters.kg(entry.weightKg)} × ${entry.count}',
                  style: AppTextStyles.caption(context),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(AppStrings.total, style: AppTextStyles.caption(context)),
              Text(
                Formatters.kg(entry.totalKg),
                style: AppTextStyles.bodyStrong(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: AppStrings.notes),
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.notes,
                size: 16,
                color: AppPalette.of(context).secondaryText,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(child: Text(notes, style: AppTextStyles.body(context))),
            ],
          ),
        ),
      ],
    );
  }
}

extension on List<Widget> {
  /// Inserts vertical gaps between widgets.
  List<Widget> separated(double gap) => [
    for (var i = 0; i < length; i++) ...[
      if (i > 0) SizedBox(height: gap),
      this[i],
    ],
  ];
}
