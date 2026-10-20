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
import 'brand.dart';

/// Shared layout of the sign-in, register and reset-password screens.
///
/// Android: full-screen form with a back arrow in the app bar.
/// Windows: centered card on a Mica-like backdrop, with a
/// "← Back to sign in" link inside the card.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.children, this.showBack = false});

  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return PlatformStyle.isFluent
        ? _buildFluent(context)
        : _buildMaterial(context);
  }

  // ===== Android (Material 3) =====

  Widget _buildMaterial(BuildContext context) {
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.authCard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== Windows (Fluent) =====

  Widget _buildFluent(BuildContext context) {
    final palette = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.mica,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 32),
                  const SizedBox(width: AppSpacing.sm),
                  Text(AppStrings.appName, style: AppTextStyles.title(context)),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: fl.Card(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  borderRadius: BorderRadius.circular(AppRadius.fluent),
                  backgroundColor: palette.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showBack) ...[
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: fl.HyperlinkButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: const Text('← ${AppStrings.backToSignIn}'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                      ],
                      ...children,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "New here? Register" style line: plain text followed by a link button.
class AuthSwitchLine extends StatelessWidget {
  const AuthSwitchLine({super.key, required this.text, required this.action});

  final String text;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(text, style: AppTextStyles.secondary(context)),
        action,
      ],
    );
  }
}
