// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_routes.dart';
import '../../app/bloc/auth_bloc.dart';
import '../../app/bloc/theme_bloc.dart';
import '../../core/platform/platform_style.dart';
import '../../core/services/crash_reporter.dart';
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
import '../../core/widgets/filter_bar.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/progress.dart';
import '../../core/widgets/section_header.dart';
import 'bloc/profile_bloc.dart';

/// S-8. Profile (FR-2, FR-5): name and photo, password change, theme,
/// sign out. The phone number is a stub until cloud sync (Firestore).
///
/// Loading and saving the profile go through [ProfileBloc]; the theme
/// through the app-wide [ThemeBloc] (saved on the device).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        auth: context.read(),
        analytics: context.read(),
        crashes: context.read(),
      )..add(const ProfileStarted()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _signOut(BuildContext context) {
    final auth = context.read<AuthBloc>();
    // Close pages opened over the shell; AuthGate then shows sign-in.
    context.returnToRoot();
    auth.add(const AuthSignOutRequested());
  }

  /// Shows the outcome of every profile request once, as a notice.
  void _showResult(BuildContext context, ProfileState state) {
    final result = state.result!;
    showNotice(context, result.message, kind: result.kind);
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((ProfileBloc bloc) => bloc.state.isLoading);

    return AppPage(
      title: AppStrings.navProfile,
      actions: [
        PageAction(
          label: AppStrings.signOut,
          icon: AppIcons.signOut,
          // Android has the Sign out button at the bottom (mockup).
          showOnMaterial: false,
          onPressed: () => _signOut(context),
        ),
      ],
      body: BlocListener<ProfileBloc, ProfileState>(
        // Only the state that ends a request carries a result (the next
        // request clears it), so each result is shown exactly once. Not
        // `result != previous.result`: a repeated "nothing to save" is the
        // same const object.
        listenWhen: (previous, current) => current.result != null,
        listener: _showResult,
        child: loading
            ? const Center(child: AppProgressIndicator())
            : _buildSections(context),
      ),
    );
  }

  Widget _buildSections(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= Breakpoints.twoColumns;
        const personal = _PersonalInfoSection();
        const password = _ChangePasswordSection();
        const appearance = _AppearanceSection();
        const diagnostics = _DiagnosticsSection();
        // Android: sections are split by dividers (mockup); Windows: cards
        // with a gap.
        final gap = PlatformStyle.isFluent
            ? const SizedBox(height: AppSpacing.l)
            : const AppDivider(spacing: AppSpacing.l);

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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                password,
                                SizedBox(height: AppSpacing.l),
                                appearance,
                              ],
                            ),
                          ),
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
                      gap,
                      password,
                      gap,
                      appearance,
                      gap,
                      diagnostics,
                      if (!PlatformStyle.isFluent) ...[
                        // Android (Material 3) only
                        gap,
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

class _PersonalInfoSection extends StatefulWidget {
  const _PersonalInfoSection();

  @override
  State<_PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<_PersonalInfoSection> {
  final _formKey = GlobalKey<FormState>();

  /// Built after the profile is loaded (the screen shows a spinner first).
  late final _name = TextEditingController(
    text: context.read<ProfileBloc>().state.user!.name,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(ProfileNameSaved(_name.text));
  }

  Future<void> _changePhoto() async {
    final bloc = context.read<ProfileBloc>();
    final choice = await showProfilePhotoPicker(
      context,
      hasPhoto: bloc.state.user?.photoUrl != null,
    );
    // Uploading own photos comes with cloud storage; removing works now.
    if (choice == ProfilePhotoAction.remove) {
      bloc.add(const ProfilePhotoChanged(null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileBloc>().state;
    final user = state.user!;
    final saving = state.action == ProfileAction.savingName;
    final changingPhoto = state.action == ProfileAction.changingPhoto;
    final isFluent = PlatformStyle.isFluent;

    final photo = isFluent
        ? Row(
            children: [
              UserAvatar(size: 80, photoUrl: user.photoUrl),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppButton.secondary(
                      label: AppStrings.changePhoto,
                      icon: AppIcons.photo,
                      loading: changingPhoto,
                      onPressed: _changePhoto,
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
              UserAvatar(size: 96, photoUrl: user.photoUrl),
              const SizedBox(height: AppSpacing.s),
              AppButton.text(
                label: AppStrings.changePhoto,
                icon: AppIcons.camera,
                loading: changingPhoto,
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
            hint: AppStrings.nameHint,
            controller: _name,
            enabled: !saving,
            textInputAction: TextInputAction.done,
            validator: Validators.name,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            // Keyed by email so the field updates if the account changes.
            key: ValueKey(user.email),
            label: AppStrings.email,
            hint: AppStrings.emailHint,
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
              loading: saving,
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

  void _update() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
      ProfilePasswordChangeRequested(
        currentPassword: _current.text,
        newPassword: _new.text,
      ),
    );
  }

  /// After a successful change the fields are cleared.
  void _clear() {
    _current.clear();
    _new.clear();
    _confirm.clear();
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isFluent = PlatformStyle.isFluent;
    final saving = context.select(
      (ProfileBloc bloc) => bloc.state.action == ProfileAction.changingPassword,
    );

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) {
        final result = current.result;
        return result != null &&
            result.action == ProfileAction.changingPassword &&
            result.isSuccess;
      },
      listener: (context, state) => _clear(),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,
        child: _Section(
          title: AppStrings.changePassword,
          children: [
            PasswordField(
              label: AppStrings.currentPassword,
              hint: AppStrings.currentPasswordHint,
              controller: _current,
              enabled: !saving,
              autofillHints: const [AutofillHints.password],
              validator: Validators.passwordEntered,
            ),
            const SizedBox(height: AppSpacing.m),
            PasswordField(
              label: AppStrings.newPassword,
              hint: AppStrings.passwordNewHint,
              controller: _new,
              enabled: !saving,
              helperText: AppStrings.passwordHint,
              autofillHints: const [AutofillHints.newPassword],
              validator: _validateNew,
            ),
            const SizedBox(height: AppSpacing.m),
            PasswordField(
              label: AppStrings.confirmNewPassword,
              hint: AppStrings.passwordRepeatHint,
              controller: _confirm,
              enabled: !saving,
              validator: Validators.confirmPassword(() => _new.text),
              onSubmitted: (_) => _update(),
            ),
            const SizedBox(height: AppSpacing.l),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppButton(
                label: AppStrings.updatePassword,
                // Mockup: tonal on Android, accent on Windows.
                variant: isFluent
                    ? AppButtonVariant.primary
                    : AppButtonVariant.tonal,
                expand: !isFluent,
                loading: saving,
                onPressed: _update,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Theme: System / Light / Dark. The choice goes to [ThemeBloc], which
/// saves it on the device (SharedPreferences), so it survives restarts.
class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  static const _modes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

  @override
  Widget build(BuildContext context) {
    final mode = context.select((ThemeBloc bloc) => bloc.state.mode);
    return _Section(
      title: AppStrings.appearance,
      children: [
        Text(
          AppStrings.appearanceHint,
          style: AppTextStyles.secondary(context),
        ),
        const SizedBox(height: AppSpacing.m),
        FilterBar(
          labels: const [
            AppStrings.themeSystem,
            AppStrings.themeLight,
            AppStrings.themeDark,
          ],
          selectedIndex: _modes.indexOf(mode),
          onSelected: (index) =>
              context.read<ThemeBloc>().add(ThemeModeChanged(_modes[index])),
        ),
      ],
    );
  }
}

/// Test reports for the crash reporting service (LR4, task 2):
/// Crashlytics on Android, Sentry on Windows.
class _DiagnosticsSection extends StatelessWidget {
  const _DiagnosticsSection();

  Future<void> _sendTestError(BuildContext context) async {
    final crashes = context.read<CrashReporter>();
    await crashes.log('Test error requested from the Profile screen');
    try {
      throw StateError('Test non-fatal error from the Profile screen');
    } catch (e, stack) {
      await crashes.recordError(e, stack, reason: 'manual test', fatal: false);
    }
    if (context.mounted) showNotice(context, AppStrings.testErrorSent);
  }

  Future<void> _testCrash(BuildContext context) async {
    final crashes = context.read<CrashReporter>();
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
