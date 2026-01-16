import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lando/services/translation/youdao/models/youdao_ec.dart';
import 'package:lando/services/translation/youdao/models/youdao_other_models.dart';
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
    this.onGeneralPronunciationTap,
    this.onFanyiPronunciationTap,
  });

  final YoudaoResponse response;
  final String query;
  final VoidCallback? onUsPronunciationTap;
  final VoidCallback? onUkPronunciationTap;
  final VoidCallback? onGeneralPronunciationTap;
  final VoidCallback? onFanyiPronunciationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ec = response.ec;
    final ecWord = ec?.word;
    final phrs = response.phrs;
    final webTrans = response.webTrans;
    final ee = response.ee;

    // Try to get translations from different sources
    final translationsByPos = <String, List<String>>{};
    String? mainTranslation;
    // List<String>? examTypes;

    // Priority 0: Fanyi (translation) - highest priority
    if (response.fanyi != null &&
        response.fanyi!.tran != null &&
        response.fanyi!.tran!.isNotEmpty) {
      mainTranslation = response.fanyi!.tran;
      translationsByPos.putIfAbsent('翻译', () => []);
      translationsByPos['翻译']!.add(response.fanyi!.tran!);
    }

    // Priority 1: EC (basic dictionary) - for English words
    if (ecWord != null && mainTranslation == null) {
      // examTypes = ec?.examType;
      for (final tr in ecWord.trs ?? []) {
        if (tr.tran != null && tr.tran!.isNotEmpty) {
          final pos = tr.pos ?? '其他';
          translationsByPos.putIfAbsent(pos, () => []);
          translationsByPos[pos]!.add(tr.tran!);
        }
      }
      if (ecWord.trs?.isNotEmpty == true) {
        mainTranslation = ecWord.trs!.first.tran;
      }
    }

    // Priority 2: Web Translation - for Chinese and other languages
    if (translationsByPos.isEmpty &&
        mainTranslation == null &&
        webTrans?.webTranslation != null) {
      for (final webItem in webTrans!.webTranslation!) {
        if (webItem.trans != null) {
          for (final transItem in webItem.trans!) {
            if (transItem.value != null && transItem.value!.isNotEmpty) {
              translationsByPos.putIfAbsent('翻译', () => []);
              translationsByPos['翻译']!.add(transItem.value!);
            }
          }
        }
        if (mainTranslation == null && webItem.trans?.isNotEmpty == true) {
          mainTranslation = webItem.trans!.first.value;
        }
      }
    }

    // Priority 3: EE (extended dictionary)
    if (translationsByPos.isEmpty &&
        mainTranslation == null &&
        ee?.word != null) {
      final eeWord = ee!.word!;
      for (final tr in eeWord.trs ?? []) {
        if (tr.tr != null) {
          for (final trItem in tr.tr!) {
            if (trItem.tran != null && trItem.tran!.isNotEmpty) {
              final pos = tr.pos ?? '翻译';
              translationsByPos.putIfAbsent(pos, () => []);
              translationsByPos[pos]!.add(trItem.tran!);
            }
          }
        }
      }
      if (mainTranslation == null && eeWord.trs?.isNotEmpty == true) {
        final firstTr = eeWord.trs!.first;
        if (firstTr.tr?.isNotEmpty == true) {
          mainTranslation = firstTr.tr!.first.tran;
        }
      }
    }

    // If still no translations, show empty state
    if (translationsByPos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.translate,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16.0),
            Text(
              '未找到翻译结果',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word header
          _buildWordHeader(
            context,
            theme,
            query,
            mainTranslation,
            // examTypes,
            ecWord,
            response.fanyi,
            onFanyiPronunciationTap,
          ),
          const SizedBox(height: 24.0),

          // Pronunciation section (only for EC words)
          if (ecWord != null &&
              (ecWord.usphone != null ||
                  ecWord.ukphone != null ||
                  onGeneralPronunciationTap != null))
            _buildPronunciationSection(
              context,
              theme,
              ecWord,
              onUsPronunciationTap,
              onUkPronunciationTap,
              onGeneralPronunciationTap,
            ),

          // Translations by part of speech
          if (translationsByPos.isNotEmpty) ...[
            const SizedBox(height: 24.0),
            ...translationsByPos.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: _buildPosSection(
                  context,
                  theme,
                  entry.key,
                  entry.value,
                  response.fanyi,
                  onFanyiPronunciationTap,
                ),
              ),
            ),
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
    String word,
    String? mainTranslation,
    // List<String>? examTypes,
    YoudaoEcWord? ecWord,
    YoudaoFanyi? fanyi,
    VoidCallback? onFanyiPronunciationTap,
  ) {
    // Check if mainTranslation is from fanyi and has voice
    final isFanyiTranslation =
        fanyi != null &&
        fanyi.tran != null &&
        fanyi.tran == mainTranslation &&
        fanyi.voice != null &&
        fanyi.voice!.isNotEmpty &&
        onFanyiPronunciationTap != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word and main translation
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (mainTranslation != null) ...[
              const SizedBox(height: 8.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFanyiTranslation) ...[
                    IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: onFanyiPronunciationTap,
                      tooltip: '播放语音',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                  ],
                  Expanded(
                    child: Text(
                      mainTranslation,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        // // Exam type tags
        // if (examTypes != null && examTypes.isNotEmpty) ...[
        //   const SizedBox(height: 12.0),
        //   Wrap(
        //     spacing: 8.0,
        //     runSpacing: 8.0,
        //     children: examTypes.map((tag) => _buildTag(theme, tag)).toList(),
        //   ),
        // ],
      ],
    );
  }

  // Widget _buildTag(ThemeData theme, String text) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  //     decoration: BoxDecoration(
  //       color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
  //       borderRadius: BorderRadius.circular(4.0),
  //       border: Border.all(
  //         color: theme.colorScheme.primary.withValues(alpha: 0.3),
  //         width: 1,
  //       ),
  //     ),
  //     child: Text(
  //       text,
  //       style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
  //     ),
  //   );
  // }

  Widget _buildPronunciationSection(
    BuildContext context,
    ThemeData theme,
    YoudaoEcWord word,
    VoidCallback? onUsTap,
    VoidCallback? onUkTap,
    VoidCallback? onGeneralTap,
  ) {
    // Check if we have English pronunciations (US/UK) or general pronunciation
    final hasEnglishPronunciations =
        (word.usphone != null && onUsTap != null) ||
        (word.ukphone != null && onUkTap != null);
    final hasGeneralPronunciation = onGeneralTap != null;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          // US pronunciation (for English)
          if (word.usphone != null && onUsTap != null)
            _buildPronunciationItem(
              theme,
              'US',
              '/${word.usphone}/',
              Icons.volume_up,
              onUsTap,
            ),
          if (word.usphone != null && word.ukphone != null && onUsTap != null)
            const SizedBox(width: 16.0),
          // UK pronunciation (for English)
          if (word.ukphone != null && onUkTap != null)
            _buildPronunciationItem(
              theme,
              'UK',
              '/${word.ukphone}/',
              Icons.volume_up,
              onUkTap,
            ),
          // General pronunciation (for non-English languages)
          if (hasGeneralPronunciation && !hasEnglishPronunciations)
            _buildPronunciationItem(
              theme,
              '发音',
              '',
              Icons.volume_up,
              onGeneralTap,
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
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 8.0),
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
    YoudaoFanyi? fanyi,
    VoidCallback? onFanyiPronunciationTap,
  ) {
    // Check if this is the fanyi translation section
    final isFanyiSection =
        pos == '翻译' &&
        fanyi != null &&
        fanyi.tran != null &&
        translations.isNotEmpty &&
        translations.first == fanyi.tran &&
        fanyi.voice != null &&
        fanyi.voice!.isNotEmpty &&
        onFanyiPronunciationTap != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Part of speech label
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
              final isFanyiItem = isFanyiSection && index == 0;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < translations.length - 1 ? 8.0 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    if (isFanyiItem) ...[
                      IconButton(
                        icon: Icon(
                          Icons.volume_up,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: onFanyiPronunciationTap,
                        tooltip: '播放语音',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                    ],
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
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
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
