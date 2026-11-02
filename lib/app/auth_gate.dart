import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/brand.dart';
import '../core/widgets/progress.dart';
import '../data/models/user_profile.dart';
import '../features/auth/sign_in_screen.dart';
import 'app_services.dart';
import 'app_shell.dart';

/// Root page: follows the Firebase auth state.
///
/// * While Firebase restores the saved session on launch: splash.
/// * Signed out: sign-in screen.
/// * Signed in: the app shell, with [CurrentUser] for the screens.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<UserProfile?> _user;
  String? _lastUid;

  @override
  void initState() {
    super.initState();
    _user = AppServices.of(context).auth.userChanges();
  }

  /// Links crash reports to the signed-in user (uid only, no email).
  void _syncCrashUser(UserProfile? user) {
    if (user?.uid == _lastUid) return;
    _lastUid = user?.uid;
    AppServices.of(context).crashes.setUser(user?.uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: _user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }
        final user = snapshot.data;
        _syncCrashUser(user);
        if (user == null) return const SignInScreen();
        return CurrentUser(
          user: user,
          // Keyed by uid: a different account gets a fresh shell state.
          child: AppShell(key: ValueKey(user.uid)),
        );
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
