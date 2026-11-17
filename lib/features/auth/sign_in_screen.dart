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
import 'register_screen.dart';
import 'reset_password_screen.dart';

/// S-1. Sign in with email and password (FR-1).
///
/// The request and its state (loading / error) live in [AuthFormBloc];
/// the screen only validates the form and shows the state. On success
/// `AuthBloc` gets the user and `AuthGate` switches to the home screen.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthFormBloc(
        auth: context.read(),
        analytics: context.read(),
        crashes: context.read(),
      ),
      child: const _SignInForm(),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsService>().logScreen('sign_in');
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthFormBloc>().add(
      SignInSubmitted(email: _email.text, password: _password.text),
    );
  }

  /// One-off reaction to success: close the register / reset pages if they
  /// were opened on top (the form itself is rebuilt below).
  void _onStateChanged(BuildContext context, AuthFormState state) {
    if (state.status == AuthFormStatus.success) context.returnToRoot();
  }

  @override
  Widget build(BuildContext context) {
    final isFluent = PlatformStyle.isFluent;
    final loading = context.select((AuthFormBloc bloc) => bloc.state.isLoading);
    // Shown in the form (mockup), until the next attempt clears it.
    final error = context.select(
      (AuthFormBloc bloc) => bloc.state.status == AuthFormStatus.failure
          ? bloc.state.message
          : null,
    );
    return BlocListener<AuthFormBloc, AuthFormState>(
      listener: _onStateChanged,
      child: _buildForm(
        context,
        isFluent: isFluent,
        loading: loading,
        error: error,
      ),
    );
  }

  Widget _buildForm(
    BuildContext context, {
    required bool isFluent,
    required bool loading,
    required String? error,
  }) {
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
              const Center(child: AppLogo(size: 80)),
              const SizedBox(height: AppSpacing.m),
              Text(
                AppStrings.appName,
                style: AppTextStyles.headline(context).copyWith(
                  fontSize: 32,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                AppStrings.tagline,
                style: AppTextStyles.secondary(context).copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: isFluent ? AppSpacing.m : AppSpacing.xl),
            if (isFluent && error != null) ...[
              // Windows (Fluent) only: error bar inside the card (mockup).
              FormErrorBar(message: error),
              const SizedBox(height: AppSpacing.m),
            ],
            AppTextField(
              label: AppStrings.email,
              hint: AppStrings.emailHint,
              controller: _email,
              enabled: !loading,
              // Mockup: the mail icon only in the Android field.
              prefixIcon: isFluent ? null : AppIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            SizedBox(height: AuthLayout.fieldGap),
            PasswordField(
              label: AppStrings.password,
              hint: AppStrings.passwordEnterHint,
              controller: _password,
              enabled: !loading,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: Validators.passwordEntered,
              // Android (Material 3): the error goes under the field.
              errorText: isFluent ? null : error,
              onSubmitted: (_) => _signIn(),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppButton.text(
                label: AppStrings.forgotPassword,
                onPressed: loading
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
              loading: loading,
              onPressed: _signIn,
            ),
            const SizedBox(height: AppSpacing.m),
            AuthSwitchLine(
              text: AppStrings.newHere,
              action: AppButton.text(
                label: AppStrings.register,
                onPressed: loading
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
