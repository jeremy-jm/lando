import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/models/query_history_item.dart';
import 'package:lando/routes/app_routes.dart';
import 'package:lando/storage/favorites_storage.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearFavorites),
        content: Text(l10n.confirmClearFavorites),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.confirm),
          ),
        ],
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
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.clearFavorites,
              onPressed: _clearFavorites,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noFavorites,
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final item = _favorites[index];
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
                    onDismissed: (direction) {
                      _deleteItem(item);
                    },
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.delete),
                              content: Text('${l10n.delete} "${item.word}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                  child: Text(l10n.confirm),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Icon(
                          Icons.star,
                          color: theme.colorScheme.primary,
                        ),
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
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(item.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteItem(item),
                          tooltip: l10n.delete,
                        ),
                        onTap: () => _navigateToQuery(item.word),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
