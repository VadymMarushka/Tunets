// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/platform/platform_style.dart';
import '../core/strings/app_strings.dart';
import '../core/theme/fluent_theme.dart';
import '../core/theme/material_theme.dart';
import 'auth_gate.dart';
import 'bloc/theme_bloc.dart';

/// Root widget. One code base, two design languages:
/// [MaterialApp] (Material 3) on Android, [fl.FluentApp] on Windows.
/// The theme mode (system / light / dark) comes from [ThemeBloc].
class TunetsApp extends StatelessWidget {
  const TunetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select((ThemeBloc bloc) => bloc.state.mode);

    // ----- Windows (Fluent); the Android (Material 3) version follows -----
    if (PlatformStyle.isFluent) {
      return fl.FluentApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: buildFluentTheme(Brightness.light),
        darkTheme: buildFluentTheme(Brightness.dark),
        // fluent_ui has its own ThemeMode enum with the same values.
        themeMode: fl.ThemeMode.values.byName(themeMode.name),
        // Material localizations let Material-only helpers (e.g. tooltips
        // inside shared widgets) work under FluentApp as well.
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          fl.FluentLocalizations.delegate,
        ],
        // The interface is English only (LR2); without this FluentApp
        // advertises every Fluent locale, e.g. uk, which the Material
        // delegate can't serve (a framework error on Ukrainian Windows).
        supportedLocales: const [Locale('en')],
        home: const AuthGate(),
      );
    }
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildMaterialTheme(Brightness.light),
      darkTheme: buildMaterialTheme(Brightness.dark),
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}
