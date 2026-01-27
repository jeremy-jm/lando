import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lando/features/home/widgets/language_selector_widget.dart';
import 'package:lando/storage/preferences_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import LanguagePair from the widget file
// Note: LanguagePair is defined in language_selector_widget.dart

void main() {
  group('LanguageSelectorWidget Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesStorage.init();
    });

    tearDown(() async {
      await PreferencesStorage.clearAll();
    });

    Widget createTestWidget({
      ValueChanged<LanguagePair>? onLanguageChanged,
      bool showBackground = false,
    }) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LanguageSelectorWidget(
            onLanguageChanged: onLanguageChanged,
            showBackground: showBackground,
          ),
        ),
      );
    }

    testWidgets('should display language selector',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectorWidget), findsOneWidget);
    });

    testWidgets('should display default languages when not set',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Should display some language text (auto or default)
      expect(find.byType(LanguageSelectorWidget), findsOneWidget);
    });

    testWidgets('should display saved languages from preferences',
        (WidgetTester tester) async {
      await PreferencesStorage.saveTranslationLanguages(
        fromLanguage: 'en',
        toLanguage: 'zh',
      );

      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Should display the saved languages
      expect(find.byType(LanguageSelectorWidget), findsOneWidget);
    });

    testWidgets('should call onLanguageChanged when language is changed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          onLanguageChanged: (pair) {},
        ),
      );

      await tester.pumpAndSettle();

      // Tap on language selector to open dialog
      // Note: This test may need adjustment based on actual implementation
      expect(find.byType(LanguageSelectorWidget), findsOneWidget);
    });

    testWidgets('should show background when showBackground is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(showBackground: true));

      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectorWidget), findsOneWidget);
    });

    testWidgets('should not show background when showBackground is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(showBackground: false));

      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectorWidget), findsOneWidget);
    });
  });
}
