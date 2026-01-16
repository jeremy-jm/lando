class Source {
  final String name;
  final String icon;

  Source({required this.name, required this.icon});
}

class ResultModel {
  final String query;
  final String? simpleExplanation;

  final String? usPronunciationUrl;
  final String? ukPronunciationUrl;

  final List<String>? examTypes;

  final List<Map<String, String>>? wordForm;

  final List<Map<String, String>>? phrases;

  final List<Map<String, String>>? webTranslations;

  ResultModel({
    required this.query,
    this.simpleExplanation,
    this.usPronunciationUrl,
    this.ukPronunciationUrl,
    this.examTypes,
    this.wordForm,
    this.phrases,
    this.webTranslations,
  });
}
