// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../strings/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/validators.dart';
import 'app_text_field.dart';
import 'brand.dart';

/// Ready-made profile pictures (HTTPS links). Uploading own files to
/// storage comes in LR6; until then the user picks one of these or pastes
/// a link to an image.
abstract final class AvatarPresets {
  static const _seeds = ['Pike', 'Perch', 'Carp', 'Bream', 'Zander', 'Roach'];

  static final urls = [
    for (final seed in _seeds)
      'https://api.dicebear.com/9.x/thumbs/png?seed=$seed&size=256',
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
  final _formKey = GlobalKey<FormState>();
  final _link = TextEditingController();
  late String? _selected = widget.currentUrl;

  /// Link typed by the user, shown in the preview once it's valid.
  String? _preview;

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  void _onLinkChanged(String value) {
    final valid = Validators.photoUrl(value) == null;
    setState(() {
      _preview = valid ? value.trim() : null;
      if (valid) _selected = value.trim();
    });
  }

  void _pickPreset(String url) {
    _link.clear();
    setState(() {
      _preview = null;
      _selected = url;
    });
  }

  void _confirm() {
    // Only validate the link field when the user typed something.
    if (_link.text.isNotEmpty && !_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(AvatarChoice(_selected));
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _selected != null && _selected != widget.currentUrl;
    final content = SizedBox(
      width: 380,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.photoPresets,
                style: AppTextStyles.label(context),
              ),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  for (final url in AvatarPresets.urls)
                    _PresetTile(
                      url: url,
                      selected: url == _selected,
                      onTap: () => _pickPreset(url),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: AppStrings.photoOwnLink,
                controller: _link,
                hint: AppStrings.photoUrl,
                keyboardType: TextInputType.url,
                validator: Validators.photoUrl,
                onChanged: _onLinkChanged,
              ),
              if (_preview != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  AppStrings.photoPreview,
                  style: AppTextStyles.caption(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                _LinkPreview(url: _preview!),
              ],
            ],
          ),
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
            onPressed: canConfirm ? _confirm : null,
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
          onPressed: canConfirm ? _confirm : null,
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
            child: UserAvatar(size: 52, photoUrl: url),
          ),
        ),
      ),
    );
  }
}

/// Image from the pasted link, or a message when it can't be loaded.
class _LinkPreview extends StatelessWidget {
  const _LinkPreview({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Image.network(
        url,
        key: ValueKey(url),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        // Round only the loaded image, not the error message.
        frameBuilder: (context, child, frame, sync) => ClipOval(child: child),
        errorBuilder: (context, error, stack) => Text(
          AppStrings.photoPreviewFailed,
          style: AppTextStyles.caption(context)
              .copyWith(color: AppPalette.of(context).error),
        ),
      ),
    );
  }
}
