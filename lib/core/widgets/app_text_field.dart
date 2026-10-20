import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Labeled text input: Material [TextField] on Android, Fluent [fl.TextBox]
/// on Windows. The label sits above the field on both platforms (mockup).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.initialValue,
    this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final String? initialValue;
  final TextEditingController? controller;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _ownController = TextEditingController(
    text: widget.initialValue,
  );

  TextEditingController get _controller => widget.controller ?? _ownController;

  @override
  void dispose() {
    _ownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = PlatformStyle.isFluent
        ? _buildFluent(context)
        : _buildMaterial(context);
    return FieldLabel(
      label: widget.label,
      helperText: widget.helperText,
      errorText: widget.errorText,
      // Material shows helper/error inside its decoration.
      showMessages: PlatformStyle.isFluent,
      child: field,
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final palette = AppPalette.of(context);
    return TextField(
      controller: _controller,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      minLines: widget.maxLines > 1 ? 3 : null,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: widget.readOnly ? TextStyle(color: palette.secondaryText) : null,
      decoration: InputDecoration(
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        fillColor: widget.readOnly ? palette.surfaceVariant : null,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 20),
        suffixIcon: widget.suffixIcon == null
            ? null
            : Icon(widget.suffixIcon, size: 20),
      ),
    );
  }

  Widget _buildFluent(BuildContext context) {
    final palette = AppPalette.of(context);
    Widget? decorate(IconData? icon) => icon == null
        ? null
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: Icon(icon, size: 16, color: palette.secondaryText),
          );
    return fl.TextBox(
      controller: _controller,
      readOnly: widget.readOnly,
      enabled: !widget.readOnly,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      minLines: widget.maxLines > 1 ? 3 : null,
      placeholder: widget.hint,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      prefix: decorate(widget.prefixIcon),
      suffix: decorate(widget.suffixIcon),
    );
  }
}

/// Label above a form control with optional helper / error text below.
/// Shared by all form controls so they line up identically.
class FieldLabel extends StatelessWidget {
  const FieldLabel({
    super.key,
    required this.label,
    required this.child,
    this.helperText,
    this.errorText,
    this.showMessages = true,
  });

  final String label;
  final Widget child;
  final String? helperText;
  final String? errorText;
  final bool showMessages;

  @override
  Widget build(BuildContext context) {
    final message = errorText ?? helperText;
    final isFluent = PlatformStyle.isFluent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: isFluent
              ? AppTextStyles.body(context)
              : AppTextStyles.label(context),
        ),
        SizedBox(height: isFluent ? AppSpacing.s : AppSpacing.xs),
        child,
        if (showMessages && message != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: AppTextStyles.caption(context).copyWith(
              color: errorText != null ? AppPalette.of(context).error : null,
            ),
          ),
        ],
      ],
    );
  }
}
