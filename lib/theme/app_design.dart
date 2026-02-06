import 'package:flutter/material.dart';

/// Centralized design tokens aligned with Figma / ui_spec.md.
/// Synced from local Figma export: docs/Lando Dictionary App UI Design (theme.css + Tailwind in components).
class AppDesign {
  AppDesign._();

  // ==================== Spacing (dp/pt) ====================
  /// Synced: Tailwind space scale (1=4, 2=8, 3=12, 4=16, 6=24, 8=32, 10=40)
  static const double spaceXxxs = 2;
  static const double spaceXxs = 4;
  static const double spaceXs = 6;
  static const double spaceS = 8;
  static const double spaceM = 10;
  static const double spaceMd = 12;
  static const double spaceL = 16;
  static const double spaceXl = 24;
  static const double spaceXxl = 32;
  static const double spaceXxxl = 40;

  // ==================== Border Radius ====================
  /// Synced: theme.css --radius 0.625rem=10, radius-sm 6, md 8, lg 10, xl 14; Tailwind rounded-xl=12, rounded-3xl=24
  static const double radiusXs = 4;
  static const double radiusS = 6;
  static const double radiusM = 8;
  static const double radiusL = 12;
  static const double radiusXl = 20;

  /// Logo / large container (Tailwind rounded-3xl)
  static const double radiusLogo = 24;

  // ==================== Typography ====================
  static const double fontSizeCaption = 12;
  static const double fontSizeBodyS = 13;
  static const double fontSizeBody = 14;
  static const double fontSizeBodyL = 16;
  static const double fontSizeTitleS = 18;
  static const double fontSizeTitleM = 20;

  static const double lineHeightBody = 1.5;

  // ==================== Icon Sizes ====================
  static const double iconXs = 16;
  static const double iconS = 18;
  static const double iconM = 20;
  static const double iconL = 24;

  // ==================== Common EdgeInsets ====================
  /// Page horizontal: Tailwind px-4 = 16
  static const EdgeInsets paddingPage = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets paddingPageTop =
      EdgeInsets.only(left: 16, right: 16, top: 16);

  /// Card: Tailwind p-4 = 16; for content-heavy use paddingCardL (px-6 py-4)
  static const EdgeInsets paddingCard = EdgeInsets.all(16);

  /// Card content with px-6 py-4 (Settings/Query cards)
  static const EdgeInsets paddingCardL =
      EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  static const EdgeInsets paddingListTile =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  /// Input: Tailwind px-6 py-4 → horizontal 24, vertical 16; we keep 10,7 for density
  static const EdgeInsets paddingInput = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 7,
  );

  /// Input large (Figma export: px-6 py-4)
  static const EdgeInsets paddingInputL =
      EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  static const EdgeInsets paddingSectionTitle =
      EdgeInsets.fromLTRB(16, 16, 16, 8);
  static const EdgeInsets paddingToolbar = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );

  // ==================== Input / Form ====================
  static const double inputCursorHeight = 16;
  static const int inputMinLines = 1;
  static const int inputMaxLines = 6;

  // ==================== Toolbar ====================
  static const double toolbarHeight = 30;

  // ==================== Divider ====================
  static const double dividerHeight = 0.5;
  static const double dividerSectionHeight = 32;

  // ==================== Empty State ====================
  static const double emptyStateIconSize = 64;
  static const double emptyStateFontSize = 18;

  // ==================== Home Page ====================
  /// Figma export: w-24 h-24 = 96; ui_spec uses 100
  static const double homeLogoSize = 100;

  /// Tailwind mb-10 = 40
  static const double homeTopSpacing = 40;

  /// Tailwind mb-6 = 24, gap-4 = 16
  static const double homeInputLanguageSpacing = 16;

  // ==================== Query Page ====================
  static const double queryInputResultSpacing = 24;

  // ==================== About Page ====================
  static const double aboutLogoSize = 80;
  static const double aboutSectionSpacing = 32;
  static const double aboutCopyrightPadding = 16;

  // ==================== List Item ====================
  static const double listItemMarginH = 8;
  static const double listItemMarginV = 4;

  // ==================== Helper: Alpha values for onSurface ====================
  static const double alphaSecondary = 0.7;
  static const double alphaTertiary = 0.6;
  static const double alphaDisabled = 0.5;
  static const double alphaDivider = 0.1;
  static const double alphaEmptyIcon = 0.3;
}
