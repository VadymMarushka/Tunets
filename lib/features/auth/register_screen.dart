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

/// S-2. Create an account with name, email and password (FR-1).
///
/// Firebase signs the new user in right away, so on success `AuthGate`
/// opens the home screen.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    AppServices.of(context).analytics.logScreen('register');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    final services = AppServices.of(context);
    setState(() => _loading = true);
    try {
      await services.auth.signUp(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      services.analytics.logSignUp();
      if (mounted) context.returnToRoot();
    } on AuthFailure catch (e) {
      if (mounted) showNotice(context, e.message, kind: NoticeKind.error);
    } catch (e, stack) {
      services.crashes.recordError(e, stack, reason: 'sign_up');
      if (mounted) {
        showNotice(context, AppStrings.unexpectedError, kind: NoticeKind.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: AutofillGroup(
        child: AuthLayout(
          showBack: true,
          children: [
            Row(
              children: [
                if (!PlatformStyle.isFluent) ...[
                  // Android (Material 3) only
                  const AppLogo(size: 40),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.createAccount,
                        style: AppTextStyles.title(context),
                      ),
                      Text(
                        AppStrings.createAccountSubtitle,
                        style: AppTextStyles.caption(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            AppTextField(
              label: AppStrings.name,
              controller: _name,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.name,
            ),
            const SizedBox(height: AppSpacing.m),
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
            const SizedBox(height: AppSpacing.m),
            PasswordField(
              label: AppStrings.password,
              controller: _password,
              enabled: !_loading,
              helperText: AppStrings.passwordHint,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.newPassword,
            ),
            const SizedBox(height: AppSpacing.m),
            PasswordField(
              label: AppStrings.confirmPassword,
              controller: _confirm,
              enabled: !_loading,
              textInputAction: TextInputAction.done,
              validator: Validators.confirmPassword(() => _password.text),
              onSubmitted: (_) => _register(),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              label: AppStrings.register,
              expand: true,
              loading: _loading,
              onPressed: _register,
            ),
            const SizedBox(height: AppSpacing.m),
            AuthSwitchLine(
              text: AppStrings.alreadyHaveAccount,
              action: AppButton.text(
                label: AppStrings.signIn,
                onPressed: _loading
                    ? null
                    : () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
