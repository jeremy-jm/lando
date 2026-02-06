import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/models/query_history_item.dart';
import 'package:lando/routes/app_routes.dart';
import 'package:lando/services/analytics/analytics_service.dart';
import 'package:lando/storage/favorites_storage.dart';
import 'package:lando/features/shared/widgets/query_history_item_tile.dart';
import 'package:lando/features/shared/widgets/empty_state_widget.dart';
import 'package:lando/features/shared/widgets/confirm_dialog_widget.dart';
import 'package:intl/intl.dart';

/// Favorites page that displays all favorited words.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<QueryHistoryItem> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final favorites = await FavoritesStorage.getFavorites();

    if (mounted) {
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(QueryHistoryItem item) async {
    AnalyticsService.instance.event(
      'tap_favorites_delete_item',
      properties: {'word': item.word},
    );
    final success = await FavoritesStorage.deleteFavorite(item.word);
    if (success && mounted) {
      await _loadFavorites();
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

  Future<void> _clearFavorites() async {
    AnalyticsService.instance.event('tap_favorites_clear');
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialogWidget.show(
      context,
      title: l10n.clearFavorites,
      content: l10n.confirmClearFavorites,
      confirmText: l10n.confirm,
      cancelText: l10n.cancel,
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
      ),
    );

    if (confirmed == true) {
      final success = await FavoritesStorage.clearFavorites();
      if (success && mounted) {
        await _loadFavorites();
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n.clearFavorites),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _navigateToQuery(String word) {
    AnalyticsService.instance.event(
      'tap_favorites_item',
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
        title: Text(l10n.favorites),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(AppIcons.deleteOutline),
              tooltip: l10n.clearFavorites,
              onPressed: AnalyticsService.instance.wrapTap(
                'tap_favorites_clear_button',
                _clearFavorites,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? EmptyStateWidget(
                  icon: AppIcons.favoriteBorder,
                  message: l10n.noFavorites,
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDesign.spaceS),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final item = _favorites[index];
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
