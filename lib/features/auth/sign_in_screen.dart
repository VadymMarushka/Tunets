// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_services.dart';
import '../../core/platform/platform_style.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/auth_layout.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/password_field.dart';
import '../../data/repositories/auth_failure.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';

/// S-1. Sign in with email and password (FR-1).
///
/// On success `AuthGate` (the app root) switches to the home screen.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    AppServices.of(context).analytics.logScreen('sign_in');
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    final services = AppServices.of(context);
    setState(() => _loading = true);
    try {
      await services.auth.signIn(email: _email.text, password: _password.text);
      services.analytics.logLogin();
      if (mounted) context.returnToRoot();
    } on AuthFailure catch (e) {
      if (mounted) showNotice(context, e.message, kind: NoticeKind.error);
    } catch (e, stack) {
      services.crashes.recordError(e, stack, reason: 'sign_in');
      if (mounted) {
        showNotice(context, AppStrings.unexpectedError, kind: NoticeKind.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFluent = PlatformStyle.isFluent;
    return Form(
      key: _formKey,
      // Errors appear after the first submit and update while typing.
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: AutofillGroup(
        child: AuthLayout(
          children: [
            if (isFluent) ...[
              // Windows (Fluent) only
              Text(AppStrings.signIn, style: AppTextStyles.title(context)),
              Text(AppStrings.tagline, style: AppTextStyles.caption(context)),
            ] else ...[
              const Center(child: AppLogo(size: 64)),
              const SizedBox(height: AppSpacing.m),
              Text(
                AppStrings.appName,
                style: AppTextStyles.headline(context)
                    .copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.tagline,
                style: AppTextStyles.secondary(context),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: isFluent ? AppSpacing.m : AppSpacing.xl),
            AppTextField(
              label: AppStrings.email,
              controller: _email,
              enabled: !_loading,
              prefixIcon: AppIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            SizedBox(height: AuthLayout.fieldGap),
            PasswordField(
              label: AppStrings.password,
              controller: _password,
              enabled: !_loading,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: Validators.passwordEntered,
              onSubmitted: (_) => _signIn(),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppButton.text(
                label: AppStrings.forgotPassword,
                onPressed: _loading
                    ? null
                    : () => context.pushPage(
                        ResetPasswordScreen(initialEmail: _email.text.trim()),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            AppButton(
              label: AppStrings.signIn,
              expand: true,
              loading: _loading,
              onPressed: _signIn,
            ),
            const SizedBox(height: AppSpacing.m),
            AuthSwitchLine(
              text: AppStrings.newHere,
              action: AppButton.text(
                label: AppStrings.register,
                onPressed: _loading
                    ? null
                    : () => context.pushPage(const RegisterScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
