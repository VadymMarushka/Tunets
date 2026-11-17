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
import 'dashed_border.dart';
import 'dialogs.dart';

/// Place to attach a catch photo (FR-5), as in the LR2 mockup.
///
/// Windows: dashed drop zone ("Drag a photo here or browse files") — drag &
/// drop is a Windows-specific feature from LR2. Android: tonal "Add photo"
/// button that opens the Camera / Gallery sheet.
class PhotoDropZone extends StatelessWidget {
  const PhotoDropZone({super.key});

  @override
  Widget build(BuildContext context) {
    // ----- Windows (Fluent); the Android (Material 3) version follows -----
    if (PlatformStyle.isFluent) return _buildFluent(context);

    return AppButton.tonal(
      label: AppStrings.addPhoto,
      icon: AppIcons.camera,
      expand: true,
      onPressed: () => showPhotoSourcePicker(context),
    );
  }

  // ===== Windows (Fluent) =====

  Widget _buildFluent(BuildContext context) {
    final palette = AppPalette.of(context);
    return fl.HoverButton(
      onPressed: () => showPhotoSourcePicker(context),
      cursor: SystemMouseCursors.click,
      builder: (context, states) => fl.FocusBorder(
        focused: states.isFocused,
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: states.isHovered ? palette.primary : palette.secondaryText,
            radius: AppRadius.fluent,
          ),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 96),
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
                Icon(AppIcons.photo, size: 24, color: palette.primary),
                const SizedBox(height: AppSpacing.s),
                Text(
                  AppStrings.dragPhotoHere,
                  style: AppTextStyles.body(context),
                ),
                const SizedBox(height: AppSpacing.s),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: AppStrings.browseFilesPrefix),
                      TextSpan(
                        text: AppStrings.browseFiles,
                        style: TextStyle(color: palette.primary),
                      ),
                      const TextSpan(text: ' · '),
                      const TextSpan(text: AppStrings.photoRequirements),
                    ],
                  ),
                  style: AppTextStyles.caption(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
