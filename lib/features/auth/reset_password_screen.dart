// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/platform/platform_style.dart';
import '../../core/services/analytics_service.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/auth_layout.dart';
import '../../core/widgets/dialogs.dart';
import 'bloc/auth_form_bloc.dart';

/// S-3. Reset password by email (FR-1).
///
/// Firebase sends a letter with a link to set a new password. With email
/// enumeration protection it doesn't reveal whether the account exists,
/// so the confirmation is worded neutrally.
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, this.initialEmail = ''});

  /// Email already typed on the sign-in screen.
  final String initialEmail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthFormBloc(
        auth: context.read(),
        analytics: context.read(),
        crashes: context.read(),
      ),
      child: _ResetPasswordForm(initialEmail: initialEmail),
    );
  }
}

class _ResetPasswordForm extends StatefulWidget {
  const _ResetPasswordForm({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<_ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);

  /// Where the last link went: shown under the form until the page closes
  /// (ephemeral state of this screen, so plain `setState`).
  String? _sentTo;

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsService>().logScreen('reset_password');
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _sendLink() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthFormBloc>().add(
      PasswordResetRequested(email: _email.text),
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
          setState(() => _sentTo = state.email);
        }
      },
      child: _buildForm(context, loading: loading),
    );
  }

  Widget _buildForm(BuildContext context, {required bool loading}) {
    final palette = AppPalette.of(context);
    final isFluent = PlatformStyle.isFluent;
    final align = isFluent ? TextAlign.start : TextAlign.center;
    final sentTo = _sentTo;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: AuthLayout(
        showBack: true,
        children: [
          Align(
            alignment: isFluent
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.center,
            child: Container(
              width: isFluent ? 40 : 56,
              height: isFluent ? 40 : 56,
              decoration: BoxDecoration(
                color: palette.primaryContainer,
                shape: isFluent ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: isFluent
                    ? BorderRadius.circular(AppRadius.fluent)
                    : null,
              ),
              child: Icon(AppIcons.mail, color: palette.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            sentTo != null ? AppStrings.checkInbox : AppStrings.resetPassword,
            style: AppTextStyles.title(context),
            textAlign: align,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            sentTo != null
                ? AppStrings.resetLinkSent(sentTo)
                : AppStrings.resetPasswordDescription,
            style: AppTextStyles.secondary(context),
            textAlign: align,
          ),
          const SizedBox(height: AppSpacing.l),
          if (sentTo == null) ...[
            AppTextField(
              label: AppStrings.email,
              hint: AppStrings.emailHint,
              controller: _email,
              enabled: !loading,
              prefixIcon: AppIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              onSubmitted: (_) => _sendLink(),
            ),
            const SizedBox(height: AppSpacing.m),
            AppButton(
              label: AppStrings.sendResetLink,
              expand: true,
              loading: loading,
              onPressed: _sendLink,
            ),
          ] else
            AppButton(
              label: AppStrings.backToSignIn,
              expand: true,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          if (!isFluent && sentTo == null) ...[
            // Android (Material 3) only
            const SizedBox(height: AppSpacing.m),
            AuthSwitchLine(
              text: AppStrings.rememberedIt,
              action: AppButton.text(
                label: AppStrings.backToSignIn,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
