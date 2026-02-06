import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/models/query_history_item.dart';
import 'package:lando/routes/app_routes.dart';
import 'package:lando/services/analytics/analytics_service.dart';
import 'package:lando/storage/query_history_storage.dart';
import 'package:lando/features/shared/widgets/query_history_item_tile.dart';
import 'package:lando/features/shared/widgets/empty_state_widget.dart';
import 'package:lando/features/shared/widgets/confirm_dialog_widget.dart';
import 'package:intl/intl.dart';

/// Query history page that displays all previous word queries.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<QueryHistoryItem> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final history = await QueryHistoryStorage.getHistory();

    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(QueryHistoryItem item) async {
    AnalyticsService.instance.event(
      'tap_history_delete_item',
      properties: {'word': item.word},
    );
    final success = await QueryHistoryStorage.deleteHistoryItem(item.word);
    if (success && mounted) {
      await _loadHistory();
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final l10n = AppLocalizations.of(context);
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('${item.word} ${l10n!.delete}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    AnalyticsService.instance.event('tap_history_clear');
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialogWidget.show(
      context,
      title: l10n.clearHistory,
      content: l10n.confirmClearHistory,
      confirmText: l10n.confirm,
      cancelText: l10n.cancel,
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
      ),
    );

    if (confirmed == true) {
      final success = await QueryHistoryStorage.clearHistory();
      if (success && mounted) {
        await _loadHistory();
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n.clearHistory),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _navigateToQuery(String word) {
    AnalyticsService.instance.event(
      'tap_history_item',
      properties: {'word': word},
    );
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.query, arguments: {'query': word});
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    // Use DateFormat for better localization support
    // For today, show only time
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    }
    // For yesterday, show "Yesterday" with time
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(AppIcons.deleteOutline),
              tooltip: l10n.clearHistory,
              onPressed: AnalyticsService.instance.wrapTap(
                'tap_history_clear_button',
                _clearHistory,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? EmptyStateWidget(
                  icon: AppIcons.history, message: l10n.noHistory)
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDesign.spaceS),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return QueryHistoryItemTile(
                        item: item,
                        onTap: _navigateToQuery,
                        onDelete: _deleteItem,
                        confirmDismiss: (item) async {
                          final confirmed = await ConfirmDialogWidget.show(
                            context,
                            title: l10n.delete,
                            content: '${l10n.delete} "${item.word}"?',
                            confirmText: l10n.confirm,
                            cancelText: l10n.cancel,
                            confirmButtonStyle: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                          return confirmed ?? false;
                        },
                        formatTimestamp: _formatTimestamp,
                      );
                    },
                  ),
                ),
    );
  }
}
