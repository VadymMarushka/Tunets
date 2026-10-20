import 'package:fishing_diary/app/tunets_app.dart';
import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke tests: every screen builds without layout overflow in the phone
/// (Material) and desktop (Fluent) variants, and the main navigation works.
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

  group('Android (Material 3)', () {
    testWidgets('sign in leads to home, sections and trip screens', (
      tester,
    ) async {
      await setWindow(tester, const Size(412, 915));
      await tester.pumpWidget(const TunetsApp());

      expect(find.text('Every catch, remembered.'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      // S-4 Home
      expect(find.text('Recent trips'), findsOneWidget);
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

      // S-8 Profile
      await tapText(tester, 'Profile');
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text("Email can't be changed"), findsOneWidget);

      // Let the snackbar timer finish.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('register and reset password screens', (tester) async {
      await setWindow(tester, const Size(412, 915));
      await tester.pumpWidget(const TunetsApp());

      await tapText(tester, 'Register');
      expect(find.text('Create account'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tapText(tester, 'Forgot password?');
      expect(find.text('Reset password'), findsOneWidget);
      await tapText(tester, 'Send reset link');
      expect(find.text('Check your inbox.'), findsOneWidget);
    });
  });

  testWidgets('Android tablet: side navigation rail, dark theme', (
    tester,
  ) async {
    await setWindow(tester, const Size(1280, 800));
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const TunetsApp());
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
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
      await tester.pumpWidget(const TunetsApp());
      expect(find.byType(fl.FluentApp), findsOneWidget);
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

        // Notifications stack up to 3 in the corner and close by themselves.
        for (var i = 0; i < 4; i++) {
          await tester.tap(
            find.widgetWithText(fl.FilledButton, 'Save changes'),
          );
          await tester.pump(const Duration(milliseconds: 300));
        }
        expect(find.byType(fl.InfoBar), findsNWidgets(3));
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        expect(find.byType(fl.InfoBar), findsNothing);
      });
    });

    testWidgets('narrow window and auth screens', (tester) async {
      await runAsWindows(tester, () async {
        await setWindow(tester, const Size(560, 800));
        await tester.pumpWidget(const TunetsApp());

        await tapText(tester, 'Register');
        expect(find.text('Create account'), findsOneWidget);
        await tapText(tester, '← Back to sign in');

        await tapText(tester, 'Forgot password?');
        expect(find.text('Send reset link'), findsOneWidget);
        await tapText(tester, '← Back to sign in');

        await tester.tap(find.widgetWithText(fl.FilledButton, 'Sign in'));
        await tester.pumpAndSettle();
        expect(find.text('Recent trips'), findsOneWidget);
        expect(find.text('Summary'), findsNothing);
      });
    });
  });
}
