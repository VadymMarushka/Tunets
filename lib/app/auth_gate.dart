import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/brand.dart';
import '../core/widgets/progress.dart';
import '../features/auth/sign_in_screen.dart';
import 'app_shell.dart';
import 'bloc/auth_bloc.dart';

/// Root page: shows the screen for the current [AuthState].
///
/// * unknown (Firebase restores the saved session on launch): splash;
/// * unauthenticated: sign-in screen;
/// * authenticated: the app shell.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => switch (state.status) {
        AuthStatus.unknown => const _Splash(),
        AuthStatus.unauthenticated => const SignInScreen(),
        // Keyed by uid: a different account gets a fresh shell state.
        AuthStatus.authenticated => AppShell(key: ValueKey(state.user!.uid)),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppPalette.of(context).background,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 64),
            SizedBox(height: 24),
            AppProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
