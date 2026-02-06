import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lando/theme/app_design.dart';

void main() {
  group('AppDesign', () {
    test('spacing constants match ui_spec', () {
      expect(AppDesign.spaceXxxs, 2);
      expect(AppDesign.spaceXxs, 4);
      expect(AppDesign.spaceXs, 6);
      expect(AppDesign.spaceS, 8);
      expect(AppDesign.spaceM, 10);
      expect(AppDesign.spaceMd, 12);
      expect(AppDesign.spaceL, 16);
      expect(AppDesign.spaceXl, 24);
      expect(AppDesign.spaceXxl, 32);
      expect(AppDesign.spaceXxxl, 40);
    });

    test('border radius constants match ui_spec', () {
      expect(AppDesign.radiusXs, 4);
      expect(AppDesign.radiusS, 6);
      expect(AppDesign.radiusM, 8);
      expect(AppDesign.radiusL, 12);
      expect(AppDesign.radiusXl, 20);
      expect(AppDesign.radiusLogo, 24);
    });

    test('typography constants match ui_spec', () {
      expect(AppDesign.fontSizeCaption, 12);
      expect(AppDesign.fontSizeBodyS, 13);
      expect(AppDesign.fontSizeBody, 14);
      expect(AppDesign.fontSizeBodyL, 16);
      expect(AppDesign.fontSizeTitleS, 18);
      expect(AppDesign.lineHeightBody, 1.5);
    });

    test('padding constants are valid', () {
      expect(AppDesign.paddingPage, isA<EdgeInsets>());
      expect(AppDesign.paddingPage.left, 16);
      expect(AppDesign.paddingCard, isA<EdgeInsets>());
      expect(AppDesign.paddingCard.left, 16);
      expect(AppDesign.paddingCardL.left, 24);
      expect(AppDesign.paddingCardL.top, 16);
      expect(AppDesign.paddingInput.left, 10);
      expect(AppDesign.paddingInput.top, 7);
      expect(AppDesign.paddingInputL.left, 24);
      expect(AppDesign.paddingInputL.top, 16);
    });

    test('alpha values are in valid range', () {
      expect(AppDesign.alphaSecondary, inInclusiveRange(0.0, 1.0));
      expect(AppDesign.alphaTertiary, inInclusiveRange(0.0, 1.0));
      expect(AppDesign.alphaDisabled, inInclusiveRange(0.0, 1.0));
      expect(AppDesign.alphaDivider, inInclusiveRange(0.0, 1.0));
      expect(AppDesign.alphaEmptyIcon, inInclusiveRange(0.0, 1.0));
    });

    test('input and toolbar constants match ui_spec', () {
      expect(AppDesign.inputCursorHeight, 16);
      expect(AppDesign.inputMinLines, 1);
      expect(AppDesign.inputMaxLines, 6);
      expect(AppDesign.toolbarHeight, 30);
    });

    test('empty state constants match ui_spec', () {
      expect(AppDesign.emptyStateIconSize, 64);
      expect(AppDesign.emptyStateFontSize, 18);
    });

    test('home page constants match ui_spec', () {
      expect(AppDesign.homeLogoSize, 100);
      expect(AppDesign.homeTopSpacing, 40);
      expect(AppDesign.homeInputLanguageSpacing, 16);
    });
  });
}
