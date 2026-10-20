// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../core/platform/platform_style.dart';
import '../core/strings/app_strings.dart';
import '../core/theme/fluent_theme.dart';
import '../core/theme/material_theme.dart';
import '../features/auth/sign_in_screen.dart';

/// Root widget. One code base, two design languages:
/// [MaterialApp] (Material 3) on Android, [fl.FluentApp] on Windows.
/// The theme follows the system light / dark setting.
class TunetsApp extends StatelessWidget {
  const TunetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ----- Windows (Fluent); the Android (Material 3) version follows -----
    if (PlatformStyle.isFluent) {
      return fl.FluentApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: buildFluentTheme(Brightness.light),
        darkTheme: buildFluentTheme(Brightness.dark),
        themeMode: fl.ThemeMode.system,
        // Material localizations let Material-only helpers (e.g. tooltips
        // inside shared widgets) work under FluentApp as well.
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          fl.FluentLocalizations.delegate,
        ],
        home: const SignInScreen(),
      );
    }
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildMaterialTheme(Brightness.light),
      darkTheme: buildMaterialTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const SignInScreen(),
    );
  }
}
