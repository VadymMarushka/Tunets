// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../strings/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'dialogs.dart';

/// What the user chose in the "Change photo" picker.
enum ProfilePhotoAction { remove }

/// "Change photo" for the profile (FR-5), as in the LR2 mockup:
///
/// * Android: bottom sheet with Camera, Gallery and Remove photo;
/// * Windows: dialog with a drop zone ("Drag an image here", Browse files…).
///
/// Uploading own images needs cloud storage, which comes in the next lab,
/// so Camera / Gallery / Browse only say so. Returns
/// [ProfilePhotoAction.remove] when the user removes the current photo,
/// `null` otherwise.
Future<ProfilePhotoAction?> showProfilePhotoPicker(
  BuildContext context, {
  required bool hasPhoto,
}) async {
  // ----- Windows (Fluent); the Android (Material 3) version follows -----
  if (PlatformStyle.isFluent) {
    return fl.showDialog<ProfilePhotoAction>(
      context: context,
      builder: (context) => _FluentPhotoDialog(hasPhoto: hasPhoto),
    );
  }
  final palette = AppPalette.of(context);
  final choice = await showModalBottomSheet<_SheetChoice>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              0,
              AppSpacing.l,
              AppSpacing.s,
            ),
            child: Text(
              AppStrings.changePhoto,
              style: AppTextStyles.subtitle(context),
            ),
          ),
          ListTile(
            leading: Icon(AppIcons.camera),
            title: const Text(AppStrings.camera),
            onTap: () => Navigator.of(context).pop(_SheetChoice.upload),
          ),
          ListTile(
            leading: Icon(AppIcons.gallery),
            title: const Text(AppStrings.gallery),
            onTap: () => Navigator.of(context).pop(_SheetChoice.upload),
          ),
          if (hasPhoto)
            ListTile(
              leading: Icon(AppIcons.delete, color: palette.error),
              title: Text(
                AppStrings.removePhoto,
                style: TextStyle(color: palette.error),
              ),
              onTap: () => Navigator.of(context).pop(_SheetChoice.remove),
            ),
        ],
      ),
    ),
  );
  switch (choice) {
    case _SheetChoice.remove:
      return ProfilePhotoAction.remove;
    case _SheetChoice.upload:
      if (context.mounted) {
        showNotice(
          context,
          AppStrings.photoNotAvailable,
          kind: NoticeKind.info,
        );
      }
      return null;
    case null:
      return null;
  }
}

enum _SheetChoice { upload, remove }

// ===== Windows (Fluent) =====

class _FluentPhotoDialog extends StatelessWidget {
  const _FluentPhotoDialog({required this.hasPhoto});

  final bool hasPhoto;

  void _browse(BuildContext context) =>
      showNotice(context, AppStrings.photoNotAvailable, kind: NoticeKind.info);

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return fl.ContentDialog(
      constraints: const BoxConstraints(maxWidth: AppSizes.dialogWidth),
      title: const Text(AppStrings.changePhoto),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.chooseSquareImage,
            style: AppTextStyles.secondary(context),
          ),
          const SizedBox(height: 20),
          // Drop zone (mockup .f-dropzone): dashed frame, opens the file
          // picker on click.
          fl.HoverButton(
            onPressed: () => _browse(context),
            cursor: SystemMouseCursors.click,
            builder: (context, states) => CustomPaint(
              painter: _DashedBorderPainter(
                color: states.isHovered
                    ? palette.primary
                    : palette.secondaryText,
                radius: AppRadius.fluent,
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 160),
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: states.isHovered
                      ? Color.alphaBlend(palette.subtleHover, palette.surface2)
                      : palette.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.fluent),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.upload, size: 32, color: palette.primary),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      AppStrings.dragImageHere,
                      style: AppTextStyles.body(context),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      AppStrings.photoRequirements,
                      style: AppTextStyles.caption(context),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    AppButton.secondary(
                      label: AppStrings.browseFilesButton,
                      icon: AppIcons.gallery,
                      onPressed: () => _browse(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasPhoto) ...[
            // Not in the mockup: needed to go back to the letter avatar.
            const SizedBox(height: AppSpacing.sm),
            AppButton.danger(
              label: AppStrings.removePhoto,
              icon: AppIcons.delete,
              expand: true,
              onPressed: () =>
                  Navigator.of(context).pop(ProfilePhotoAction.remove),
            ),
          ],
        ],
      ),
      actions: [
        // No image can be picked yet (next lab), so Save just closes the
        // dialog without changes, as in the mockup.
        fl.FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.save),
        ),
        fl.Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
      ],
    );
  }
}

/// Dashed rounded frame (CSS `border: 1px dashed`), which Flutter has no
/// built-in border for.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dash = 4.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5),
          Radius.circular(radius),
        ),
      );
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
