// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 'app_text_field.dart';

/// Single-choice dropdown: Material dropdown on Android, ComboBox on Windows.
class AppSelectField extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.errorText,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? placeholder;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    // ----- Windows (Fluent); the Android (Material 3) version follows -----
    if (PlatformStyle.isFluent) {
      return FieldLabel(
        label: label,
        errorText: errorText,
        child: fl.ComboBox<String>(
          isExpanded: true,
          value: value,
          placeholder: placeholder == null ? null : Text(placeholder!),
          items: [
            for (final option in options)
              fl.ComboBoxItem(value: option, child: Text(option)),
          ],
          onChanged: onChanged,
        ),
      );
    }
    return FieldLabel(
      label: label,
      showMessages: false,
      child: DropdownButtonFormField<String>(
        // Recreate when the value changes from outside.
        key: ValueKey(value),
        initialValue: value,
        isExpanded: true,
        hint: placeholder == null ? null : Text(placeholder!),
        decoration: InputDecoration(errorText: errorText),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Date field. Uses the platform's own picker (system dialog on Android,
/// Fluent DatePicker flyout on Windows) — LR2 requires system pickers.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    // ----- Windows (Fluent); the Android (Material 3) version follows -----
    if (PlatformStyle.isFluent) {
      return FieldLabel(
        label: label,
        child: fl.DatePicker(
          selected: value,
          onChanged: onChanged,
          endDate: DateTime(2100),
        ),
      );
    }
    return FieldLabel(
      label: label,
      showMessages: false,
      child: _PickerButton(
        icon: AppIcons.calendar,
        text: Formatters.date(value),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onChanged(
              DateTime(
                picked.year,
                picked.month,
                picked.day,
                value.hour,
                value.minute,
              ),
            );
          }
        },
      ),
    );
  }
}

/// Time field with the platform's own time picker.
class AppTimeField extends StatelessWidget {
  const AppTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    // ----- Windows (Fluent); the Android (Material 3) version follows -----
    if (PlatformStyle.isFluent) {
      return FieldLabel(
        label: label,
        child: fl.TimePicker(
          selected: value,
          hourFormat: fl.HourFormat.HH,
          onChanged: onChanged,
        ),
      );
    }
    return FieldLabel(
      label: label,
      showMessages: false,
      child: _PickerButton(
        icon: AppIcons.clock,
        text: Formatters.time(value),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(value),
          );
          if (picked != null) {
            onChanged(
              DateTime(
                value.year,
                value.month,
                value.day,
                picked.hour,
                picked.minute,
              ),
            );
          }
        },
      ),
    );
  }
}

/// Material field look-alike that opens a picker on tap.
class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final radius = BorderRadius.circular(AppRadius.material);
    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.outline),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Row(
              children: [
                Icon(icon, size: 20, color: palette.secondaryText),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(text, style: AppTextStyles.body(context))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
