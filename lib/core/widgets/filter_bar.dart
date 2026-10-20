// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';
import '../theme/app_spacing.dart';

/// Row of mutually exclusive filters ("All / This month / This year").
/// Material filter chips on Android, toggle buttons on Windows.
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (var i = 0; i < labels.length; i++)
          if (PlatformStyle
              .isFluent) // Windows (Fluent); else Android (Material 3)
            fl.ToggleButton(
              checked: i == selectedIndex,
              onChanged: (_) => onSelected(i),
              child: Text(labels[i]),
            )
          else
            FilterChip(
              label: Text(labels[i]),
              selected: i == selectedIndex,
              onSelected: (_) => onSelected(i),
            ),
      ],
    );
  }
}

/// Search input: Material search bar on Android, TextBox on Windows.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.icon,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // ----- Windows (Fluent); the Android (Material 3) version follows -----
    if (PlatformStyle.isFluent) {
      return fl.TextBox(
        placeholder: hint,
        onChanged: onChanged,
        prefix: Padding(
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.s),
          child: Icon(icon, size: 14),
        ),
      );
    }
    return SearchBar(
      hintText: hint,
      onChanged: onChanged,
      elevation: const WidgetStatePropertyAll(0),
      leading: Icon(icon),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpacing.m),
      ),
    );
  }
}
