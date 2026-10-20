// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

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

  /// Windows only: gives access to the Fluent pane to open it on start.
  final _paneKey = GlobalKey<fl.NavigationViewState>();

  @override
  void initState() {
    super.initState();
    // ----- Windows (Fluent); the Android (Material 3) version follows -----
    if (PlatformStyle.isFluent) {
      // Wide window: start with the labeled pane, narrow: icons only.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (MediaQuery.sizeOf(context).width >= Breakpoints.expanded) {
          _paneKey.currentState?.openPane();
        }
      });
    }
  }

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

  // ===== Android (Material 3) =====

  /// Bottom navigation bar on phones, navigation rail on wide screens.
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

  // ===== Windows (Fluent) =====

  /// Height of the pane header (logo + "Tunets"). Used for both the open
  /// and the compact pane so the items do not jump when it collapses.
  static const _paneHeaderHeight = 50.0;

  /// Fluent pane: always at least a column of icons (compact mode).
  /// The logo button toggles between icons only and icons with labels;
  /// wide windows start with the labels visible.
  Widget _buildFluent(BuildContext context) {
    fl.PaneItem item(AppTab tab, IconData icon, String title) => fl.PaneItem(
      icon: Icon(icon),
      title: Text(title),
      body: _sectionNavigator(tab),
    );

    return fl.NavigationView(
      key: _paneKey,
      pane: fl.NavigationPane(
        selected: _tab.index,
        onChanged: (index) => _selectTab(AppTab.values[index]),
        displayMode: fl.PaneDisplayMode.compact,
        size: const fl.NavigationPaneSize(headerHeight: _paneHeaderHeight),
        toggleButton: const _LogoPaneToggle(height: _paneHeaderHeight),
        header: Text(
          AppStrings.appName,
          style: AppTextStyles.bodyStrong(context),
        ),
        items: [
          item(AppTab.home, AppIcons.home, AppStrings.navHome),
          item(AppTab.trips, AppIcons.trips, AppStrings.navTrips),
          item(AppTab.profile, AppIcons.profile, AppStrings.navProfile),
        ],
        footerItems: [
          fl.PaneItemWidgetAdapter(
            applyPadding: false,
            child: _UserPaneFooter(onTap: () => _selectTab(AppTab.profile)),
          ),
        ],
      ),
    );
  }
}

/// Windows only: the app logo used as the pane toggle (instead of the
/// standard "hamburger" button).
///
/// The logo is pinned to the top of the box, so it stays at the same spot
/// whether Fluent gives the toggle the full height (compact pane) or a bit
/// less (open pane, where the header row also holds the title).
class _LogoPaneToggle extends StatelessWidget {
  const _LogoPaneToggle({required this.height});

  final double height;

  /// Pane icons are 16 px; the logo tile is slightly larger but stays
  /// square inside the 50 px compact column.
  static const _logoSize = 20.0;

  /// Puts the logo center on the center line of the "Tunets" title.
  static const _topOffset = 8.0;

  @override
  Widget build(BuildContext context) {
    final view = fl.NavigationView.of(context);
    return SizedBox(
      width: fl.kCompactNavigationPaneWidth,
      height: height,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: _topOffset),
          child: fl.Tooltip(
            message: view.isPaneOpen
                ? AppStrings.collapseNavigation
                : AppStrings.expandNavigation,
            child: fl.IconButton(
              icon: const AppLogo(size: _logoSize),
              onPressed: view.togglePane,
            ),
          ),
        ),
      ),
    );
  }
}

/// Windows only: signed-in user at the bottom of the pane.
///
/// A custom pane entry instead of a regular PaneItem: Fluent limits item
/// icons to 14 px in the compact pane, which is too small for an avatar.
/// Shows the avatar alone when the pane is collapsed, avatar + name + email
/// when it is open. Opens the profile on click.
class _UserPaneFooter extends StatelessWidget {
  const _UserPaneFooter({required this.onTap});

  final VoidCallback onTap;

  static const _avatarSize = 28.0;

  /// Horizontal inset that centers the avatar on the pane icon column.
  static const _inset = (fl.kCompactNavigationPaneWidth - _avatarSize) / 2;

  @override
  Widget build(BuildContext context) {
    const user = MockData.user;
    final palette = AppPalette.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final open = constraints.maxWidth > fl.kCompactNavigationPaneWidth * 2;
        final content = fl.HoverButton(
          onPressed: onTap,
          cursor: SystemMouseCursors.click,
          semanticLabel: AppStrings.navProfile,
          builder: (context, states) => Container(
            height: 52,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            padding: EdgeInsets.symmetric(horizontal: _inset - 4),
            decoration: BoxDecoration(
              color: states.isHovered ? palette.subtleHover : null,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                UserAvatar(size: _avatarSize, initial: user.initial),
                if (open) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, overflow: TextOverflow.ellipsis),
                        Text(
                          user.email,
                          style: AppTextStyles.caption(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: open
              ? content
              : fl.Tooltip(message: user.name, child: content),
        );
      },
    );
  }
}
