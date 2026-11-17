// WINDOWS-ONLY CODE: the window frame of the Fluent version.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/strings/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/brand.dart';

/// Windows only: the window from the LR2 mockup — the app's own title bar
/// (logo, name, window buttons) on the mica backdrop, with the app below.
///
/// `main.dart` hides the system title bar, so this one is drawn by the app
/// on every screen (sign-in too). Wraps the whole app in
/// `FluentApp.builder`.
class WindowFrame extends StatelessWidget {
  const WindowFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppPalette.of(context).mica,
        ),
      ),
      child: Column(
        children: [
          const WindowTitleBar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Windows only: the title bar — logo, app name, minimize / maximize /
/// close. Drag the empty part to move the window, double-click it to
/// maximize (`DragToMoveArea`).
class WindowTitleBar extends StatefulWidget {
  const WindowTitleBar({super.key});

  /// Mockup: 48 px, the same as the compact navigation pane is wide.
  static const height = 48.0;

  /// Tracks dialogs on the root navigator, so the title bar greys out with
  /// the rest of the window (it sits above the navigator, out of the
  /// dialog barrier's reach). Passed to `FluentApp.navigatorObservers`.
  static final modalObserver = _ModalBarrierObserver();

  /// What the logo does. `AppShell` sets it to open / close the navigation
  /// pane (mockup); outside the shell (sign-in) it is null and the logo is
  /// just a picture.
  static final paneToggle = ValueNotifier<VoidCallback?>(null);

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar> with WindowListener {
  /// Maximize or restore button.
  var _maximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((value) {
      if (mounted) setState(() => _maximized = value);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  @override
  Widget build(BuildContext context) {
    final theme = fl.FluentTheme.of(context);
    final brightness = theme.brightness;

    return ValueListenableBuilder(
      valueListenable: WindowTitleBar.modalObserver.barrier,
      builder: (context, barrier, bar) => Stack(
        children: [
          bar!,
          // Same shade as the dialog barrier; the window buttons stay
          // usable, as in Windows itself.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                color: barrier ?? const Color(0x00000000),
              ),
            ),
          ),
        ],
      ),
      child: _buildBar(context, theme, brightness),
    );
  }

  Widget _buildBar(
    BuildContext context,
    fl.FluentThemeData theme,
    Brightness brightness,
  ) {
    return DefaultTextStyle(
      style: theme.typography.body!.copyWith(fontWeight: FontWeight.w600),
      child: SizedBox(
        height: WindowTitleBar.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(width: 4),
            Center(
              child: ValueListenableBuilder(
                valueListenable: WindowTitleBar.paneToggle,
                builder: (context, toggle, _) => _LogoButton(onPressed: toggle),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: DragToMoveArea(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppStrings.appName),
                ),
              ),
            ),
            WindowCaptionButton.minimize(
              brightness: brightness,
              onPressed: windowManager.minimize,
            ),
            if (_maximized)
              WindowCaptionButton.unmaximize(
                brightness: brightness,
                onPressed: windowManager.unmaximize,
              )
            else
              WindowCaptionButton.maximize(
                brightness: brightness,
                onPressed: windowManager.maximize,
              ),
            WindowCaptionButton.close(
              brightness: brightness,
              onPressed: windowManager.close,
            ),
          ],
        ),
      ),
    );
  }
}

/// Barrier color of the topmost open dialog (null when none is open).
///
/// Only routes with a visible barrier count: menus and flyouts have a
/// transparent one.
class _ModalBarrierObserver extends NavigatorObserver {
  final barrier = ValueNotifier<Color?>(null);
  final _routes = <ModalRoute<dynamic>>[];

  static bool _hasBarrier(Route<dynamic>? route) =>
      route is PopupRoute && (route.barrierColor?.a ?? 0) > 0;

  void _add(Route<dynamic>? route) {
    if (_hasBarrier(route)) _routes.add(route! as ModalRoute<dynamic>);
    _update();
  }

  void _remove(Route<dynamic>? route) {
    _routes.remove(route);
    _update();
  }

  /// After the frame: the navigator reports changes while it is building,
  /// and the title bar can't rebuild in the middle of that.
  void _update() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      barrier.value = _routes.isEmpty ? null : _routes.last.barrierColor;
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _routes.remove(oldRoute);
    _add(newRoute);
  }
}

/// The logo in the title bar; a button when [onPressed] is set.
class _LogoButton extends StatelessWidget {
  const _LogoButton({required this.onPressed});

  final VoidCallback? onPressed;

  /// Mockup: 28 px logo in a 40 px button, centered over the 48 px pane.
  static const _logoSize = 28.0;
  static const _padding = 6.0;

  @override
  Widget build(BuildContext context) {
    const logo = AppLogo(size: _logoSize);
    if (onPressed == null) {
      return const Padding(padding: EdgeInsets.all(_padding), child: logo);
    }
    return Semantics(
      label: AppStrings.expandNavigation,
      child: fl.IconButton(
        icon: logo,
        style: const fl.ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.all(_padding)),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
