import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/models/query_history_item.dart';

/// A reusable tile widget for displaying query history or favorite items.
///
/// This widget is decoupled from data sources and can be used in both
/// history and favorites pages.
class QueryHistoryItemTile extends StatelessWidget {
  const QueryHistoryItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.confirmDismiss,
    this.formatTimestamp,
  });

  /// The query history item to display.
  final QueryHistoryItem item;

  /// Callback when the tile is tapped.
  final ValueChanged<String> onTap;

  /// Callback when delete button is pressed.
  final ValueChanged<QueryHistoryItem> onDelete;

  /// Optional callback for swipe-to-delete gesture confirmation.
  /// Returns true if deletion should proceed, false otherwise.
  final Future<bool> Function(QueryHistoryItem)? confirmDismiss;

  /// Optional timestamp formatter. If not provided, uses default formatting.
  final String Function(int timestamp)? formatTimestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    Widget tile = Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDesign.listItemMarginH,
        vertical: AppDesign.listItemMarginV,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusL),
      ),
      child: ListTile(
        contentPadding: AppDesign.paddingListTile,
        title: Text(
          item.word,
          style: TextStyle(
            fontSize: AppDesign.fontSizeTitleS,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppDesign.spaceS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.meaning,
                style: TextStyle(
                  fontSize: AppDesign.fontSizeBody,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: AppDesign.alphaSecondary),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDesign.spaceXxs),
              Text(
                formatTimestamp?.call(item.timestamp) ??
                    _defaultFormatTimestamp(context, item.timestamp),
                style: TextStyle(
                  fontSize: AppDesign.fontSizeCaption,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: AppDesign.alphaDisabled),
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(AppIcons.deleteOutline),
          onPressed: () => onDelete(item),
          tooltip: l10n?.delete ?? 'Delete',
        ),
        onTap: () => onTap(item.word),
      ),
    );

    // Wrap with Dismissible if confirmDismiss is provided
    if (confirmDismiss != null) {
      return Dismissible(
        key: Key('${item.word}-${item.timestamp}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppDesign.spaceXl),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(AppDesign.radiusL),
          ),
          child: Icon(
            AppIcons.delete,
            color: theme.colorScheme.onError,
          ),
        ),
        confirmDismiss: (direction) => confirmDismiss!(item),
        onDismissed: (_) => onDelete(item),
        child: tile,
      );
    }

    return tile;
  }

  String _defaultFormatTimestamp(BuildContext context, int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    // Use DateFormat for better localization support
    // For today, show only time
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    }
    // For yesterday, show date and time
    if (difference.inDays == 1) {
      return DateFormat('MMM d, HH:mm').format(date);
    }
    // For dates within a week, show day and time
    if (difference.inDays < 7) {
      return DateFormat('EEE, HH:mm').format(date);
    }
    // For older dates, show full date
    return DateFormat.yMMMd().add_Hm().format(date);
  }
}
