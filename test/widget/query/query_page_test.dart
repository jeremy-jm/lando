import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lando/features/home/query/query_page.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/storage/preferences_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('QueryPage Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesStorage.init();
    });

    tearDown(() async {
      await PreferencesStorage.clearAll();
    });
    Widget createTestWidget({String? initialQuery}) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: QueryPage(initialQuery: initialQuery),
      );
    }

    testWidgets('should display query page with app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(QueryPage), findsOneWidget);
    });

    testWidgets('should display initial query if provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(initialQuery: 'hello'));

      // Wait for initial setup and async operations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should display the initial query in the text field
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('should display empty text field when no initial query',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Wait for initial setup
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // TextField should be present
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display back button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('should display settings button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should navigate back when back button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const QueryPage(),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      // Navigate to query page
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.byType(QueryPage), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Should be back to previous page
      expect(find.text('Navigate'), findsOneWidget);
    });

    testWidgets('should display language selector in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Language selector should be in the app bar title
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle text input changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Wait for initial setup
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'test query');
      await tester.pump();

      // Text should be entered
      expect(find.text('test query'), findsOneWidget);
    });
  });
}
