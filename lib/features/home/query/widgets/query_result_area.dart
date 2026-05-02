import 'package:flutter/material.dart';
import 'package:lando/features/home/query/query_bloc.dart';
import 'package:lando/features/dictionary/widgets/dictionary_widget.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/translation/translation_service_type.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';

/// Displays loading / error / empty / dictionary results based on [QueryState].
class QueryResultArea extends StatelessWidget {
  const QueryResultArea({
    super.key,
    required this.state,
    required this.onQueryTap,
    required this.onRetry,
    required this.platforms,
  });

  final QueryState state;
  final ValueChanged<String> onQueryTap;
  final VoidCallback onRetry;
  final List<TranslationServiceType> platforms;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _ErrorState(
        message: state.errorMessage!,
        onRetry: onRetry,
      );
    }

    if (state.query.isNotEmpty) {
      return DictionaryWidget(
        query: state.query,
        platforms: platforms,
        onQueryTap: onQueryTap,
      );
    }

    if (state.result.isNotEmpty) {
      return _ResultText(result: state.result);
    }

    return const _EmptyState();
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.errorOutline,
            size: AppDesign.emptyStateIconSize,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: AppDesign.spaceL),
          Text(
            message,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: AppDesign.fontSizeBodyL,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesign.spaceL),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(l10n?.translation ?? 'Retry'),
          ),
        ],
      ),
    );
  }
}

class _ResultText extends StatelessWidget {
  const _ResultText({required this.result});

  final String result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: AppDesign.paddingCard,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDesign.radiusL),
        ),
        child: SelectableText(
          result,
          style: TextStyle(
            fontSize: AppDesign.fontSizeBodyL,
            color: theme.colorScheme.onSurface,
            height: AppDesign.lineHeightBody,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.search,
            size: AppDesign.emptyStateIconSize,
            color: theme.colorScheme.onSurface.withValues(alpha: AppDesign.alphaEmptyIcon),
          ),
          const SizedBox(height: AppDesign.spaceL),
          Text(
            l10n?.translation ?? 'Translation',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: AppDesign.alphaTertiary),
              fontSize: AppDesign.emptyStateFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
