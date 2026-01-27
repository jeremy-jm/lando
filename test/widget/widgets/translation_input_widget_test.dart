import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lando/features/home/widgets/translation_input_widget.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/storage/preferences_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('TranslationInputWidget Widget Tests', () {
    late TextEditingController controller;
    late FocusNode focusNode;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesStorage.init();
      controller = TextEditingController();
      focusNode = FocusNode();
    });

    tearDown(() async {
      controller.dispose();
      focusNode.dispose();
      await PreferencesStorage.clearAll();
    });

    Widget createTestWidget({
      String? hintText,
      ValueChanged<String>? onSubmitted,
      VoidCallback? onTap,
      String? detectedLanguage,
      bool readOnly = false,
      String? pronunciationUrl,
      VoidCallback? onPronunciationTap,
      ValueChanged<String>? onSuggestionTap,
      bool enableSuggestions = true,
      VoidCallback? onNavigateBack,
      VoidCallback? onNavigateForward,
      bool canNavigateBack = false,
      bool canNavigateForward = false,
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
          body: TranslationInputWidget(
            controller: controller,
            focusNode: focusNode,
            hintText: hintText,
            onSubmitted: onSubmitted,
            onTap: onTap,
            detectedLanguage: detectedLanguage,
            readOnly: readOnly,
            pronunciationUrl: pronunciationUrl,
            onPronunciationTap: onPronunciationTap,
            onSuggestionTap: onSuggestionTap,
            enableSuggestions: enableSuggestions,
            onNavigateBack: onNavigateBack,
            onNavigateForward: onNavigateForward,
            canNavigateBack: canNavigateBack,
            canNavigateForward: canNavigateForward,
          ),
        ),
      );
    }

    testWidgets('should display text field with controller text',
        (WidgetTester tester) async {
      controller.text = 'hello';
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('should display hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(hintText: 'Enter text to translate'),
      );

      expect(find.text('Enter text to translate'), findsOneWidget);
    });

    testWidgets('should call onSubmitted when text is submitted',
        (WidgetTester tester) async {
      String? submittedText;
      await tester.pumpWidget(
        createTestWidget(
          onSubmitted: (text) {
            submittedText = text;
          },
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'hello');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(submittedText, 'hello');
    });

    testWidgets('should display detected language when provided',
        (WidgetTester tester) async {
      controller.text = 'hello';
      await tester.pumpWidget(
        createTestWidget(detectedLanguage: '英语'),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('英语'), findsOneWidget);
    });

    testWidgets('should not display detected language when text is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(detectedLanguage: '英语'),
      );

      await tester.pumpAndSettle();

      // Detected language should not be shown when text is empty
      expect(find.textContaining('英语'), findsNothing);
    });

    testWidgets('should display pronunciation button when language detected',
        (WidgetTester tester) async {
      controller.text = 'hello';
      bool pronunciationTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          detectedLanguage: '英语',
          onPronunciationTap: () {
            pronunciationTapped = true;
          },
        ),
      );

      await tester.pumpAndSettle();

      final volumeIcon = find.byIcon(Icons.volume_up);
      expect(volumeIcon, findsOneWidget);

      await tester.tap(volumeIcon);
      await tester.pumpAndSettle();

      expect(pronunciationTapped, true);
    });

    testWidgets('should display copy button when text is present',
        (WidgetTester tester) async {
      controller.text = 'hello';
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      // Copy button is only shown when detectedLanguage is present
      // So we need to provide detectedLanguage
      await tester.pumpWidget(
        createTestWidget(detectedLanguage: '英语'),
      );
      controller.text = 'hello';
      await tester.pumpAndSettle();

      final copyIcon = find.byIcon(Icons.content_copy);
      expect(copyIcon, findsOneWidget);
    });

    testWidgets('should copy text to clipboard when copy button is tapped',
        (WidgetTester tester) async {
      controller.text = 'hello';
      await tester.pumpWidget(
        createTestWidget(detectedLanguage: '英语'),
      );

      await tester.pumpAndSettle();

      final copyIcon = find.byIcon(Icons.content_copy);
      await tester.tap(copyIcon);
      await tester.pumpAndSettle();

      // Verify clipboard contains the text
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      expect(clipboardData?.text, 'hello');
    });

    testWidgets('should display clear button when text is present',
        (WidgetTester tester) async {
      controller.text = 'hello';
      await tester.pumpWidget(
        createTestWidget(detectedLanguage: '英语'),
      );

      await tester.pumpAndSettle();

      final clearIcon = find.byIcon(Icons.clear);
      expect(clearIcon, findsOneWidget);
    });

    testWidgets('should clear text when clear button is tapped',
        (WidgetTester tester) async {
      controller.text = 'hello';
      await tester.pumpWidget(
        createTestWidget(detectedLanguage: '英语'),
      );

      await tester.pumpAndSettle();

      final clearIcon = find.byIcon(Icons.clear);
      await tester.tap(clearIcon);
      await tester.pumpAndSettle();

      expect(controller.text, '');
    });

    testWidgets('should display navigation buttons when callbacks provided',
        (WidgetTester tester) async {
      controller.text = 'hello';
      await tester.pumpWidget(
        createTestWidget(
          detectedLanguage: '英语',
          onNavigateBack: () {},
          onNavigateForward: () {},
          canNavigateBack: true,
          canNavigateForward: true,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('should call onNavigateBack when back button is tapped',
        (WidgetTester tester) async {
      controller.text = 'hello';
      bool backTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          detectedLanguage: '英语',
          onNavigateBack: () {
            backTapped = true;
          },
          canNavigateBack: true,
        ),
      );

      await tester.pumpAndSettle();

      final backIcon = find.byIcon(Icons.arrow_back);
      await tester.tap(backIcon);
      await tester.pumpAndSettle();

      expect(backTapped, true);
    });

    testWidgets('should call onNavigateForward when forward button is tapped',
        (WidgetTester tester) async {
      controller.text = 'hello';
      bool forwardTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          detectedLanguage: '英语',
          onNavigateForward: () {
            forwardTapped = true;
          },
          canNavigateForward: true,
        ),
      );

      await tester.pumpAndSettle();

      final forwardIcon = find.byIcon(Icons.arrow_forward);
      await tester.tap(forwardIcon);
      await tester.pumpAndSettle();

      expect(forwardTapped, true);
    });

    testWidgets('should disable navigation buttons when cannot navigate',
        (WidgetTester tester) async {
      controller.text = 'hello';
      await tester.pumpWidget(
        createTestWidget(
          detectedLanguage: '英语',
          onNavigateBack: () {},
          onNavigateForward: () {},
          canNavigateBack: false,
          canNavigateForward: false,
        ),
      );

      await tester.pumpAndSettle();

      // Buttons should still be visible but disabled
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('should be read-only when readOnly is true',
        (WidgetTester tester) async {
      controller.text = 'hello';
      await tester.pumpWidget(createTestWidget(readOnly: true));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, true);
    });

    testWidgets('should handle text input changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'test');

      expect(controller.text, 'test');
    });
  });
}
