import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lando/services/translation/youdao/models/youdao_ec.dart';
import 'package:lando/services/translation/youdao/models/youdao_phrs.dart';
import 'package:lando/services/translation/youdao/models/youdao_response.dart';

/// Widget for displaying Youdao dictionary result in a detailed format.
class YoudaoResultWidget extends StatelessWidget {
  const YoudaoResultWidget({
    super.key,
    required this.response,
    required this.query,
    required this.onUsPronunciationTap,
    required this.onUkPronunciationTap,
  });

  final YoudaoResponse response;
  final String query;
  final VoidCallback? onUsPronunciationTap;
  final VoidCallback? onUkPronunciationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ec = response.ec;
    final ecWord = ec?.word;
    final phrs = response.phrs;

    if (ecWord == null) {
      return const SizedBox.shrink();
    }

    // Group translations by part of speech
    final translationsByPos = <String, List<String>>{};
    for (final tr in ecWord.trs ?? []) {
      if (tr.tran != null && tr.tran!.isNotEmpty) {
        final pos = tr.pos ?? '其他';
        translationsByPos.putIfAbsent(pos, () => []);
        translationsByPos[pos]!.add(tr.tran!);
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word header
          _buildWordHeader(context, theme, ecWord, ec?.examType),
          const SizedBox(height: 24.0),

          // Pronunciation section
          if (ecWord.usphone != null || ecWord.ukphone != null)
            _buildPronunciationSection(
              context,
              theme,
              ecWord,
              onUsPronunciationTap,
              onUkPronunciationTap,
            ),

          // Translations by part of speech
          if (translationsByPos.isNotEmpty) ...[
            const SizedBox(height: 24.0),
            ...translationsByPos.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildPosSection(context, theme, entry.key, entry.value),
                )),
          ],

          // Related phrases
          if (phrs?.phrs != null && phrs!.phrs!.isNotEmpty) ...[
            const SizedBox(height: 24.0),
            _buildPhrasesSection(context, theme, phrs.phrs!),
          ],
        ],
      ),
    );
  }

  Widget _buildWordHeader(
    BuildContext context,
    ThemeData theme,
    YoudaoEcWord word,
    List<String>? examTypes,
  ) {
    final mainTranslation = word.trs?.isNotEmpty == true
        ? word.trs!.first.tran
        : query;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word and main translation
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              query,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (mainTranslation != null) ...[
              const SizedBox(width: 12.0),
              Text(
                mainTranslation,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),

        // Exam type tags
        if (examTypes != null && examTypes.isNotEmpty) ...[
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: examTypes.map((tag) => _buildTag(theme, tag)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTag(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPronunciationSection(
    BuildContext context,
    ThemeData theme,
    YoudaoEcWord word,
    VoidCallback? onUsTap,
    VoidCallback? onUkTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          // US pronunciation
          if (word.usphone != null && onUsTap != null)
            Expanded(
              child: _buildPronunciationItem(
                theme,
                'US',
                '/${word.usphone}/',
                Icons.volume_up,
                onUsTap,
              ),
            ),
          if (word.usphone != null && word.ukphone != null)
            const SizedBox(width: 16.0),
          // UK pronunciation
          if (word.ukphone != null && onUkTap != null)
            Expanded(
              child: _buildPronunciationItem(
                theme,
                'UK',
                '/${word.ukphone}/',
                Icons.volume_down,
                onUkTap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPronunciationItem(
    ThemeData theme,
    String label,
    String phonetic,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    phonetic,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosSection(
    BuildContext context,
    ThemeData theme,
    String pos,
    List<String> translations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Part of speech label
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                pos,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),

        // Translations list
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: translations.asMap().entries.map((entry) {
              final index = entry.key;
              final translation = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index < translations.length - 1 ? 8.0 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        translation,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhrasesSection(
    BuildContext context,
    ThemeData theme,
    List<YoudaoPhr> phrases,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '相关短语',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: phrases.asMap().entries.map((entry) {
              final index = entry.key;
              final phrase = entry.value;
              final headword = phrase.headword;
              final translation = phrase.translation;
              
              if (headword == null || translation == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < phrases.length - 1 ? 12.0 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headword,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            translation,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.content_copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: headword));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('已复制'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          tooltip: '复制',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
