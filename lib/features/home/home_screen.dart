// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_routes.dart';
import '../../app/app_shell.dart';
import '../../app/bloc/auth_bloc.dart';
import '../../core/platform/platform_style.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/info_chips.dart';
import '../../core/widgets/progress.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_tile.dart';
import '../../core/widgets/trip_card.dart';
import '../trips/bloc/trips_bloc.dart';
import '../trips/trip_details_screen.dart';
import '../trips/trip_form_screen.dart';

/// S-4. Home (FR-3): greeting, sync status, recent trips and quick access to
/// adding a trip. Wide windows also show a summary of the current month.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _recentCount = 3;

  String _salutation() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 18) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final isFluent = PlatformStyle.isFluent;
    final user = context.currentUser;
    final addTrip = PageAction(
      label: AppStrings.addTrip,
      icon: AppIcons.add,
      primary: true,
      onPressed: () => context.pushFullScreen(const TripFormScreen()),
    );

    return AppPage(
      title: AppStrings.navHome,
      materialTitle: Row(
        children: [
          const AppLogo(size: 32),
          const SizedBox(width: AppSpacing.sm),
          Text(AppStrings.appName, style: AppTextStyles.title(context)),
        ],
      ),
      // Tapping the avatar opens the Profile tab.
      materialTrailing: IconButton(
        tooltip: AppStrings.navProfile,
        onPressed: () =>
            AppShellScope.maybeOf(context)?.selectTab(AppTab.profile),
        icon: UserAvatar(
          size: 32,
          initial: user.initial,
          photoUrl: user.photoUrl,
        ),
      ),
      fluentHeaderExtra: const SyncBadge(),
      floatingAction: addTrip,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= Breakpoints.twoColumns;
          const tripsColumn = _RecentTrips(count: _recentCount);

          return SingleChildScrollView(
            padding: pagePadding(bottom: isFluent ? AppSpacing.l : 96),
            child: ContentConstraint(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.greeting(_salutation(), user.name),
                    style: isFluent
                        ? AppTextStyles.subtitle(context)
                        : AppTextStyles.headline(context),
                  ),
                  if (!isFluent) ...[
                    // Android (Material 3) only
                    const SizedBox(height: AppSpacing.s),
                    const SyncBadge(),
                  ],
                  const SizedBox(height: AppSpacing.l),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: tripsColumn),
                        const SizedBox(width: AppSpacing.l),
                        const SizedBox(
                          width: AppSizes.summaryPane,
                          child: _SummaryCard(),
                        ),
                      ],
                    )
                  else
                    tripsColumn,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The [count] newest trips from [TripsBloc] (FR-3), or a loading / empty
/// state.
class _RecentTrips extends StatelessWidget {
  const _RecentTrips({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: AppStrings.recentTrips,
          trailing: AppButton.text(
            label: PlatformStyle.isFluent
                ? AppStrings.seeAllTrips
                : AppStrings.seeAll,
            onPressed: () =>
                AppShellScope.maybeOf(context)?.selectTab(AppTab.trips),
          ),
        ),
        BlocBuilder<TripsBloc, TripsState>(
          builder: (context, state) {
            if (state.status == TripsStatus.loading && state.trips.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: AppProgressIndicator()),
              );
            }
            if (state.trips.isEmpty) {
              return EmptyState(
                icon: const FishIcon(),
                title: AppStrings.noTripsYet,
                message: AppStrings.homeEmptyMessage,
                action: AppButton(
                  label: AppStrings.addFirstTrip,
                  icon: AppIcons.add,
                  onPressed: () =>
                      context.pushFullScreen(const TripFormScreen()),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final trip in state.trips.take(count)) ...[
                  TripCard(
                    trip: trip,
                    onTap: () =>
                        context.pushPage(TripDetailsScreen(tripId: trip.id)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Month summary: trips count, total catch weight and the best fish.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    final trips = context.select((TripsBloc bloc) => bloc.state.trips);
    final month = DateTime.now();
    final monthTrips = trips
        .where(
          (t) =>
              t.dateTime.year == month.year && t.dateTime.month == month.month,
        )
        .toList();
    final totalKg = monthTrips.fold(0.0, (sum, t) => sum + t.totalKg);
    final catches = monthTrips.expand((t) => t.catches).toList()
      ..sort((a, b) => b.weightKg.compareTo(a.weightKg));
    final best = catches.isEmpty
        ? '—'
        : '${catches.first.species} ${Formatters.kg(catches.first.weightKg)}';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.summary, style: AppTextStyles.subtitle(context)),
          Text(
            Formatters.monthYear(month),
            style: AppTextStyles.caption(context),
          ),
          const SizedBox(height: AppSpacing.m),
          StatRow(
            icon: AppIcons.calendar,
            label: AppStrings.tripsThisMonth,
            value: '${monthTrips.length}',
          ),
          const AppDivider(spacing: AppSpacing.l),
          StatRow(
            icon: AppIcons.weight,
            label: AppStrings.totalCatch,
            value: Formatters.kg(totalKg),
          ),
          const AppDivider(spacing: AppSpacing.l),
          StatRow(
            icon: AppIcons.trophy,
            label: AppStrings.bestCatch,
            value: best,
          ),
        ],
      ),
    );
  }
}
