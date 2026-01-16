/// Youdao Meta model.
class YoudaoMeta {
  YoudaoMeta({
    this.input,
    this.guessLanguage,
    this.isHasSimpleDict,
    this.le,
    this.lang,
    this.dicts,
  });

  factory YoudaoMeta.fromJson(Map<String, dynamic> json) {
    return YoudaoMeta(
      input: json['input'] as String?,
      guessLanguage: json['guessLanguage'] as String?,
      isHasSimpleDict: json['isHasSimpleDict'] as String?,
      le: json['le'] as String?,
      lang: json['lang'] as String?,
      dicts: json['dicts'] != null
          ? (json['dicts'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  final String? input;
  final String? guessLanguage;
  final String? isHasSimpleDict;
  final String? le;
  final String? lang;
  final List<String>? dicts;
}
