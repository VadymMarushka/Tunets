// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/platform/platform_style.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/section_header.dart';
import '../../data/mock/mock_data.dart';
import '../auth/sign_in_screen.dart';

/// S-8. Profile (FR-2, FR-5): personal info with photo, password change and
/// sign out. Buttons show confirmations only — nothing is persisted yet.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _signOut(BuildContext context) => context.resetTo(const SignInScreen());

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AppStrings.navProfile,
      actions: [
        PageAction(
          label: AppStrings.signOut,
          icon: AppIcons.signOut,
          onPressed: () => _signOut(context),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= Breakpoints.twoColumns;
          const personal = _PersonalInfoSection();
          const password = _ChangePasswordSection();

          return SingleChildScrollView(
            padding: pagePadding(),
            child: ContentConstraint(
              child: twoColumns
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: personal),
                        SizedBox(width: AppSpacing.l),
                        Expanded(child: password),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        personal,
                        const SizedBox(height: AppSpacing.l),
                        password,
                        if (!PlatformStyle.isFluent) ...[
                          // Android (Material 3) only
                          const SizedBox(height: AppSpacing.l),
                          AppButton.danger(
                            label: AppStrings.signOut,
                            icon: AppIcons.signOut,
                            expand: true,
                            onPressed: () => _signOut(context),
                          ),
                        ],
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Groups a section on a card on Windows; on Android sections are plain.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: AppSpacing.s),
        ...children,
      ],
    );
    return PlatformStyle.isFluent
        ? AppCard(padding: const EdgeInsets.all(AppSpacing.l), child: content)
        : content;
  }
}

class _PersonalInfoSection extends StatelessWidget {
  const _PersonalInfoSection();

  @override
  Widget build(BuildContext context) {
    const user = MockData.user;
    final isFluent = PlatformStyle.isFluent;

    final photo = isFluent
        ? Row(
            children: [
              const UserAvatar(size: 64),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppButton.secondary(
                      label: AppStrings.changePhoto,
                      icon: AppIcons.photo,
                      onPressed: () => showPhotoSourcePicker(context),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.dropImageOrBrowse,
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: [
              const UserAvatar(size: 96),
              const SizedBox(height: AppSpacing.s),
              AppButton.text(
                label: AppStrings.changePhoto,
                icon: AppIcons.camera,
                onPressed: () =>
                    showPhotoSourcePicker(context, canRemove: true),
              ),
            ],
          );

    return _Section(
      title: AppStrings.personalInfo,
      children: [
        photo,
        const SizedBox(height: AppSpacing.m),
        AppTextField(
          label: AppStrings.name,
          initialValue: user.name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.m),
        AppTextField(
          label: AppStrings.email,
          initialValue: user.email,
          readOnly: true,
          suffixIcon: AppIcons.lock,
          helperText: AppStrings.emailCantBeChanged,
        ),
        const SizedBox(height: AppSpacing.m),
        AppTextField(
          label: AppStrings.phoneOptional,
          initialValue: user.phone,
          hint: AppStrings.phoneHint,
          helperText: AppStrings.optional,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSpacing.l),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppButton(
            label: AppStrings.saveChanges,
            expand: !isFluent,
            onPressed: () => showNotice(context, AppStrings.profileSaved),
          ),
        ),
      ],
    );
  }
}

class _ChangePasswordSection extends StatelessWidget {
  const _ChangePasswordSection();

  @override
  Widget build(BuildContext context) {
    final isFluent = PlatformStyle.isFluent;
    return _Section(
      title: AppStrings.changePassword,
      children: [
        const PasswordField(label: AppStrings.currentPassword),
        const SizedBox(height: AppSpacing.m),
        const PasswordField(
          label: AppStrings.newPassword,
          helperText: AppStrings.passwordHint,
        ),
        const SizedBox(height: AppSpacing.m),
        const PasswordField(label: AppStrings.confirmNewPassword),
        const SizedBox(height: AppSpacing.l),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppButton(
            label: AppStrings.updatePassword,
            expand: !isFluent,
            onPressed: () => showNotice(context, AppStrings.passwordUpdated),
          ),
        ),
      ],
    );
  }
}
