import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../strings/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'dialogs.dart';

/// Place to attach a catch photo (FR-5).
///
/// Windows: drop zone ("Drag a photo here or browse files") — drag & drop is
/// a Windows-specific feature from LR2. Android: tappable tile that opens
/// the Camera / Gallery sheet.
class PhotoDropZone extends StatelessWidget {
  const PhotoDropZone({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final isFluent = PlatformStyle.isFluent;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.m,
        horizontal: AppSpacing.s,
      ),
      child: Column(
        children: [
          Icon(AppIcons.photo, color: palette.primary),
          const SizedBox(height: AppSpacing.s),
          Text(
            isFluent ? AppStrings.dragPhotoHere : AppStrings.addPhoto,
            style: AppTextStyles.bodyStrong(context),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text.rich(
            TextSpan(
              children: [
                if (isFluent) ...[
                  const TextSpan(text: AppStrings.browseFilesPrefix),
                  TextSpan(
                    text: AppStrings.browseFiles,
                    style: TextStyle(color: palette.primary),
                  ),
                  const TextSpan(text: ' · '),
                ],
                const TextSpan(text: AppStrings.photoRequirements),
              ],
            ),
            style: AppTextStyles.caption(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    final radius = BorderRadius.circular(
      isFluent ? AppRadius.fluent : AppRadius.material,
    );
    final decoration = BoxDecoration(
      color: palette.surface2,
      borderRadius: radius,
      border: Border.all(color: palette.outline),
    );

    if (isFluent) {
      return fl.HoverButton(
        onPressed: () => showPhotoSourcePicker(context),
        cursor: SystemMouseCursors.click,
        builder: (context, states) => fl.FocusBorder(
          focused: states.isFocused,
          child: DecoratedBox(
            decoration: decoration.copyWith(
              color: states.isHovered
                  ? Color.alphaBlend(palette.subtleHover, palette.surface2)
                  : null,
            ),
            child: SizedBox(width: double.infinity, child: content),
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          borderRadius: radius,
          onTap: () => showPhotoSourcePicker(context),
          child: SizedBox(width: double.infinity, child: content),
        ),
      ),
    );
  }
}
