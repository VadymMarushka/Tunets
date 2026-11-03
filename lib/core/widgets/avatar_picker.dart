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
import 'brand.dart';

/// Ready-made profile pictures (HTTPS links to DiceBear "thumbs" images).
/// Uploading own files to storage comes in LR6; until then the user picks
/// one of these.
abstract final class AvatarPresets {
  /// Background, figure color, eyes and mouth of each picture.
  static const _styles = [
    ('c8e6c9', '2e7d32', 'variant1W12', 'variant1'),
    ('1b5e20', 'a5d6a7', 'variant2W14', 'variant2'),
    ('b2dfdb', '00897b', 'variant3W12', 'variant3'),
    ('dcedc8', '7cb342', 'variant4W16', 'variant4'),
    ('bbdefb', '1e88e5', 'variant5W14', 'variant5'),
    ('0a5b83', '69d2e7', 'variant6W12', 'variant1'),
    ('fff3c4', 'f9a825', 'variant7W14', 'variant2'),
    ('ffe0b2', 'f4511e', 'variant8W12', 'variant3'),
    ('f8bbd0', 'd81b60', 'variant9W14', 'variant4'),
    ('e1bee7', '8e24aa', 'variant2W10', 'variant5'),
    ('ffcdd2', 'c62828', 'variant5W16', 'variant2'),
    ('37474f', 'eceff1', 'variant8W16', 'variant1'),
  ];

  static final urls = [
    for (final (i, (background, shape, eyes, mouth)) in _styles.indexed)
      'https://api.dicebear.com/9.x/thumbs/png?seed=tunets${i + 1}&size=256'
          '&backgroundColor=$background&shapeColor=$shape'
          '&eyes=$eyes&mouth=$mouth',
  ];
}

/// Result of [showAvatarPicker]: the new photo link, or `null` to remove it.
class AvatarChoice {
  const AvatarChoice(this.url);

  final String? url;
}

/// Dialog for choosing the profile photo. Returns `null` when cancelled.
Future<AvatarChoice?> showAvatarPicker(
  BuildContext context, {
  String? currentUrl,
}) {
  final dialog = _AvatarPickerDialog(currentUrl: currentUrl);
  // ----- Windows (Fluent); the Android (Material 3) version follows -----
  return PlatformStyle.isFluent
      ? fl.showDialog<AvatarChoice>(context: context, builder: (_) => dialog)
      : showDialog<AvatarChoice>(context: context, builder: (_) => dialog);
}

class _AvatarPickerDialog extends StatefulWidget {
  const _AvatarPickerDialog({this.currentUrl});

  final String? currentUrl;

  @override
  State<_AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends State<_AvatarPickerDialog> {
  late String? _selected = widget.currentUrl;

  /// Set after a tap on "Upload from device", which isn't available yet.
  bool _showComingSoon = false;

  @override
  Widget build(BuildContext context) {
    final canConfirm = _selected != null && _selected != widget.currentUrl;
    final content = SizedBox(
      // Six pictures per row on Windows; fewer on a narrow phone dialog.
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.photoPresets, style: AppTextStyles.label(context)),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final url in AvatarPresets.urls)
                  _PresetTile(
                    url: url,
                    selected: url == _selected,
                    onTap: () => setState(() => _selected = url),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppButton.secondary(
                label: AppStrings.uploadFromDevice,
                icon: AppIcons.upload,
                onPressed: () => setState(() => _showComingSoon = true),
              ),
            ),
            if (_showComingSoon) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                AppStrings.uploadComingSoon,
                style: AppTextStyles.caption(context),
              ),
            ],
          ],
        ),
      ),
    );

    final hasPhoto = widget.currentUrl != null;

    // ----- Windows (Fluent); the Android (Material 3) version follows -----
    if (PlatformStyle.isFluent) {
      return fl.ContentDialog(
        constraints: const BoxConstraints(maxWidth: 460),
        title: const Text(AppStrings.choosePhoto),
        content: content,
        actions: [
          fl.FilledButton(
            onPressed: canConfirm
                ? () => Navigator.of(context).pop(AvatarChoice(_selected))
                : null,
            child: const Text(AppStrings.usePhoto),
          ),
          if (hasPhoto)
            fl.Button(
              onPressed: () =>
                  Navigator.of(context).pop(const AvatarChoice(null)),
              child: const Text(AppStrings.removePhoto),
            ),
          fl.Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
        ],
      );
    }
    return AlertDialog(
      title: const Text(AppStrings.choosePhoto),
      content: content,
      actions: [
        if (hasPhoto)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppPalette.of(context).error,
            ),
            onPressed: () =>
                Navigator.of(context).pop(const AvatarChoice(null)),
            child: const Text(AppStrings.remove),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: canConfirm
              ? () => Navigator.of(context).pop(AvatarChoice(_selected))
              : null,
          child: const Text(AppStrings.usePhoto),
        ),
      ],
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.url,
    required this.selected,
    required this.onTap,
  });

  final String url;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? palette.primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: UserAvatar(size: 48, photoUrl: url),
          ),
        ),
      ),
    );
  }
}
