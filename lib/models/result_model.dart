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
