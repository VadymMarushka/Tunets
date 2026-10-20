import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_shell.dart';
import '../../core/platform/platform_style.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/auth_layout.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/password_field.dart';
import '../../data/mock/mock_data.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';

/// S-1. Sign in (FR-1).
///
/// No real authentication in this lab: "Sign in" opens the home screen as if
/// the credentials were correct.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  void _signIn(BuildContext context) => context.resetTo(const AppShell());

  @override
  Widget build(BuildContext context) {
    final isFluent = PlatformStyle.isFluent;
    return AuthLayout(
      children: [
        if (isFluent) ...[
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
          initialValue: MockData.user.email,
          prefixIcon: AppIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.m),
        const PasswordField(
          label: AppStrings.password,
          initialValue: 'fishing2026',
          textInputAction: TextInputAction.done,
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: AppButton.text(
            label: AppStrings.forgotPassword,
            onPressed: () => context.pushPage(const ResetPasswordScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        AppButton(
          label: AppStrings.signIn,
          expand: true,
          onPressed: () => _signIn(context),
        ),
        const SizedBox(height: AppSpacing.m),
        AuthSwitchLine(
          text: AppStrings.newHere,
          action: AppButton.text(
            label: AppStrings.register,
            onPressed: () => context.pushPage(const RegisterScreen()),
          ),
        ),
      ],
    );
  }
}
