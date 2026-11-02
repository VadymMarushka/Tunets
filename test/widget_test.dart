import 'package:fishing_diary/data/models/user_profile.dart';
import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Widget tests with a fake auth repository: every screen builds without
/// layout overflow in the phone (Material) and desktop (Fluent) variants,
/// forms validate input, and auth results switch screens.
void main() {
  Future<void> setWindow(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).first);
    await tester.pumpAndSettle();
  }

  /// Types into the [index]-th text input on screen (works for Material
  /// TextField and Fluent TextBox / PasswordBox alike).
  Future<void> enter(WidgetTester tester, int index, String text) async {
    await tester.enterText(find.byType(EditableText).at(index), text);
    await tester.pump();
  }

  /// Lets snackbars / info bars time out so no timers are left pending.
  Future<void> flushNotices(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  }

  group('Android (Material 3)', () {
    Finder signInButton() => find.widgetWithText(FilledButton, 'Sign in');

    Future<void> signIn(WidgetTester tester) async {
      await enter(tester, 0, 'vadym@example.com');
      await enter(tester, 1, FakeAuthRepository.password);
      await tester.tap(signInButton());
      await tester.pumpAndSettle();
    }

    testWidgets('sign-in validation, wrong password, then the app', (
      tester,
    ) async {
      await setWindow(tester, const Size(412, 915));
      await tester.pumpWidget(testApp());
      await tester.pumpAndSettle();
      expect(find.text('Every catch, remembered.'), findsOneWidget);

      // Empty form: local validation, no request.
      await tester.tap(signInButton());
      await tester.pumpAndSettle();
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter a password'), findsOneWidget);

      // Invalid email format.
      await enter(tester, 0, 'vadym@');
      expect(
        find.text('Enter a valid email, e.g. name@example.com'),
        findsOneWidget,
      );

      // Valid form, wrong password: message from the repository.
      await enter(tester, 0, 'vadym@example.com');
      await enter(tester, 1, FakeAuthRepository.wrongPassword);
      await tester.tap(signInButton());
      await tester.pumpAndSettle();
      expect(
        find.text("Couldn't sign in. Check your email and password."),
        findsOneWidget,
      );
      await flushNotices(tester);

      await signIn(tester);

      // S-4 Home with the signed-in user's name
      expect(find.text('Recent trips'), findsOneWidget);
      expect(find.textContaining('Vadym'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      // S-7 Trip details from a home card
      await tapText(tester, 'Lake Svitiaz');
      expect(find.text('Trip details'), findsOneWidget);
      expect(find.text('Catch · 6 fish'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // S-5 Trips
      await tapText(tester, 'Trips');
      expect(find.text('Search by water body'), findsOneWidget);
      await tapText(tester, 'This month');
      expect(find.text('Shatsk Pond'), findsNothing);

      // S-6 Trip form: saving without a water body shows the error
      await tester.tap(find.byType(FloatingActionButton).last);
      await tester.pumpAndSettle();
      expect(find.text('Add trip'), findsWidgets);
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('Water body is required'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      // S-8 Profile shows the account's email
      await tapText(tester, 'Profile');
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text('vadym@example.com'), findsOneWidget);
      await flushNotices(tester);
    });

    testWidgets('register validates fields and opens home', (tester) async {
      await setWindow(tester, const Size(412, 915));
      await tester.pumpWidget(testApp());
      await tester.pumpAndSettle();

      await tapText(tester, 'Register');
      expect(find.text('Create account'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Register'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your name'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Repeat the password'), findsOneWidget);

      await enter(tester, 0, 'Olena');
      await enter(tester, 1, 'olena@example.com');
      await enter(tester, 2, 'short');
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
      await enter(tester, 2, 'fishing2026');
      await enter(tester, 3, 'fishing2027');
      expect(find.text("Passwords don't match"), findsOneWidget);
      await enter(tester, 3, 'fishing2026');

      await tester.tap(find.widgetWithText(FilledButton, 'Register'));
      await tester.pumpAndSettle();
      expect(find.text('Recent trips'), findsOneWidget);
      expect(find.textContaining('Olena'), findsOneWidget);
    });

    testWidgets('reset password, change password and sign out', (tester) async {
      await setWindow(tester, const Size(412, 915));
      await tester.pumpWidget(testApp());
      await tester.pumpAndSettle();

      await enter(tester, 0, 'vadym@example.com');
      await tapText(tester, 'Forgot password?');
      expect(find.text('Reset password'), findsOneWidget);
      // The email typed on the sign-in screen is carried over.
      await tapText(tester, 'Send reset link');
      expect(find.text('Check your inbox.'), findsOneWidget);
      await tapText(tester, 'Back to sign in');

      await signIn(tester);
      await tapText(tester, 'Profile');

      // Change password with a wrong current password.
      final fields = find.byType(EditableText);
      final current = fields.evaluate().length - 3;
      await enter(tester, current, 'not-my-password');
      await enter(tester, current + 1, 'brand-new-pass');
      await enter(tester, current + 2, 'brand-new-pass');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Update password'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Update password'));
      await tester.pumpAndSettle();
      expect(find.text('The current password is incorrect.'), findsOneWidget);
      await flushNotices(tester);

      // Sign out returns to the sign-in screen.
      await tester.tap(find.byTooltip('Sign out').first);
      await tester.pumpAndSettle();
      expect(find.text('Every catch, remembered.'), findsOneWidget);
    });

    testWidgets('session restore: signed-in user goes straight home', (
      tester,
    ) async {
      await setWindow(tester, const Size(412, 915));
      await tester.pumpWidget(
        testApp(auth: FakeAuthRepository(signedIn: _vadym)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Recent trips'), findsOneWidget);
    });
  });

  testWidgets('Android tablet: side navigation rail, dark theme', (
    tester,
  ) async {
    await setWindow(tester, const Size(1280, 800));
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      testApp(auth: FakeAuthRepository(signedIn: _vadym)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    await tapText(tester, 'Trips');
    expect(find.text('Open'), findsOneWidget);
  });

  group('Windows (Fluent)', () {
    Future<void> runAsWindows(
      WidgetTester tester,
      Future<void> Function() body,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await body();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    }

    Future<void> signIn(WidgetTester tester) async {
      await tester.pumpWidget(testApp());
      await tester.pumpAndSettle();
      expect(find.byType(fl.FluentApp), findsOneWidget);
      await enter(tester, 0, 'vadym@example.com');
      await enter(tester, 1, FakeAuthRepository.password);
      await tester.tap(find.widgetWithText(fl.FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
    }

    testWidgets('wide window: pane navigation and master–detail', (
      tester,
    ) async {
      await runAsWindows(tester, () async {
        await setWindow(tester, const Size(1366, 768));
        await signIn(tester);

        // S-4 Home with the summary column
        expect(find.byType(fl.NavigationView), findsOneWidget);
        expect(find.text('Summary'), findsOneWidget);

        // S-5 + S-7 master–detail
        await tapText(tester, 'Trips');
        expect(find.text('4 trips'), findsOneWidget);
        expect(find.text('Open'), findsOneWidget);
        await tapText(tester, 'Dnister River');
        expect(find.text('Catch · 10 fish'), findsOneWidget);

        // S-6 form
        await tapText(tester, 'Add trip');
        expect(find.text('Drag a photo here'), findsOneWidget);
        await tester.tap(find.widgetWithText(fl.Button, 'Cancel'));
        await tester.pumpAndSettle();

        // S-8 Profile
        await tapText(tester, 'Profile');
        expect(find.text('Update password'), findsOneWidget);

        // Notifications stack up to 3 in the corner and close by themselves
        // (the name is unchanged, so each tap shows an info notice).
        for (var i = 0; i < 4; i++) {
          await tester.tap(
            find.widgetWithText(fl.FilledButton, 'Save changes'),
          );
          await tester.pump(const Duration(milliseconds: 300));
        }
        expect(find.byType(fl.InfoBar), findsNWidgets(3));
        await flushNotices(tester);
        expect(find.byType(fl.InfoBar), findsNothing);
      });
    });

    testWidgets('narrow window and auth screens', (tester) async {
      await runAsWindows(tester, () async {
        await setWindow(tester, const Size(560, 800));
        await tester.pumpWidget(testApp());
        await tester.pumpAndSettle();

        await tapText(tester, 'Register');
        expect(find.text('Create account'), findsOneWidget);
        await tapText(tester, '← Back to sign in');

        await tapText(tester, 'Forgot password?');
        expect(find.text('Send reset link'), findsOneWidget);
        await tapText(tester, '← Back to sign in');

        // Validation messages are shown under Fluent fields too.
        await tester.tap(find.widgetWithText(fl.FilledButton, 'Sign in'));
        await tester.pumpAndSettle();
        expect(find.text('Enter your email'), findsOneWidget);

        await enter(tester, 0, 'vadym@example.com');
        await enter(tester, 1, FakeAuthRepository.password);
        await tester.tap(find.widgetWithText(fl.FilledButton, 'Sign in'));
        await tester.pumpAndSettle();
        expect(find.text('Recent trips'), findsOneWidget);
        expect(find.text('Summary'), findsNothing);
      });
    });
  });
}

const _vadym = UserProfile(
  uid: 'u1',
  name: 'Vadym',
  email: 'vadym@example.com',
);
