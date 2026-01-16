/// Youdao Phrases model.
class YoudaoPhrs {
  YoudaoPhrs({this.word, this.phrs});

  factory YoudaoPhrs.fromJson(Map<String, dynamic> json) {
    return YoudaoPhrs(
      word: json['word'] as String?,
      phrs: json['phrs'] != null
          ? (json['phrs'] as List)
                .map((e) => YoudaoPhr.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  final String? word;
  final List<YoudaoPhr>? phrs;
}

/// Phrase model.
class YoudaoPhr {
  YoudaoPhr({this.headword, this.translation});

  factory YoudaoPhr.fromJson(Map<String, dynamic> json) {
    return YoudaoPhr(
      headword: json['headword'] as String?,
      translation: json['translation'] as String?,
    );
  }

  final String? headword;
  final String? translation;
}
