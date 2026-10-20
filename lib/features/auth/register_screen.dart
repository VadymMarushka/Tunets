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

/// S-2. Create account (FR-1). "Register" opens the home screen directly.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: true,
      children: [
        Row(
          children: [
            if (!PlatformStyle.isFluent) ...[
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
        const AppTextField(
          label: AppStrings.name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.m),
        AppTextField(
          label: AppStrings.email,
          prefixIcon: AppIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.m),
        const PasswordField(
          label: AppStrings.password,
          helperText: AppStrings.passwordHint,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.m),
        const PasswordField(
          label: AppStrings.confirmPassword,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.l),
        AppButton(
          label: AppStrings.register,
          expand: true,
          onPressed: () => context.resetTo(const AppShell()),
        ),
        const SizedBox(height: AppSpacing.m),
        AuthSwitchLine(
          text: AppStrings.alreadyHaveAccount,
          action: AppButton.text(
            label: AppStrings.signIn,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}
