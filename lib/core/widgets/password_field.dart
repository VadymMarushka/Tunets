// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../strings/app_strings.dart';
import '../theme/app_icons.dart';
import 'app_text_field.dart';

/// Password input with a show/hide toggle.
///
/// Windows uses the native-looking [fl.PasswordBox] reveal button; Android
/// uses an eye icon button (48 dp target).
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    this.initialValue,
    this.helperText,
    this.errorText,
    this.textInputAction,
  });

  final String label;
  final String? initialValue;
  final String? helperText;
  final String? errorText;
  final TextInputAction? textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late final _controller = TextEditingController(text: widget.initialValue);
  bool _obscured = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FieldLabel(
      label: widget.label,
      helperText: widget.helperText,
      errorText: widget.errorText,
      showMessages: PlatformStyle.isFluent,
      child: PlatformStyle.isFluent
          ? fl.PasswordBox(
              controller: _controller,
              revealMode: fl.PasswordRevealMode.peekAlways,
            )
          : TextField(
              controller: _controller,
              obscureText: _obscured,
              textInputAction: widget.textInputAction,
              decoration: InputDecoration(
                helperText: widget.helperText,
                errorText: widget.errorText,
                suffixIcon: IconButton(
                  tooltip: _obscured
                      ? AppStrings.showPassword
                      : AppStrings.hidePassword,
                  icon: Icon(
                    _obscured ? AppIcons.visibility : AppIcons.visibilityOff,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                ),
              ),
            ),
    );
  }
}
