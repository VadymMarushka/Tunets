import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../strings/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// An action in the page header.
///
/// Android shows it as an icon button in the app bar; Windows shows a
/// labeled command button in the page header (Fluent command bar).
class PageAction {
  const PageAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
    this.destructive = false,
    this.showOnMaterial = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;
  final bool destructive;

  /// Some actions live elsewhere on Android (FAB, bottom bar).
  final bool showOnMaterial;
}

/// Page skeleton for both design languages.
///
/// Android: [Scaffold] with an app bar (system back handled by the route),
/// optional extended FAB and bottom bar.
/// Windows: [fl.ScaffoldPage] with a [fl.PageHeader] — back button,
/// breadcrumb and command buttons on the right.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.parentTitle,
    this.materialTitle,
    this.materialTrailing,
    this.fluentHeaderExtra,
    this.floatingAction,
    this.materialBottomBar,
  });

  final String title;
  final Widget body;
  final List<PageAction> actions;

  /// Shown as a breadcrumb ("Trips › Lake Svitiaz") on Windows.
  final String? parentTitle;

  /// Replaces the plain title in the Android app bar.
  final Widget? materialTitle;

  /// Extra widget at the end of the Android app bar (e.g. avatar).
  final Widget? materialTrailing;

  /// Extra widget before the Windows command buttons (e.g. sync badge).
  final Widget? fluentHeaderExtra;

  /// Main action: extended FAB on Android, accent header button on Windows.
  final PageAction? floatingAction;

  /// Android-only bottom bar (e.g. Cancel / Save on the trip form).
  final Widget? materialBottomBar;

  @override
  Widget build(BuildContext context) {
    return PlatformStyle.isFluent
        ? _buildFluent(context)
        : _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    final palette = AppPalette.of(context);
    final fab = floatingAction;
    return Scaffold(
      appBar: AppBar(
        title: materialTitle ?? Text(title),
        actions: [
          for (final action in actions.where((a) => a.showOnMaterial))
            AppIconButton(
              icon: action.icon,
              tooltip: action.label,
              color: action.destructive ? palette.error : null,
              onPressed: action.onPressed,
            ),
          if (materialTrailing != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.m),
              child: materialTrailing,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: materialBottomBar == null,
        child: body,
      ),
      floatingActionButton: fab == null
          ? null
          : FloatingActionButton.extended(
              // Each section has its own FAB; no hero animation between them.
              heroTag: null,
              onPressed: fab.onPressed,
              icon: Icon(fab.icon),
              label: Text(fab.label),
            ),
      bottomNavigationBar: materialBottomBar,
    );
  }

  Widget _buildFluent(BuildContext context) {
    final navigator = Navigator.of(context);
    final palette = AppPalette.of(context);
    final allActions = [?floatingAction, ...actions];

    return fl.ScaffoldPage(
      header: fl.PageHeader(
        leading: navigator.canPop()
            ? Padding(
                padding: const EdgeInsetsDirectional.only(end: AppSpacing.s),
                child: AppIconButton(
                  icon: AppIcons.back,
                  tooltip: AppStrings.back,
                  onPressed: navigator.maybePop,
                ),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (parentTitle != null)
              Text(
                '$parentTitle  ›  $title',
                style: AppTextStyles.caption(context),
                overflow: TextOverflow.ellipsis,
              ),
            Text(title, overflow: TextOverflow.ellipsis),
          ],
        ),
        commandBar: Wrap(
          spacing: AppSpacing.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ?fluentHeaderExtra,
            for (final action in allActions)
              AppButton(
                label: action.label,
                icon: action.icon,
                variant: action.primary
                    ? AppButtonVariant.primary
                    : action.destructive
                    ? AppButtonVariant.danger
                    : AppButtonVariant.secondary,
                onPressed: action.onPressed,
              ),
          ],
        ),
      ),
      content: ColoredBox(color: palette.background, child: body),
    );
  }
}

/// Centers content and limits its width on large windows.
class ContentConstraint extends StatelessWidget {
  const ContentConstraint({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Horizontal page padding: 16 on phones, 24 on Windows (Fluent page inset).
EdgeInsets pagePadding({
  double top = AppSpacing.s,
  double bottom = AppSpacing.l,
}) {
  final horizontal = PlatformStyle.isFluent ? AppSpacing.l : AppSpacing.m;
  return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
}
