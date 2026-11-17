// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Labeled text input: Material [TextField] on Android, Fluent [fl.TextBox]
/// on Windows. The label sits above the field on both platforms (mockup).
///
/// Works inside a [Form]: [validator] runs on `FormState.validate()` and its
/// message is shown under the field on both platforms.
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
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofillHints,
    this.suggestions = const [],
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

  /// `false` while a request is running: the field can't be edited.
  final bool enabled;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;

  /// Values offered while typing, those that start with the typed text
  /// (ignoring case): "sh" → "Shatsk Pond". Empty = a plain field.
  final List<String> suggestions;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _ownController = TextEditingController(
    text: widget.initialValue,
  );

  TextEditingController get _controller => widget.controller ?? _ownController;

  final _focusNode = FocusNode();

  @override
  void dispose() {
    _ownController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Suggestions that start with the typed text (ignoring case), like a
  /// browser's address bar; at most 6. Nothing for an empty field or when
  /// the text already equals a suggestion.
  Iterable<String> _matches(TextEditingValue value) {
    final query = value.text.trimLeft().toLowerCase();
    if (query.isEmpty) return const [];
    return widget.suggestions
        .where((option) {
          final lower = option.toLowerCase();
          return lower != query && lower.startsWith(query);
        })
        .take(6);
  }

  /// Enter: picks the highlighted suggestion if the list is open, then
  /// calls [AppTextField.onSubmitted].
  void _submit(String value, VoidCallback? onSubmitSuggestion) {
    onSubmitSuggestion?.call();
    widget.onSubmitted?.call(_controller.text);
  }

  /// The platform field, plus the suggestion list under it when
  /// [AppTextField.suggestions] isn't empty.
  Widget _buildInput(
    BuildContext context,
    String? errorText,
    ValueChanged<String> onChanged,
  ) {
    Widget field({VoidCallback? onSubmitSuggestion}) => PlatformStyle.isFluent
        ? _buildFluent(context, errorText, onChanged, onSubmitSuggestion)
        : _buildMaterial(context, errorText, onChanged, onSubmitSuggestion);

    if (widget.suggestions.isEmpty) return field();
    return RawAutocomplete<String>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: _matches,
      // Keep the form field (validation) in step with the picked value.
      onSelected: onChanged,
      fieldViewBuilder: (context, _, _, onFieldSubmitted) =>
          field(onSubmitSuggestion: onFieldSubmitted),
      optionsViewBuilder: (context, onSelected, options) =>
          _SuggestionList(options: options.toList(), onSelected: onSelected),
    );
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
        void onChanged(String value) {
          field.didChange(value);
          widget.onChanged?.call(value);
        }

        return FieldLabel(
          label: widget.label,
          helperText: widget.helperText,
          errorText: errorText,
          // Material shows helper/error inside its decoration.
          showMessages: PlatformStyle.isFluent,
          child: _buildInput(context, errorText, onChanged),
        );
      },
    );
  }

  // ===== Android (Material 3) =====

  Widget _buildMaterial(
    BuildContext context,
    String? errorText,
    ValueChanged<String> onChanged,
    VoidCallback? onSubmitSuggestion,
  ) {
    final palette = AppPalette.of(context);
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      minLines: widget.maxLines > 1 ? 3 : null,
      onChanged: onChanged,
      onSubmitted: (value) => _submit(value, onSubmitSuggestion),
      style: widget.readOnly ? TextStyle(color: palette.secondaryText) : null,
      decoration: InputDecoration(
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: errorText,
        errorMaxLines: 2,
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

  // ===== Windows (Fluent) =====

  Widget _buildFluent(
    BuildContext context,
    String? errorText,
    ValueChanged<String> onChanged,
    VoidCallback? onSubmitSuggestion,
  ) {
    final palette = AppPalette.of(context);
    final errorColor = errorText != null ? palette.error : null;
    // Padding only on the outer side: the text box already keeps a gap
    // between its text and the icon.
    Widget? decorate(IconData? icon, EdgeInsetsGeometry padding) => icon == null
        ? null
        : Padding(
            padding: padding,
            child: Icon(icon, size: 16, color: palette.secondaryText),
          );
    return fl.TextBox(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly,
      enabled: widget.enabled && !widget.readOnly,
      autofillHints: widget.autofillHints,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      minLines: widget.maxLines > 1 ? 3 : null,
      placeholder: widget.hint,
      onChanged: onChanged,
      onSubmitted: (value) => _submit(value, onSubmitSuggestion),
      // Red underline while the field has a validation error.
      highlightColor: errorColor,
      unfocusedColor: errorColor,
      prefix: decorate(
        widget.prefixIcon,
        const EdgeInsetsDirectional.only(start: AppSpacing.sm),
      ),
      suffix: decorate(
        widget.suffixIcon,
        const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      ),
    );
  }
}

/// Drop-down under a field with suggestions. Shared look on both
/// platforms (a card like the app's others); the option chosen with the
/// arrow keys is highlighted, which matters on Windows.
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.options, required this.onSelected});

  final List<String> options;
  final AutocompleteOnSelected<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final isFluent = PlatformStyle.isFluent;
    final highlighted = AutocompleteHighlightedOption.of(context);
    final radius = isFluent ? AppRadius.fluent : AppRadius.material;

    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Material(
          color: palette.surface,
          elevation: 4,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: palette.layerBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return InkWell(
                  onTap: () => onSelected(option),
                  hoverColor: palette.subtleHover,
                  child: Container(
                    color: index == highlighted ? palette.subtleHover : null,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      // Touch targets of at least 48 px on Android.
                      vertical: isFluent ? AppSpacing.s : AppSpacing.sm,
                    ),
                    child: Text(option, style: AppTextStyles.body(context)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
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
