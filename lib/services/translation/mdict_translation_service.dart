import 'package:lando/models/result_model.dart';
import 'package:lando/services/mdict/mdict_html_parser.dart';
import 'package:lando/services/mdict/mdict_manager.dart';
import 'package:lando/services/translation/translation_service.dart';

/// MDict offline dictionary service.
///
/// Implements [TranslationService] for querying local .mdx dictionary files.
/// Falls back to online services when offline dictionary is unavailable or
/// returns no result.
class MdictTranslationService implements TranslationService {
  @override
  String get name => 'MDict';

  @override
  Future<String> translate(String query) async {
    if (query.trim().isEmpty) {
      return '';
    }

    if (!MdictManager.instance.isSupported) {
      throw Exception('MDict is not supported on this platform');
    }

    // Wait for dictionary initialization if still in progress
    final html = await MdictManager.instance.lookupAsync(query);
    if (html == null || html.isEmpty) {
      throw Exception('Word not found in offline dictionary: $query');
    }

    // Extract plain text from HTML for simple translation
    return _htmlToPlainText(html);
  }

  @override
  Future<ResultModel?> getDetailedResult(String query) async {
    if (query.trim().isEmpty) {
      return null;
    }

    if (!MdictManager.instance.isSupported) {
      return null;
    }

    // Wait for dictionary initialization if still in progress
    final html = await MdictManager.instance.lookupAsync(query);
    if (html == null || html.isEmpty) {
      return null;
    }

    return MdictHtmlParser.parse(html, query);
  }

  /// Converts HTML content to plain text.
  String _htmlToPlainText(String html) {
    // Simple HTML tag removal for display
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .trim();
  }
}
