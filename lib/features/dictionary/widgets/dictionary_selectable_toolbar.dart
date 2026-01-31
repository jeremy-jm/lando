import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';

/// Builds context menu for SelectableText: Copy and Select All (localized).
Widget buildDictionarySelectableToolbar(
  BuildContext context,
  EditableTextState editableTextState,
  AppLocalizations? l10n,
) {
  final copyLabel = l10n?.copy ?? 'Copy';
  final selectAllLabel = l10n?.selectAll ?? 'Select All';
  final items = editableTextState.contextMenuButtonItems
      .where((item) =>
          item.type == ContextMenuButtonType.copy ||
          item.type == ContextMenuButtonType.selectAll)
      .map((item) {
    if (item.type == ContextMenuButtonType.copy) {
      return item.copyWith(label: copyLabel);
    }
    if (item.type == ContextMenuButtonType.selectAll) {
      return item.copyWith(label: selectAllLabel);
    }
    return item;
  }).toList();
  if (items.isEmpty) {
    return const SizedBox.shrink();
  }
  return AdaptiveTextSelectionToolbar.buttonItems(
    anchors: editableTextState.contextMenuAnchors,
    buttonItems: items,
  );
}
