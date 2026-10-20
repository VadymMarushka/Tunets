import 'package:flutter/material.dart';

import '../../core/platform/platform_style.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/auth_layout.dart';
import '../../data/mock/mock_data.dart';

/// S-3. Reset password by email (FR-1).
///
/// "Send reset link" only switches the screen to its confirmation state;
/// no email is sent in this lab.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _linkSent = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final isFluent = PlatformStyle.isFluent;
    final align = isFluent ? TextAlign.start : TextAlign.center;

    return AuthLayout(
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
          _linkSent ? AppStrings.checkInbox : AppStrings.resetPassword,
          style: AppTextStyles.title(context),
          textAlign: align,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _linkSent
              ? AppStrings.resetLinkSent(MockData.user.email)
              : AppStrings.resetPasswordDescription,
          style: AppTextStyles.secondary(context),
          textAlign: align,
        ),
        const SizedBox(height: AppSpacing.l),
        if (!_linkSent) ...[
          AppTextField(
            label: AppStrings.email,
            initialValue: MockData.user.email,
            prefixIcon: AppIcons.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton(
            label: AppStrings.sendResetLink,
            expand: true,
            onPressed: () => setState(() => _linkSent = true),
          ),
        ] else
          AppButton(
            label: AppStrings.backToSignIn,
            expand: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        if (!isFluent && !_linkSent) ...[
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
    );
  }
}
