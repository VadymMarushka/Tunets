// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../strings/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// Confirmation for destructive actions: Material dialog on Android,
/// ContentDialog on Windows. Returns `true` when the user confirms.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = true,
}) async {
  final palette = AppPalette.of(context);
  final bool? result;

  // ----- Windows (Fluent); the Android (Material 3) version follows -----
  if (PlatformStyle.isFluent) {
    result = await fl.showDialog<bool>(
      context: context,
      builder: (context) => fl.ContentDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          fl.FilledButton(
            style: destructive
                ? fl.ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(palette.error),
                    foregroundColor: WidgetStatePropertyAll(
                      palette.isDark ? Colors.black : Colors.white,
                    ),
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
          fl.Button(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  } else {
    result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            style: destructive
                ? TextButton.styleFrom(foregroundColor: palette.error)
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
  return result ?? false;
}

enum NoticeKind { info, success, error }

/// Short non-blocking message: Snackbar on Android, InfoBar on Windows.
void showNotice(
  BuildContext context,
  String message, {
  NoticeKind kind = NoticeKind.success,
}) {
  // ----- Windows (Fluent); the Android (Material 3) version follows -----
  if (PlatformStyle.isFluent) {
    fl.displayInfoBar(
      context,
      builder: (context, close) => fl.InfoBar(
        title: Text(message),
        severity: switch (kind) {
          NoticeKind.info => fl.InfoBarSeverity.info,
          NoticeKind.success => fl.InfoBarSeverity.success,
          NoticeKind.error => fl.InfoBarSeverity.error,
        },
        action: fl.IconButton(
          icon: const Icon(fl.FluentIcons.clear, size: 12),
          onPressed: close,
        ),
      ),
    );
    return;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Photo source choice (FR-5). Android shows a bottom sheet with camera and
/// gallery; Windows has no camera flow, so it goes straight to the file
/// picker. Pickers are wired up together with media upload in a later lab.
Future<void> showPhotoSourcePicker(
  BuildContext context, {
  bool canRemove = false,
}) async {
  // ----- Windows (Fluent); the Android (Material 3) version follows -----
  if (PlatformStyle.isFluent) {
    showNotice(context, AppStrings.photoNotAvailable, kind: NoticeKind.info);
    return;
  }
  final picked = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(AppIcons.camera),
            title: const Text(AppStrings.takePhoto),
            onTap: () => Navigator.of(context).pop(true),
          ),
          ListTile(
            leading: Icon(AppIcons.gallery),
            title: const Text(AppStrings.chooseFromGallery),
            onTap: () => Navigator.of(context).pop(true),
          ),
          if (canRemove)
            ListTile(
              leading: Icon(AppIcons.delete),
              title: const Text(AppStrings.removePhoto),
              onTap: () => Navigator.of(context).pop(true),
            ),
        ],
      ),
    ),
  );
  if (picked == true && context.mounted) {
    showNotice(context, AppStrings.photoNotAvailable, kind: NoticeKind.info);
  }
}
