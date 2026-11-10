// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_routes.dart';
import '../../core/platform/platform_style.dart';
import '../../core/services/analytics_service.dart';
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
import 'bloc/auth_form_bloc.dart';

/// S-2. Create an account with name, email and password (FR-1).
///
/// Firebase signs the new user in right away, so on success `AuthGate`
/// opens the home screen.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthFormBloc(
        auth: context.read(),
        analytics: context.read(),
        crashes: context.read(),
      ),
      child: const _RegisterForm(),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsService>().logScreen('register');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthFormBloc>().add(
      RegisterSubmitted(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((AuthFormBloc bloc) => bloc.state.isLoading);
    return BlocListener<AuthFormBloc, AuthFormState>(
      listener: (context, state) {
        if (state.status == AuthFormStatus.failure) {
          showNotice(context, state.message!, kind: NoticeKind.error);
        } else if (state.status == AuthFormStatus.success) {
          // Close this page; AuthGate (the root) shows the home screen.
          context.returnToRoot();
        }
      },
      child: _buildForm(context, loading: loading),
    );
  }

  Widget _buildForm(BuildContext context, {required bool loading}) {
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
              enabled: !loading,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.name,
            ),
            SizedBox(height: AuthLayout.fieldGap),
            AppTextField(
              label: AppStrings.email,
              controller: _email,
              enabled: !loading,
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
              enabled: !loading,
              helperText: AppStrings.passwordHint,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.newPassword,
            ),
            SizedBox(height: AuthLayout.fieldGap),
            PasswordField(
              label: AppStrings.confirmPassword,
              controller: _confirm,
              enabled: !loading,
              textInputAction: TextInputAction.done,
              validator: Validators.confirmPassword(() => _password.text),
              onSubmitted: (_) => _register(),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              label: AppStrings.register,
              expand: true,
              loading: loading,
              onPressed: _register,
            ),
            const SizedBox(height: AppSpacing.m),
            AuthSwitchLine(
              text: AppStrings.alreadyHaveAccount,
              action: AppButton.text(
                label: AppStrings.signIn,
                onPressed: loading
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
