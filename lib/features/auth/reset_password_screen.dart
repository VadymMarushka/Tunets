// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';

import '../../app/app_services.dart';
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
import '../../data/repositories/auth_failure.dart';

/// S-3. Reset password by email (FR-1).
///
/// Firebase sends a letter with a link to set a new password. With email
/// enumeration protection it doesn't reveal whether the account exists,
/// so the confirmation is worded neutrally.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail = ''});

  /// Email already typed on the sign-in screen.
  final String initialEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _loading = false;
  String? _sentTo;

  @override
  void initState() {
    super.initState();
    AppServices.of(context).analytics.logScreen('reset_password');
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    final services = AppServices.of(context);
    final email = _email.text.trim();
    setState(() => _loading = true);
    try {
      await services.auth.sendPasswordReset(email: email);
      services.analytics.logEvent(AnalyticsEvents.passwordResetRequested);
      if (mounted) setState(() => _sentTo = email);
    } on AuthFailure catch (e) {
      if (mounted) showNotice(context, e.message, kind: NoticeKind.error);
    } catch (e, stack) {
      services.crashes.recordError(e, stack, reason: 'password_reset');
      if (mounted) {
        showNotice(context, AppStrings.unexpectedError, kind: NoticeKind.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _email,
              enabled: !_loading,
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
              loading: _loading,
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
