// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_services.dart';
import '../../core/platform/platform_style.dart';
import '../../core/services/analytics_service.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/avatar_picker.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/section_header.dart';
import '../../data/repositories/auth_failure.dart';

/// S-8. Profile (FR-2, FR-5): name and photo, password change, sign out.
/// The phone number is a stub until cloud sync (Firestore) is added.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final services = AppServices.of(context);
    services.analytics.logEvent(AnalyticsEvents.signOut);
    // Close pages opened over the shell; AuthGate then shows sign-in.
    context.returnToRoot();
    await services.auth.signOut();
  }

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
          const diagnostics = _DiagnosticsSection();

          return SingleChildScrollView(
            padding: pagePadding(),
            child: ContentConstraint(
              child: twoColumns
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: personal),
                            SizedBox(width: AppSpacing.l),
                            Expanded(child: password),
                          ],
                        ),
                        SizedBox(height: AppSpacing.l),
                        diagnostics,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        personal,
                        const SizedBox(height: AppSpacing.l),
                        password,
                        const SizedBox(height: AppSpacing.l),
                        diagnostics,
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

/// Runs an auth request and shows its result: [success] on success,
/// the [AuthFailure] message otherwise. Returns `true` on success.
Future<bool> _runRequest(
  BuildContext context,
  Future<void> Function() request, {
  required String success,
  required String reason,
}) async {
  final services = AppServices.of(context);
  try {
    await request();
    if (context.mounted) showNotice(context, success);
    return true;
  } on AuthFailure catch (e) {
    if (context.mounted) {
      showNotice(context, e.message, kind: NoticeKind.error);
    }
  } catch (e, stack) {
    services.crashes.recordError(e, stack, reason: reason);
    if (context.mounted) {
      showNotice(context, AppStrings.unexpectedError, kind: NoticeKind.error);
    }
  }
  return false;
}

class _PersonalInfoSection extends StatefulWidget {
  const _PersonalInfoSection();

  @override
  State<_PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<_PersonalInfoSection> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: CurrentUser.of(context).name);
  bool _saving = false;
  bool _changingPhoto = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (_name.text.trim() == CurrentUser.of(context).name) {
      showNotice(context, AppStrings.nameUnchanged, kind: NoticeKind.info);
      return;
    }
    final services = AppServices.of(context);
    setState(() => _saving = true);
    final saved = await _runRequest(
      context,
      () => services.auth.updateProfile(displayName: _name.text),
      success: AppStrings.profileSaved,
      reason: 'update_profile',
    );
    if (saved) services.analytics.logEvent(AnalyticsEvents.profileUpdated);
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _changePhoto() async {
    final services = AppServices.of(context);
    final choice = await showAvatarPicker(
      context,
      currentUrl: CurrentUser.of(context).photoUrl,
    );
    if (choice == null || !mounted) return;
    setState(() => _changingPhoto = true);
    final url = choice.url;
    final saved = await _runRequest(
      context,
      () => url == null
          ? services.auth.updateProfile(clearPhoto: true)
          : services.auth.updateProfile(photoUrl: url),
      success: url == null ? AppStrings.photoRemoved : AppStrings.photoUpdated,
      reason: 'update_photo',
    );
    if (saved) services.analytics.logEvent(AnalyticsEvents.profilePhotoChanged);
    if (mounted) setState(() => _changingPhoto = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = CurrentUser.of(context);
    final isFluent = PlatformStyle.isFluent;

    final photo = isFluent
        ? Row(
            children: [
              UserAvatar(size: 64, photoUrl: user.photoUrl),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppButton.secondary(
                      label: AppStrings.changePhoto,
                      icon: AppIcons.photo,
                      loading: _changingPhoto,
                      onPressed: _changePhoto,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.photoHint,
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: [
              UserAvatar(size: 96, photoUrl: user.photoUrl),
              const SizedBox(height: AppSpacing.s),
              AppButton.text(
                label: AppStrings.changePhoto,
                icon: AppIcons.camera,
                loading: _changingPhoto,
                onPressed: _changePhoto,
              ),
            ],
          );

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: _Section(
        title: AppStrings.personalInfo,
        children: [
          photo,
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: AppStrings.name,
            controller: _name,
            enabled: !_saving,
            textInputAction: TextInputAction.done,
            validator: Validators.name,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            // Keyed by email so the field updates if the account changes.
            key: ValueKey(user.email),
            label: AppStrings.email,
            initialValue: user.email,
            readOnly: true,
            suffixIcon: AppIcons.lock,
            helperText: AppStrings.emailCantBeChanged,
          ),
          const SizedBox(height: AppSpacing.m),
          const AppTextField(
            // Stub: needs Firestore (or SMS verification) to be stored.
            label: AppStrings.phoneOptional,
            hint: AppStrings.phoneHint,
            helperText: AppStrings.phoneNotSaved,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton(
              label: AppStrings.saveChanges,
              expand: !isFluent,
              loading: _saving,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordSection extends StatefulWidget {
  const _ChangePasswordSection();

  @override
  State<_ChangePasswordSection> createState() => _ChangePasswordSectionState();
}

class _ChangePasswordSectionState extends State<_ChangePasswordSection> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateNew(String? value) {
    final error = Validators.newPassword(value);
    if (error != null) return error;
    if (value == _current.text) return AppStrings.newPasswordSameAsCurrent;
    return null;
  }

  Future<void> _update() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final services = AppServices.of(context);
    setState(() => _saving = true);
    final changed = await _runRequest(
      context,
      () => services.auth.changePassword(
        currentPassword: _current.text,
        newPassword: _new.text,
      ),
      success: AppStrings.passwordUpdated,
      reason: 'change_password',
    );
    if (changed) {
      services.analytics.logEvent(AnalyticsEvents.passwordChanged);
      _current.clear();
      _new.clear();
      _confirm.clear();
      _formKey.currentState?.reset();
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isFluent = PlatformStyle.isFluent;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: _Section(
        title: AppStrings.changePassword,
        children: [
          PasswordField(
            label: AppStrings.currentPassword,
            controller: _current,
            enabled: !_saving,
            autofillHints: const [AutofillHints.password],
            validator: Validators.passwordEntered,
          ),
          const SizedBox(height: AppSpacing.m),
          PasswordField(
            label: AppStrings.newPassword,
            controller: _new,
            enabled: !_saving,
            helperText: AppStrings.passwordHint,
            autofillHints: const [AutofillHints.newPassword],
            validator: _validateNew,
          ),
          const SizedBox(height: AppSpacing.m),
          PasswordField(
            label: AppStrings.confirmNewPassword,
            controller: _confirm,
            enabled: !_saving,
            validator: Validators.confirmPassword(() => _new.text),
            onSubmitted: (_) => _update(),
          ),
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton(
              label: AppStrings.updatePassword,
              expand: !isFluent,
              loading: _saving,
              onPressed: _update,
            ),
          ),
        ],
      ),
    );
  }
}

/// Test reports for the crash reporting service (LR4, task 2):
/// Crashlytics on Android, Sentry on Windows.
class _DiagnosticsSection extends StatelessWidget {
  const _DiagnosticsSection();

  Future<void> _sendTestError(BuildContext context) async {
    final crashes = AppServices.of(context).crashes;
    await crashes.log('Test error requested from the Profile screen');
    try {
      throw StateError('Test non-fatal error from the Profile screen');
    } catch (e, stack) {
      await crashes.recordError(e, stack, reason: 'manual test', fatal: false);
    }
    if (context.mounted) showNotice(context, AppStrings.testErrorSent);
  }

  Future<void> _testCrash(BuildContext context) async {
    final crashes = AppServices.of(context).crashes;
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.testCrashTitle,
      message: AppStrings.testCrashMessage,
      confirmLabel: AppStrings.testCrash,
    );
    if (confirmed) crashes.testCrash();
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: AppStrings.diagnostics,
      children: [
        Text(
          AppStrings.diagnosticsHint,
          style: AppTextStyles.secondary(context),
        ),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            AppButton.secondary(
              label: AppStrings.sendTestError,
              onPressed: () => _sendTestError(context),
            ),
            AppButton.danger(
              label: AppStrings.testCrash,
              onPressed: () => _testCrash(context),
            ),
          ],
        ),
      ],
    );
  }
}
