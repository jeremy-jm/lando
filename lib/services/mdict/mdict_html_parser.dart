import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:lando/models/result_model.dart';

/// Parses MDict HTML content into a structured [ResultModel].
///
/// MDict entries vary widely across dictionaries (ECDICT, OALD, LDOCE, etc.).
/// This parser handles the common HTML patterns used by most MDict词典.
class MdictHtmlParser {
  /// Parses MDict HTML content and returns a [ResultModel].
  ///
  /// [html] - Raw HTML string from MDict lookup
  /// [query] - The original search word
  static ResultModel? parse(String html, String query) {
    if (html.trim().isEmpty) return null;

    try {
      final document = html_parser.parse(html);

      // Extract simple explanation (main translation)
      final simpleExplanation = _extractSimpleExplanation(document);

      // Extract phonetic information
      final phonetic = _extractPhonetic(document);

      // Extract translations by part of speech
      final translationsByPos = _extractTranslationsByPos(document);

      // Extract word forms
      final wordForms = _extractWordForms(document);

      // Extract phrases
      final phrases = _extractPhrases(document);

      // If we couldn't extract any meaningful content, return null
      if (simpleExplanation == null &&
          translationsByPos == null &&
          phonetic == null &&
          wordForms == null &&
          phrases == null) {
        return null;
      }

      return ResultModel(
        query: query,
        simpleExplanation: simpleExplanation,
        translationsByPos: translationsByPos,
        usPhonetic: phonetic,
        ukPhonetic: phonetic,
      );
    } catch (e) {
      return null;
    }
  }

  /// Extracts the main translation/explanation from the document.
  static String? _extractSimpleExplanation(Document document) {
    // Strategy 1: Look for <b> or <font> tags with class indicators
    // ECDICT typically uses <b> for headwords and structured content
    final bTags = document.querySelectorAll('b');
    for (final b in bTags) {
      final text = b.text.trim();
      if (text.isNotEmpty && text.length < 500) {
        // Likely a translation line
        if (_looksLikeTranslation(text)) {
          return text;
        }
      }
    }

    // Strategy 2: Look for paragraphs that contain translation patterns
    final paragraphs = document.querySelectorAll('p');
    for (final p in paragraphs) {
      final text = p.text.trim();
      if (_looksLikeTranslation(text)) {
        return text;
      }
    }

    // Strategy 3: Get the body text directly
    final body = document.body;
    if (body != null) {
      final text = body.text.trim();
      if (text.isNotEmpty && text.length < 1000) {
        return text;
      }
    }

    return null;
  }

  /// Checks if the text looks like a translation/explanation.
  static bool _looksLikeTranslation(String text) {
    if (text.isEmpty || text.length > 2000) return false;

    // Skip if it's mostly HTML tags or special characters
    final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (cleanText.isEmpty) return false;

    // Check for common translation patterns
    // Chinese characters indicate a Chinese translation
    final hasChinese = RegExp(r'[\u4e00-\u9fff]').hasMatch(cleanText);
    // English words indicate an English translation
    final hasEnglish = RegExp(r'[a-zA-Z]{2,}').hasMatch(cleanText);

    // Look for part-of-speech indicators
    final hasPosIndicator = RegExp(r'\bn\.|v\.|adj\.|adv\.|pron\.|prep\.|conj\.|num\.').hasMatch(cleanText.toLowerCase());

    // Look for bullet points or list markers
    final hasBullets = cleanText.contains(RegExp(r'[•\-\*\d+\.]'));

    // Look for colon-separated word and definition
    final hasColon = cleanText.contains(':');

    return hasChinese || hasEnglish || hasPosIndicator || hasBullets || hasColon;
  }

  /// Extracts phonetic/pronunciation information.
  static String? _extractPhonetic(Document document) {
    // Strategy 1: Look for <b> or <font> with phonetic markers
    // Many MDict dictionaries use UK][ or [US] or phonetic symbols
    final bodyText = document.body?.text ?? '';

    // Pattern: [UK] xxx or [US] xxx
    final ukMatch = RegExp(r'\[UK\]\s*([^\[\]]+)').firstMatch(bodyText);
    if (ukMatch != null) {
      return ukMatch.group(1)?.trim();
    }

    final usMatch = RegExp(r'\[US\]\s*([^\[\]]+)').firstMatch(bodyText);
    if (usMatch != null) {
      return usMatch.group(1)?.trim();
    }

    // Pattern: /fəˈnɛtɪk/ (IPA notation)
    final ipaMatch = RegExp(r'/([^/]+)/').firstMatch(bodyText);
    if (ipaMatch != null) {
      return ipaMatch.group(1)?.trim();
    }

    return null;
  }

  /// Extracts translations organized by part of speech.
  static List<Map<String, String>>? _extractTranslationsByPos(Document document) {
    final result = <Map<String, String>>[];

    // Look for list items that contain POS + translation
    final liTags = document.querySelectorAll('li');
    for (final li in liTags) {
      final text = li.text.trim();
      if (text.isEmpty || text.length > 500) continue;

      String? pos;
      String translation = text;

      // Extract POS if present
      final posMatch = RegExp(r'^(n\.|v\.|adj\.|adv\.|pron\.|prep\.|conj\.|num\.)[\s\-]*(.*)', caseSensitive: false).firstMatch(text);
      if (posMatch != null) {
        pos = posMatch.group(1)?.trim();
        translation = posMatch.group(2)?.trim() ?? text;
      }

      // Look for colon-separated format: word: translation
      if (translation.contains(':')) {
        final parts = translation.split(':');
        if (parts.length >= 2) {
          translation = parts.sublist(1).join(':').trim();
        }
      }

      if (translation.isNotEmpty) {
        result.add({
          'name': pos ?? '',
          'value': translation,
        });
      }

      // Limit results
      if (result.length >= 20) break;
    }

    return result.isNotEmpty ? result : null;
  }

  /// Extracts word forms (plural, past tense, comparative, etc.).
  static List<Map<String, String>>? _extractWordForms(Document document) {
    final result = <Map<String, String>>[];

    // Look for patterns like "plural: xxx", "past tense: xxx"
    final bodyText = document.body?.text ?? '';
    final formPatterns = [
      (RegExp(r'([Pp]lural)[:\s]+([^\n]+)'), 'plural'),
      (RegExp(r'([Pp]ast\s+tense)[:\s]+([^\n]+)'), 'past'),
      (RegExp(r'([Pp]ast\s+participle)[:\s]+([^\n]+)'), 'past participle'),
      (RegExp(r'([Pp]resent\s+participle)[:\s]+([^\n]+)'), 'present participle'),
      (RegExp(r'([Tt]hird\s+person)[:\s]+([^\n]+)'), 'third person'),
      (RegExp(r'([Cc]omparative)[:\s]+([^\n]+)'), 'comparative'),
      (RegExp(r'([Ss]uperlative)[:\s]+([^\n]+)'), 'superlative'),
    ];

    for (final (pattern, label) in formPatterns) {
      final match = pattern.firstMatch(bodyText);
      if (match != null) {
        final value = match.group(2)?.trim();
        if (value != null && value.isNotEmpty) {
          result.add({'name': label, 'value': value});
        }
      }
    }

    return result.isNotEmpty ? result : null;
  }

  /// Extracts phrases and collocations.
  static List<Map<String, String>>? _extractPhrases(Document document) {
    final result = <Map<String, String>>[];

    // Look for phrase sections
    final headings = document.querySelectorAll('[class*="phrase"], [class*="idiom"], h3, h4');
    for (final heading in headings) {
      final headingText = heading.text.trim().toLowerCase();
      if (headingText.contains('phrase') || headingText.contains('idiom') || headingText.contains('collocation')) {
        // Get following siblings
        Element? sibling = heading.nextElementSibling;
        int count = 0;
        while (sibling != null && count < 10) {
          final text = sibling.text.trim();
          if (text.isNotEmpty && text.length < 200) {
            // Check for phrase pattern: "phrase: meaning" or bullet points
            if (text.contains(':') || text.contains('-') || text.contains(RegExp(r'^\s*[\•\-\*]'))) {
              result.add({'name': '', 'value': text.replaceFirst(RegExp(r'^\s*[\•\-\*]\s*'), '')});
              if (result.length >= 10) break;
            }
          }
          sibling = sibling.nextElementSibling;
          count++;
        }
      }
    }

    return result.isNotEmpty ? result : null;
  }
}
