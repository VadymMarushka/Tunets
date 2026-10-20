import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Material 3 theme for Android (narrow and wide layouts).
ThemeData buildMaterialTheme(Brightness brightness) {
  final p = AppPalette.forBrightness(brightness);

  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppPalette.light.primary,
        brightness: brightness,
      ).copyWith(
        primary: p.primary,
        onPrimary: p.onPrimary,
        primaryContainer: p.primaryContainer,
        onPrimaryContainer: p.onPrimaryContainer,
        secondaryContainer: p.primaryContainer,
        onSecondaryContainer: p.onPrimaryContainer,
        surface: p.surface,
        onSurface: p.onSurface,
        onSurfaceVariant: p.secondaryText,
        surfaceContainerLowest: p.surface,
        surfaceContainerLow: p.surface2,
        surfaceContainer: p.surface2,
        surfaceContainerHigh: p.surfaceVariant,
        surfaceContainerHighest: p.surfaceVariant,
        outline: p.outline,
        outlineVariant: p.outline,
        error: p.error,
      );

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.material),
    borderSide: BorderSide(color: p.outline),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.material),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 14,
      ),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      disabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: p.primary, width: 2),
      ),
      errorBorder: fieldBorder.copyWith(borderSide: BorderSide(color: p.error)),
      focusedErrorBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: p.error, width: 2),
      ),
      hintStyle: TextStyle(color: p.secondaryText),
      helperStyle: TextStyle(color: p.secondaryText),
      prefixIconColor: p.secondaryText,
      suffixIconColor: p.secondaryText,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, AppSizes.minTouchTarget),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, AppSizes.minTouchTarget),
        shape: const StadiumBorder(),
        side: BorderSide(color: p.outline),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, AppSizes.minTouchTarget),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primaryContainer,
      foregroundColor: p.onPrimaryContainer,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface2,
      indicatorColor: p.primaryContainer,
      surfaceTintColor: Colors.transparent,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: p.surface2,
      indicatorColor: p.primaryContainer,
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: p.outline),
      selectedColor: p.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.fluent),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: brightness == Brightness.light
          ? const Color(0xFF253433)
          : const Color(0xFFE2EEEC),
    ),
    dividerTheme: DividerThemeData(color: p.outline, space: 1),
    // Same subtle, translucent scrollbar thumb as on Windows.
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => p.onSurface.withValues(
          alpha: states.contains(WidgetState.dragged) ? 0.45 : 0.25,
        ),
      ),
    ),
  );
}
