import 'package:lando/services/translation/youdao/models/youdao_ec.dart';

/// Youdao CE (Chinese-English) model.
class YoudaoCe {
  YoudaoCe({this.source, this.word});

  factory YoudaoCe.fromJson(Map<String, dynamic> json) {
    return YoudaoCe(
      source: json['source'] != null
          ? YoudaoSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      word: json['word'] != null
          ? YoudaoCeWord.fromJson(json['word'] as Map<String, dynamic>)
          : null,
    );
  }

  final YoudaoSource? source;
  final YoudaoCeWord? word;
}

/// CE Word model.
class YoudaoCeWord {
  YoudaoCeWord({this.trs, this.returnPhrase});

  factory YoudaoCeWord.fromJson(Map<String, dynamic> json) {
    return YoudaoCeWord(
      trs: json['trs'] != null
          ? (json['trs'] as List)
                .map((e) => YoudaoCeWordTr.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      returnPhrase: json['return-phrase'] as String?,
    );
  }

  final List<YoudaoCeWordTr>? trs;
  final String? returnPhrase;
}

/// CE Word Translation model.
class YoudaoCeWordTr {
  YoudaoCeWordTr({this.voice, this.text});

  factory YoudaoCeWordTr.fromJson(Map<String, dynamic> json) {
    return YoudaoCeWordTr(
      voice: json['voice'] as String?,
      // JSON uses '#text' as the key
      text: json['#text'] as String?,
    );
  }

  final String? voice;
  final String? text;
}
