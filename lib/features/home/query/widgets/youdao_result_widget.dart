// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:lando/features/widgets/dict_widget.dart';
// import 'package:lando/models/result_model.dart';
// import 'package:lando/services/translation/translation_service_type.dart';
// import 'package:lando/services/translation/youdao/models/youdao_ce.dart';
// import 'package:lando/services/translation/youdao/models/youdao_ec.dart';
// import 'package:lando/services/translation/youdao/models/youdao_other_models.dart';
// import 'package:lando/services/translation/youdao/models/youdao_phrs.dart';
// import 'package:lando/services/translation/youdao/models/youdao_response.dart';
// import 'package:lando/services/translation/youdao/models/youdao_web_trans.dart';

// /// Widget for displaying Youdao dictionary result in a detailed format.
// class YoudaoResultWidget extends StatelessWidget {
//   const YoudaoResultWidget({
//     super.key,
//     required this.response,
//     required this.query,
//     required this.onUsPronunciationTap,
//     required this.onUkPronunciationTap,
//     this.onGeneralPronunciationTap,
//     this.onFanyiPronunciationTap,
//   });

//   final YoudaoResponse response;
//   final String query;
//   final VoidCallback? onUsPronunciationTap;
//   final VoidCallback? onUkPronunciationTap;
//   final VoidCallback? onGeneralPronunciationTap;
//   final VoidCallback? onFanyiPronunciationTap;

//   @override
//   Widget build(BuildContext context) {
//     return DictWidget(
//       query: query,
//       platforms: [
//         TranslationServiceType.youdao,
//         // TranslationServiceType.google,
//         // TranslationServiceType.bing,
//       ],
//     );
//     final theme = Theme.of(context);
//     final ec = response.ec;
//     final ecWord = ec?.word;
//     final ce = response.ce;
//     final ceWord = ce?.word;
//     final phrs = response.phrs;
//     final webTrans = response.webTrans;
//     final ee = response.ee;
//     final simple = response.simple;

//     // Determine input language
//     final guessLanguage = response.meta?.guessLanguage;
//     final lang = response.meta?.lang;
//     final isChineseInput =
//         guessLanguage == 'zh' || lang == 'zh' || lang == 'zh-CHS';
//     final isEnglishInput =
//         guessLanguage == 'eng' || lang == 'eng' || lang == 'en';

//     // Try to get translations from different sources
//     final translationsByPos = <String, List<String>>{};
//     String? mainTranslation;
//     // List<String>? examTypes;

//     // Priority logic based on input language:
//     // 1. If Chinese input: prioritize CE (Chinese-English)
//     // 2. If English input: prioritize EC (English-Chinese)
//     // 3. If both EC and CE are empty: prioritize Simple, then Fanyi

//     // Priority 1: CE (Chinese-English) - for Chinese input
//     // Note: CE translations are displayed separately, not merged into translationsByPos
//     if (isChineseInput && ceWord != null) {
//       if (ceWord.trs?.isNotEmpty == true && ceWord.trs!.first.text != null) {
//         mainTranslation = ceWord.trs!.first.text;
//       }
//     }

//     // Priority 2: EC (English-Chinese) - for English input
//     if (isEnglishInput && ecWord != null && mainTranslation == null) {
//       // examTypes = ec?.examType;
//       for (final tr in ecWord.trs ?? []) {
//         if (tr.tran != null && tr.tran!.isNotEmpty) {
//           final pos = tr.pos ?? '其他';
//           translationsByPos.putIfAbsent(pos, () => []);
//           translationsByPos[pos]!.add(tr.tran!);
//         }
//       }
//       if (ecWord.trs?.isNotEmpty == true) {
//         mainTranslation = ecWord.trs!.first.tran;
//       }
//     }

//     // Priority 3: If both EC and CE are empty, try Simple
//     if (mainTranslation == null && ecWord == null && ceWord == null) {
//       if (simple?.word != null && simple!.word!.isNotEmpty) {
//         final firstWord = simple.word!.first;
//         if (firstWord.returnPhrase != null &&
//             firstWord.returnPhrase!.isNotEmpty) {
//           mainTranslation = firstWord.returnPhrase;
//           translationsByPos.putIfAbsent('翻译', () => []);
//           translationsByPos['翻译']!.add(firstWord.returnPhrase!);
//         }
//       }
//     }

//     // Priority 4: Fanyi (translation) - fallback
//     if (mainTranslation == null &&
//         response.fanyi != null &&
//         response.fanyi!.tran != null &&
//         response.fanyi!.tran!.isNotEmpty) {
//       mainTranslation = response.fanyi!.tran;
//       translationsByPos.putIfAbsent('翻译', () => []);
//       translationsByPos['翻译']!.add(response.fanyi!.tran!);
//     }

//     // Priority 5: Web Translation - for Chinese and other languages
//     // Note: Web translations are displayed separately, not merged into translationsByPos
//     if (mainTranslation == null && webTrans?.webTranslation != null) {
//       final firstWebItem = webTrans!.webTranslation!.first;
//       if (firstWebItem.trans?.isNotEmpty == true) {
//         mainTranslation = firstWebItem.trans!.first.value;
//       }
//     }

//     // Priority 6: EE (extended dictionary)
//     if (translationsByPos.isEmpty &&
//         mainTranslation == null &&
//         ee?.word != null) {
//       final eeWord = ee!.word!;
//       for (final tr in eeWord.trs ?? []) {
//         if (tr.tr != null) {
//           for (final trItem in tr.tr!) {
//             if (trItem.tran != null && trItem.tran!.isNotEmpty) {
//               final pos = tr.pos ?? '翻译';
//               translationsByPos.putIfAbsent(pos, () => []);
//               translationsByPos[pos]!.add(trItem.tran!);
//             }
//           }
//         }
//       }
//       if (mainTranslation == null && eeWord.trs?.isNotEmpty == true) {
//         final firstTr = eeWord.trs!.first;
//         if (firstTr.tr?.isNotEmpty == true) {
//           mainTranslation = firstTr.tr!.first.tran;
//         }
//       }
//     }

//     // If still no translations, show empty state
//     if (translationsByPos.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.translate,
//               size: 64,
//               color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
//             ),
//             const SizedBox(height: 16.0),
//             Text(
//               '未找到翻译结果',
//               style: TextStyle(
//                 color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     // Check both ec.word.wfs and individual.anagram.wfs for word forms
//     final wordForms =
//         response.ec?.word?.wfs ?? response.individual?.anagram?.wfs;

//     return SingleChildScrollView(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12.0),
//           color: theme.colorScheme.surfaceContainer,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Word header
//             _buildWordHeader(
//               context,
//               theme,
//               query,
//               mainTranslation,
//               // examTypes,
//               ecWord,
//               ceWord,
//               response.fanyi,
//               onFanyiPronunciationTap,
//             ),
//             const SizedBox(height: 24.0),

//             // Pronunciation section (only for EC words)
//             if (ecWord != null &&
//                 (ecWord.usphone != null ||
//                     ecWord.ukphone != null ||
//                     onGeneralPronunciationTap != null))
//               _buildPronunciationSection(
//                 context,
//                 theme,
//                 ecWord,
//                 onUsPronunciationTap,
//                 onUkPronunciationTap,
//                 onGeneralPronunciationTap,
//               ),

//             // CE Translations section - display each translation separately
//             if (isChineseInput &&
//                 ceWord != null &&
//                 ceWord.trs != null &&
//                 ceWord.trs!.isNotEmpty) ...[
//               if (ecWord != null &&
//                   (ecWord.usphone != null ||
//                       ecWord.ukphone != null ||
//                       onGeneralPronunciationTap != null))
//                 const SizedBox(height: 24.0),
//               _buildCeTranslationsSection(context, theme, ceWord.trs!),
//             ],

//             // Translations by part of speech (for EC and other sources)
//             if (translationsByPos.isNotEmpty) ...[
//               if ((isChineseInput &&
//                       ceWord != null &&
//                       ceWord.trs != null &&
//                       ceWord.trs!.isNotEmpty) ||
//                   (ecWord != null &&
//                       (ecWord.usphone != null ||
//                           ecWord.ukphone != null ||
//                           onGeneralPronunciationTap != null)))
//                 const SizedBox(height: 24.0),
//               ...translationsByPos.entries.map(
//                 (entry) => Padding(
//                   padding: const EdgeInsets.only(bottom: 20.0),
//                   child: _buildPosSection(
//                     context,
//                     theme,
//                     entry.key,
//                     entry.value,
//                     response.fanyi,
//                     onFanyiPronunciationTap,
//                   ),
//                 ),
//               ),
//             ],

//             // Web Translation section - display each webItem separately
//             if (webTrans?.webTranslation != null &&
//                 webTrans!.webTranslation!.isNotEmpty) ...[
//               if (translationsByPos.isNotEmpty ||
//                   (ecWord != null &&
//                       (ecWord.usphone != null ||
//                           ecWord.ukphone != null ||
//                           onGeneralPronunciationTap != null)))
//                 const SizedBox(height: 24.0),
//               _buildWebTranslationSection(
//                 context,
//                 theme,
//                 webTrans.webTranslation!,
//               ),
//             ],

//             // Related phrases
//             if (phrs?.phrs != null && phrs!.phrs!.isNotEmpty) ...[
//               const SizedBox(height: 24.0),
//               _buildPhrasesSection(context, theme, phrs.phrs!),
//             ],

//             // Word forms (时态)
//             if (wordForms != null && wordForms.isNotEmpty) ...[
//               const SizedBox(height: 24.0),
//               _buildWordFormsSection(context, theme, wordForms),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWordHeader(
//     BuildContext context,
//     ThemeData theme,
//     String word,
//     String? mainTranslation,
//     // List<String>? examTypes,
//     YoudaoEcWord? ecWord,
//     YoudaoCeWord? ceWord,
//     YoudaoFanyi? fanyi,
//     VoidCallback? onFanyiPronunciationTap,
//   ) {
//     // Check if mainTranslation is from fanyi and has voice
//     final isFanyiTranslation =
//         fanyi != null &&
//         fanyi.tran != null &&
//         fanyi.tran == mainTranslation &&
//         fanyi.voice != null &&
//         fanyi.voice!.isNotEmpty &&
//         onFanyiPronunciationTap != null;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Word and main translation
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               word,
//               style: theme.textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//             if (mainTranslation != null) ...[
//               const SizedBox(height: 8.0),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (isFanyiTranslation) ...[
//                     IconButton(
//                       icon: Icon(
//                         Icons.volume_up,
//                         size: 20,
//                         color: theme.colorScheme.primary,
//                       ),
//                       onPressed: onFanyiPronunciationTap,
//                       tooltip: '播放语音',
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(
//                         minWidth: 32,
//                         minHeight: 32,
//                       ),
//                     ),
//                     const SizedBox(width: 4.0),
//                   ],
//                   // Expanded(
//                   //   child: Text(
//                   //     mainTranslation,
//                   //     style: theme.textTheme.titleMedium?.copyWith(
//                   //       color: theme.colorScheme.primary,
//                   //     ),
//                   //     softWrap: true,
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ],
//           ],
//         ),

//         // // Exam type tags
//         // if (examTypes != null && examTypes.isNotEmpty) ...[
//         //   const SizedBox(height: 12.0),
//         //   Wrap(
//         //     spacing: 8.0,
//         //     runSpacing: 8.0,
//         //     children: examTypes.map((tag) => _buildTag(theme, tag)).toList(),
//         //   ),
//         // ],
//       ],
//     );
//   }

//   // Widget _buildTag(ThemeData theme, String text) {
//   //   return Container(
//   //     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//   //     decoration: BoxDecoration(
//   //       color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
//   //       borderRadius: BorderRadius.circular(4.0),
//   //       border: Border.all(
//   //         color: theme.colorScheme.primary.withValues(alpha: 0.3),
//   //         width: 1,
//   //       ),
//   //     ),
//   //     child: Text(
//   //       text,
//   //       style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
//   //     ),
//   //   );
//   // }

//   Widget _buildPronunciationSection(
//     BuildContext context,
//     ThemeData theme,
//     YoudaoEcWord word,
//     VoidCallback? onUsTap,
//     VoidCallback? onUkTap,
//     VoidCallback? onGeneralTap,
//   ) {
//     // Check if we have English pronunciations (US/UK) or general pronunciation
//     final hasEnglishPronunciations =
//         (word.usphone != null && onUsTap != null) ||
//         (word.ukphone != null && onUkTap != null);
//     final hasGeneralPronunciation = onGeneralTap != null;

//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
//       child: Column(
//         children: [
//           // US pronunciation (for English)
//           if (word.usphone != null && onUsTap != null)
//             _buildPronunciationItem(
//               theme,
//               'US',
//               '/${word.usphone}/',
//               Icons.volume_up,
//               onUsTap,
//             ),
//           if (word.usphone != null && word.ukphone != null && onUsTap != null)
//             const SizedBox(width: 16.0),
//           // UK pronunciation (for English)
//           if (word.ukphone != null && onUkTap != null)
//             _buildPronunciationItem(
//               theme,
//               'UK',
//               '/${word.ukphone}/',
//               Icons.volume_up,
//               onUkTap,
//             ),
//           // General pronunciation (for non-English languages)
//           if (hasGeneralPronunciation && !hasEnglishPronunciations)
//             _buildPronunciationItem(
//               theme,
//               '发音',
//               '',
//               Icons.volume_up,
//               onGeneralTap,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPronunciationItem(
//     ThemeData theme,
//     String label,
//     String phonetic,
//     IconData icon,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             Icon(icon, size: 20, color: theme.colorScheme.primary),
//             const SizedBox(width: 8.0),
//             Expanded(
//               child: Row(
//                 children: [
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                     ),
//                   ),
//                   const SizedBox(width: 8.0),
//                   Text(
//                     phonetic,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: theme.colorScheme.onSurface,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPosSection(
//     BuildContext context,
//     ThemeData theme,
//     String pos,
//     List<String> translations,
//     YoudaoFanyi? fanyi,
//     VoidCallback? onFanyiPronunciationTap,
//   ) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Part of speech label
//         Text(
//           pos,
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//         const SizedBox(width: 8.0),
//         Expanded(
//           child: Text(
//             translations.join('; '),
//             style: theme.textTheme.titleMedium?.copyWith(
//               color: theme.colorScheme.onSurface,
//             ),
//             softWrap: true,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCeTranslationsSection(
//     BuildContext context,
//     ThemeData theme,
//     List<YoudaoCeWordTr> translations,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '翻译',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//         const SizedBox(height: 12.0),
//         ...translations.asMap().entries.map((entry) {
//           final index = entry.key;
//           final tr = entry.value;

//           if (tr.text == null || tr.text!.isEmpty) {
//             return const SizedBox.shrink();
//           }

//           return Padding(
//             padding: EdgeInsets.only(
//               bottom: index < translations.length - 1 ? 12.0 : 0,
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(width: 8.0),
//                 Expanded(
//                   child: Text(
//                     tr.text!,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       color: theme.colorScheme.onSurface,
//                     ),
//                     softWrap: true,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildPhrasesSection(
//     BuildContext context,
//     ThemeData theme,
//     List<YoudaoPhr> phrases,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '相关短语',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//         const SizedBox(height: 12.0),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: phrases.asMap().entries.map((entry) {
//               final index = entry.key;
//               final phrase = entry.value;
//               final headword = phrase.headword;
//               final translation = phrase.translation;

//               if (headword == null || translation == null) {
//                 return const SizedBox.shrink();
//               }

//               return Padding(
//                 padding: EdgeInsets.only(
//                   bottom: index < phrases.length - 1 ? 12.0 : 0,
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             headword,
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: theme.colorScheme.primary,
//                             ),
//                           ),
//                           const SizedBox(height: 4.0),
//                           Text(
//                             translation,
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: theme.colorScheme.onSurface.withValues(
//                                 alpha: 0.8,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.content_copy, size: 18),
//                           onPressed: () {
//                             Clipboard.setData(ClipboardData(text: headword));
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('已复制'),
//                                 duration: Duration(seconds: 1),
//                               ),
//                             );
//                           },
//                           tooltip: '复制',
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildWordFormsSection(
//     BuildContext context,
//     ThemeData theme,
//     List<YoudaoWf> wordForms,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '单词时态',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//         const SizedBox(height: 12.0),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surfaceContainerHighest,
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: wordForms.map((wf) {
//               if (wf.name == null || wf.value == null) {
//                 return const SizedBox.shrink();
//               }

//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 12.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: 80,
//                       child: Text(
//                         wf.name!,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: theme.colorScheme.primary,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16.0),
//                     Expanded(
//                       child: Text(
//                         wf.value!,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildWebTranslationSection(
//     BuildContext context,
//     ThemeData theme,
//     List<YoudaoWebTranslation> webTranslations,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '网络翻译',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//         const SizedBox(height: 12.0),
//         ...webTranslations.asMap().entries.map((entry) {
//           final index = entry.key;
//           final webItem = entry.value;

//           if (webItem.key == null ||
//               webItem.trans == null ||
//               webItem.trans!.isEmpty) {
//             return const SizedBox.shrink();
//           }

//           return Padding(
//             padding: EdgeInsets.only(
//               bottom: index < webTranslations.length - 1 ? 16.0 : 0,
//             ),
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12.0),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Key (keyword)
//                   Text(
//                     webItem.key!,
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: theme.colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 8.0),
//                   // Translations - one per line
//                   ...webItem.trans!.asMap().entries.map((transEntry) {
//                     final transIndex = transEntry.key;
//                     final transItem = transEntry.value;

//                     if (transItem.value == null || transItem.value!.isEmpty) {
//                       return const SizedBox.shrink();
//                     }

//                     return Padding(
//                       padding: EdgeInsets.only(
//                         bottom: transIndex < webItem.trans!.length - 1
//                             ? 8.0
//                             : 0,
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(width: 8.0),
//                           Expanded(
//                             child: Text(
//                               transItem.value!,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: theme.colorScheme.onSurface,
//                                 height: 1.5,
//                               ),
//                               softWrap: true,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ],
//     );
//   }
// }
