import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../core/platform/platform_style.dart';
import '../core/strings/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_icons.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/brand.dart';
import '../data/mock/mock_data.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/trips/trips_screen.dart';
import 'app_routes.dart';

/// Main sections available after sign-in.
enum AppTab { home, trips, profile }

/// Lets screens switch sections (e.g. "See all" on Home opens Trips).
class AppShellScope extends InheritedWidget {
  const AppShellScope({
    super.key,
    required this.selectTab,
    required super.child,
  });

  final ValueChanged<AppTab> selectTab;

  static AppShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>();

  @override
  bool updateShouldNotify(AppShellScope oldWidget) => false;
}

/// Navigation shell after sign-in (S-4, S-5, S-8).
///
/// * Android, narrow: bottom [NavigationBar] with three items.
/// * Android, wide (≥ 840 dp): [NavigationRail] on the side.
/// * Windows: Fluent [fl.NavigationView] — expanded pane on wide windows,
///   compact / minimal pane when the window gets narrow.
///
/// Every section has its own nested [Navigator], so opening trip details
/// keeps the navigation bar / pane on screen.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.home;
  final _navigatorKeys = {
    for (final tab in AppTab.values) tab: GlobalKey<NavigatorState>(),
  };

  void _selectTab(AppTab tab) {
    if (tab == _tab) {
      // Re-selecting the current section returns to its first page.
      _navigatorKeys[tab]?.currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _tab = tab);
  }

  Widget _rootPage(AppTab tab) => switch (tab) {
    AppTab.home => const HomeScreen(),
    AppTab.trips => const TripsScreen(),
    AppTab.profile => const ProfileScreen(),
  };

  Widget _sectionNavigator(AppTab tab) {
    final key = _navigatorKeys[tab]!;
    return NavigatorPopHandler(
      // Android back button pops inside the section first.
      onPopWithResult: (_) => key.currentState?.maybePop(),
      child: Navigator(
        key: key,
        onGenerateRoute: (_) => appRoute((_) => _rootPage(tab)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScope(
      selectTab: _selectTab,
      child: PlatformStyle.isFluent
          ? _buildFluent(context)
          : _buildMaterial(context),
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final body = IndexedStack(
      index: _tab.index,
      children: [for (final tab in AppTab.values) _sectionNavigator(tab)],
    );
    void onSelected(int index) => _selectTab(AppTab.values[index]);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.expanded) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _tab.index,
                    onDestinationSelected: onSelected,
                    labelType: NavigationRailLabelType.all,
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
                      child: AppLogo(size: 40),
                    ),
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(AppIcons.home),
                        selectedIcon: Icon(AppIcons.homeSelected),
                        label: const Text(AppStrings.navHome),
                      ),
                      NavigationRailDestination(
                        icon: Icon(AppIcons.trips),
                        selectedIcon: Icon(AppIcons.tripsSelected),
                        label: const Text(AppStrings.navTrips),
                      ),
                      NavigationRailDestination(
                        icon: Icon(AppIcons.profile),
                        selectedIcon: Icon(AppIcons.profileSelected),
                        label: const Text(AppStrings.navProfile),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab.index,
            onDestinationSelected: onSelected,
            destinations: [
              NavigationDestination(
                icon: Icon(AppIcons.home),
                selectedIcon: Icon(AppIcons.homeSelected),
                label: AppStrings.navHome,
              ),
              NavigationDestination(
                icon: Icon(AppIcons.trips),
                selectedIcon: Icon(AppIcons.tripsSelected),
                label: AppStrings.navTrips,
              ),
              NavigationDestination(
                icon: Icon(AppIcons.profile),
                selectedIcon: Icon(AppIcons.profileSelected),
                label: AppStrings.navProfile,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFluent(BuildContext context) {
    final palette = AppPalette.of(context);
    const user = MockData.user;

    fl.PaneItem item(AppTab tab, IconData icon, String title) => fl.PaneItem(
      icon: Icon(icon),
      title: Text(title),
      body: _sectionNavigator(tab),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.mica,
        ),
      ),
      child: fl.NavigationView(
        pane: fl.NavigationPane(
          selected: _tab.index,
          onChanged: (index) => _selectTab(AppTab.values[index]),
          displayMode: fl.PaneDisplayMode.auto,
          compactModeThresholdWidth: Breakpoints.compact,
          expandedModeThresholdWidth: Breakpoints.expanded,
          header: Row(
            children: [
              const AppLogo(size: 24),
              const SizedBox(width: AppSpacing.s),
              Text(
                AppStrings.appName,
                style: AppTextStyles.bodyStrong(context),
              ),
            ],
          ),
          items: [
            item(AppTab.home, AppIcons.home, AppStrings.navHome),
            item(AppTab.trips, AppIcons.trips, AppStrings.navTrips),
            item(AppTab.profile, AppIcons.profile, AppStrings.navProfile),
          ],
          footerItems: [
            fl.PaneItemAction(
              icon: UserAvatar(size: 20, initial: user.initial),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user.name, overflow: TextOverflow.ellipsis),
                  Text(
                    user.email,
                    style: AppTextStyles.caption(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              onTap: () => _selectTab(AppTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}
