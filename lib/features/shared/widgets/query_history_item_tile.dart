import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.word,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.meaning,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                formatTimestamp?.call(item.timestamp) ??
                    _defaultFormatTimestamp(context, item.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
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
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
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

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (difference.inDays == 1) {
      return '${date.month}/${date.day}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (difference.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[date.weekday - 1]}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.year}/${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
