class Source {
  final String name;
  final String icon;

  Source({required this.name, required this.icon});
}

class ResultModel {
  final String query;
  final String? simpleExplanation;

  final List<Map<String, String>>? translationsByPos;

  final String? usPronunciationUrl;
  final String? ukPronunciationUrl;
  final String? usPhonetic;
  final String? ukPhonetic;

  final List<String>? examTypes;

  final List<Map<String, String>>? wordForm;

  final List<Map<String, String>>? phrases;

  final List<Map<String, String>>? webTranslations;

  ResultModel({
    required this.query,
    this.simpleExplanation,
    this.translationsByPos,
    this.usPronunciationUrl,
    this.ukPronunciationUrl,
    this.usPhonetic,
    this.ukPhonetic,
    this.examTypes,
    this.wordForm,
    this.phrases,
    this.webTranslations,
  });
}

/// Meaning text used when saving this result to favorites.
extension ResultModelFavoriteMeaning on ResultModel {
  String favoriteMeaning() {
    if (simpleExplanation != null && simpleExplanation!.trim().isNotEmpty) {
      return simpleExplanation!.trim();
    }
    if (translationsByPos != null && translationsByPos!.isNotEmpty) {
      final meanings = translationsByPos!
          .map((t) => '${t['name'] ?? ''} ${t['value'] ?? ''}')
          .where((s) => s.trim().isNotEmpty)
          .join('; ');
      if (meanings.isNotEmpty) return meanings;
    }
    if (webTranslations != null && webTranslations!.isNotEmpty) {
      final meanings = webTranslations!
          .map((t) => '${t['key'] ?? ''} ${t['value'] ?? ''}')
          .where((s) => s.trim().isNotEmpty)
          .join('; ');
      if (meanings.isNotEmpty) return meanings;
    }
    return '';
  }
}
