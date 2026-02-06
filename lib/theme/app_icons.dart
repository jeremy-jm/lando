import 'package:flutter/material.dart';

/// Centralized app icons synced with Figma export (lucide-react at http://localhost:5173/).
/// Lucide icon name → Material Icons mapping. Replace with custom assets if needed.
class AppIcons {
  AppIcons._();

  // ==================== Navigation & AppBar ====================
  /// Lucide: ArrowLeft — AppBar back
  static const IconData back = Icons.arrow_back_ios_new;

  /// Lucide: ArrowLeft (alternative) — e.g. toolbar back
  static const IconData backAlt = Icons.arrow_back;

  /// Lucide: ArrowRightCircle — toolbar forward
  static const IconData forward = Icons.arrow_forward;

  /// Lucide: ChevronRight — list item trailing
  static const IconData chevronRight = Icons.chevron_right;

  /// Lucide: ArrowLeftRight — swap languages
  static const IconData swapHoriz = Icons.swap_horiz;

  // ==================== Bottom Nav ====================
  /// Lucide: Home
  static const IconData home = Icons.home;

  /// Lucide: User
  static const IconData person = Icons.person;

  // ==================== Me / Settings ====================
  /// Lucide: Heart — favorites
  static const IconData favorite = Icons.favorite;
  static const IconData favoriteBorder = Icons.favorite_border;

  /// Lucide: History
  static const IconData history = Icons.history;

  /// Lucide: Settings
  static const IconData settings = Icons.settings;

  // ==================== Query / Dictionary ====================
  /// Lucide: Volume2 — pronunciation
  static const IconData volumeUp = Icons.volume_up;

  /// Lucide: Copy
  static const IconData copy = Icons.content_copy;

  /// Lucide: X — clear input
  static const IconData clear = Icons.clear;

  /// Lucide: Star — favorite word in result
  static const IconData star = Icons.star;
  static const IconData starBorder = Icons.star_border;

  /// Lucide: Search
  static const IconData search = Icons.search;

  // ==================== Actions ====================
  /// Lucide: Trash2 — delete
  static const IconData deleteOutline = Icons.delete_outline;
  static const IconData delete = Icons.delete;

  // ==================== About / Legal ====================
  /// App branding / about
  static const IconData book = Icons.book;

  /// Lucide: Info
  static const IconData infoOutline = Icons.info_outline;

  /// Privacy
  static const IconData privacyTip = Icons.privacy_tip_outlined;

  /// Terms
  static const IconData description = Icons.description_outlined;

  /// Licenses
  static const IconData code = Icons.code_outlined;

  // ==================== Settings / Proxy ====================
  /// Proxy / network
  static const IconData settingsEthernet = Icons.settings_ethernet;
  static const IconData dns = Icons.dns;
  static const IconData numbers = Icons.numbers;

  /// Lucide: Pencil — edit hotkey
  static const IconData edit = Icons.edit;

  // ==================== Status ====================
  /// Error banner
  static const IconData errorOutline = Icons.error_outline;

  /// Success
  static const IconData checkCircle = Icons.check_circle;
  static const IconData checkCircleOutline = Icons.check_circle_outline;

  // ==================== Form / Picker ====================
  /// Language dropdown
  static const IconData arrowDropDown = Icons.arrow_drop_down;

  /// Checkmark (e.g. selected item)
  static const IconData check = Icons.check;
}
