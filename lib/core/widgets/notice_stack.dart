import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Windows only: stack of InfoBar notifications in the bottom-right corner.
///
/// Fluent's own `displayInfoBar` puts every notification at the same spot,
/// so several of them overlap. This stack shows them as a column instead:
/// the newest at the bottom, at most [maxVisible] at once (the oldest one
/// goes away when a new one arrives), each closing by itself after
/// [visibleFor] or with its close button.
///
/// (Android uses Material snackbars, which by design show one at a time.)
abstract final class FluentNoticeStack {
  static const maxVisible = 3;
  static const visibleFor = Duration(seconds: 4);
  static const _width = 360.0;

  static final _notices = ValueNotifier<List<_Notice>>(const []);
  static final _timers = <int, Timer>{};
  static OverlayEntry? _entry;
  static int _nextId = 0;

  static void show(
    BuildContext context,
    String message, {
    fl.InfoBarSeverity severity = fl.InfoBarSeverity.success,
  }) {
    _ensureOverlay(context);

    final notice = _Notice(_nextId++, message, severity);
    final list = [..._notices.value, notice];
    // Drop the oldest ones above the limit.
    while (list.length > maxVisible) {
      _timers.remove(list.first.id)?.cancel();
      list.removeAt(0);
    }
    _notices.value = list;
    _timers[notice.id] = Timer(visibleFor, () => dismiss(notice.id));
  }

  static void dismiss(int id) {
    _timers.remove(id)?.cancel();
    _notices.value = _notices.value.where((n) => n.id != id).toList();
    if (_notices.value.isEmpty) {
      _entry?.remove();
      _entry = null;
    }
  }

  static void _ensureOverlay(BuildContext context) {
    if (_entry != null && _entry!.mounted) return;
    _entry = OverlayEntry(builder: (_) => const _NoticeColumn());
    // Root overlay: notifications stay visible across page changes.
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }
}

class _Notice {
  const _Notice(this.id, this.message, this.severity);

  final int id;
  final String message;
  final fl.InfoBarSeverity severity;
}

class _NoticeColumn extends StatelessWidget {
  const _NoticeColumn();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: AppSpacing.m,
      bottom: AppSpacing.l,
      width: FluentNoticeStack._width,
      child: ValueListenableBuilder<List<_Notice>>(
        valueListenable: FluentNoticeStack._notices,
        builder: (context, notices, _) => AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final notice in notices)
                Padding(
                  key: ValueKey(notice.id),
                  padding: const EdgeInsets.only(top: AppSpacing.s),
                  child: _NoticeCard(notice: notice),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One notification; slides in from the right when it appears.
class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.notice});

  final _Notice notice;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset((1 - t) * 40, 0),
          child: child,
        ),
      ),
      child: PhysicalModel(
        // Opaque backing: the InfoBar tint itself is semi-transparent, so
        // page content would show through it.
        color: AppPalette.of(context).surface,
        elevation: 8,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: fl.InfoBar(
          // Full-width title pushes the close button to the right edge
          // (InfoBar otherwise sizes the row to the text).
          title: SizedBox(width: double.infinity, child: Text(notice.message)),
          severity: notice.severity,
          // `onClose` puts the close button on the right, in line with the
          // text (unlike `action`, which goes below it).
          onClose: () => FluentNoticeStack.dismiss(notice.id),
        ),
      ),
    );
  }
}
