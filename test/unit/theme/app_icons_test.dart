import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lando/theme/app_icons.dart';

void main() {
  group('AppIcons', () {
    test('navigation and app bar icons are defined', () {
      expect(AppIcons.back, isA<IconData>());
      expect(AppIcons.backAlt, isA<IconData>());
      expect(AppIcons.forward, isA<IconData>());
      expect(AppIcons.chevronRight, isA<IconData>());
      expect(AppIcons.swapHoriz, isA<IconData>());
    });

    test('bottom nav icons are defined', () {
      expect(AppIcons.home, isA<IconData>());
      expect(AppIcons.person, isA<IconData>());
    });

    test('me and settings icons are defined', () {
      expect(AppIcons.favorite, isA<IconData>());
      expect(AppIcons.favoriteBorder, isA<IconData>());
      expect(AppIcons.history, isA<IconData>());
      expect(AppIcons.settings, isA<IconData>());
    });

    test('query and dictionary icons are defined', () {
      expect(AppIcons.volumeUp, isA<IconData>());
      expect(AppIcons.copy, isA<IconData>());
      expect(AppIcons.clear, isA<IconData>());
      expect(AppIcons.star, isA<IconData>());
      expect(AppIcons.starBorder, isA<IconData>());
      expect(AppIcons.search, isA<IconData>());
    });

    test('action and status icons are defined', () {
      expect(AppIcons.deleteOutline, isA<IconData>());
      expect(AppIcons.delete, isA<IconData>());
      expect(AppIcons.errorOutline, isA<IconData>());
      expect(AppIcons.checkCircle, isA<IconData>());
      expect(AppIcons.checkCircleOutline, isA<IconData>());
    });
  });
}
