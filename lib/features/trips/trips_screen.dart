// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/platform/platform_style.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/filter_bar.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/trip_card.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/trip.dart';
import 'trip_details_screen.dart';
import 'trip_form_screen.dart';

enum _TripFilter { all, thisMonth, thisYear }

/// S-5. Trips list (FR-4) with search by water body and period filters.
///
/// Narrow: a single list, tapping a trip opens [TripDetailsScreen].
/// Wide (≥ 760 px of content): master–detail — list on the left, details of
/// the selected trip on the right (Open / Edit / Delete).
class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String _query = '';
  _TripFilter _filter = _TripFilter.all;
  Trip? _selected = MockData.trips.first;

  List<Trip> get _visibleTrips {
    final today = MockData.today;
    final query = _query.trim().toLowerCase();
    return MockData.trips.where((trip) {
      final matchesQuery =
          query.isEmpty || trip.waterBody.toLowerCase().contains(query);
      final date = trip.dateTime;
      final matchesFilter = switch (_filter) {
        _TripFilter.all => true,
        _TripFilter.thisMonth =>
          date.year == today.year && date.month == today.month,
        _TripFilter.thisYear => date.year == today.year,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  void _openForm([Trip? trip]) =>
      context.pushFullScreen(TripFormScreen(trip: trip));

  @override
  Widget build(BuildContext context) {
    final trips = _visibleTrips;

    return AppPage(
      title: AppStrings.navTrips,
      floatingAction: PageAction(
        label: AppStrings.addTrip,
        icon: AppIcons.add,
        primary: true,
        onPressed: _openForm,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final masterDetail = constraints.maxWidth >= Breakpoints.masterDetail;
          final list = _buildList(context, trips, masterDetail: masterDetail);
          if (!masterDetail) return list;

          final selected = trips.contains(_selected) ? _selected : null;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: AppSizes.masterPane, child: list),
              Expanded(
                child: selected == null
                    ? const EmptyState(
                        icon: Icons.touch_app_outlined,
                        title: AppStrings.tripDetails,
                        message: AppStrings.selectTripHint,
                      )
                    : _DetailsPane(
                        trip: selected,
                        onEdit: () => _openForm(selected),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Trip> trips, {
    required bool masterDetail,
  }) {
    final padding = pagePadding(
      bottom: PlatformStyle.isFluent ? AppSpacing.l : 96,
    );
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: padding.copyWith(bottom: AppSpacing.m),
          sliver: SliverList.list(
            children: [
              AppSearchField(
                hint: AppStrings.searchByWaterBody,
                icon: AppIcons.search,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilterBar(
                labels: const [
                  AppStrings.filterAll,
                  AppStrings.filterThisMonth,
                  AppStrings.filterThisYear,
                ],
                selectedIndex: _filter.index,
                onSelected: (index) =>
                    setState(() => _filter = _TripFilter.values[index]),
              ),
              if (PlatformStyle.isFluent) ...[
                // Windows (Fluent) only
                const SizedBox(height: AppSpacing.s),
                Text(
                  AppStrings.tripsCount(trips.length),
                  style: AppTextStyles.caption(context),
                ),
              ],
            ],
          ),
        ),
        if (trips.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyTrips(
              filtered: _query.isNotEmpty || _filter != _TripFilter.all,
              onAdd: _openForm,
            ),
          )
        else
          SliverPadding(
            padding: padding.copyWith(top: 0),
            sliver: SliverList.separated(
              itemCount: trips.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return TripCard(
                  trip: trip,
                  selected: masterDetail && trip == _selected,
                  onTap: masterDetail
                      ? () => setState(() => _selected = trip)
                      : () => context.pushPage(TripDetailsScreen(trip: trip)),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyTrips extends StatelessWidget {
  const _EmptyTrips({required this.filtered, required this.onAdd});

  final bool filtered;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (filtered) {
      return EmptyState(
        icon: AppIcons.search,
        title: AppStrings.noMatchingTrips,
        message: AppStrings.noMatchingTripsMessage,
      );
    }
    return EmptyState(
      icon: AppIcons.fish,
      title: AppStrings.noTripsYet,
      message: AppStrings.noTripsYetMessage,
      action: AppButton(
        label: AppStrings.addFirstTrip,
        icon: AppIcons.add,
        onPressed: onAdd,
      ),
    );
  }
}

/// Right side of the master–detail layout.
class _DetailsPane extends StatelessWidget {
  const _DetailsPane({required this.trip, required this.onEdit});

  final Trip trip;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Gap between the list scrollbar and the details.
      padding: pagePadding().copyWith(left: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.s,
            children: [
              AppButton.text(
                label: AppStrings.open,
                icon: AppIcons.open,
                onPressed: () =>
                    context.pushPage(TripDetailsScreen(trip: trip)),
              ),
              AppButton.text(
                label: AppStrings.edit,
                icon: AppIcons.edit,
                onPressed: onEdit,
              ),
              AppButton.danger(
                label: AppStrings.delete,
                icon: AppIcons.delete,
                onPressed: () => confirmDeleteTrip(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          TripDetailsView(trip: trip),
        ],
      ),
    );
  }
}
