// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../strings/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import 'app_text_field.dart';

/// Password input with a show/hide toggle.
///
/// Windows uses the native-looking [fl.PasswordBox] reveal button; Android
/// uses an eye icon button (48 dp target). Supports [Form] validation like
/// [AppTextField].
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.helperText,
    this.errorText,
    this.textInputAction,
    this.enabled = true,
    this.validator,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? helperText;
  final String? errorText;
  final TextInputAction? textInputAction;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late final _ownController = TextEditingController(text: widget.initialValue);
  bool _obscured = true;

  TextEditingController get _controller => widget.controller ?? _ownController;

  @override
  void dispose() {
    _ownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: _controller.text,
      validator: widget.validator == null
          ? null
          : (_) => widget.validator!(_controller.text),
      builder: (field) {
        final errorText = field.errorText ?? widget.errorText;
        final errorColor = errorText != null
            ? AppPalette.of(context).error
            : null;
        return FieldLabel(
          label: widget.label,
          helperText: widget.helperText,
          errorText: errorText,
          showMessages: PlatformStyle.isFluent,
          // ----- Windows (Fluent); the Android (Material 3) version follows
          child: PlatformStyle.isFluent
              ? fl.PasswordBox(
                  controller: _controller,
                  enabled: widget.enabled,
                  revealMode: fl.PasswordRevealMode.peekAlways,
                  onChanged: field.didChange,
                  onSubmitted: widget.onSubmitted,
                  highlightColor: errorColor,
                  unfocusedColor: errorColor,
                )
              : TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  obscureText: _obscured,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  onChanged: field.didChange,
                  onSubmitted: widget.onSubmitted,
                  decoration: InputDecoration(
                    helperText: widget.helperText,
                    errorText: errorText,
                    errorMaxLines: 2,
                    suffixIcon: IconButton(
                      tooltip: _obscured
                          ? AppStrings.showPassword
                          : AppStrings.hidePassword,
                      icon: Icon(
                        _obscured
                            ? AppIcons.visibility
                            : AppIcons.visibilityOff,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscured = !_obscured),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
