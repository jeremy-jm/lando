import 'package:lando/services/translation/youdao/models/youdao_ec.dart';

/// Youdao EE (extended dictionary) model.
class YoudaoEe {
  YoudaoEe({this.source, this.word});

  factory YoudaoEe.fromJson(Map<String, dynamic> json) {
    return YoudaoEe(
      source: json['source'] != null
          ? YoudaoSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      word: json['word'] != null
          ? YoudaoEeWord.fromJson(json['word'] as Map<String, dynamic>)
          : null,
    );
  }

  final YoudaoSource? source;
  final YoudaoEeWord? word;
}

/// EE Word model.
class YoudaoEeWord {
  YoudaoEeWord({this.trs, this.phone, this.speech, this.returnPhrase});

  factory YoudaoEeWord.fromJson(Map<String, dynamic> json) {
    return YoudaoEeWord(
      trs: json['trs'] != null
          ? (json['trs'] as List)
                .map((e) => YoudaoEeWordTr.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      phone: json['phone'] as String?,
      speech: json['speech'] as String?,
      returnPhrase: json['return-phrase'] as String?,
    );
  }

  final List<YoudaoEeWordTr>? trs;
  final String? phone;
  final String? speech;
  final String? returnPhrase;
}

/// EE Word Translation model.
class YoudaoEeWordTr {
  YoudaoEeWordTr({this.pos, this.tr});

  factory YoudaoEeWordTr.fromJson(Map<String, dynamic> json) {
    return YoudaoEeWordTr(
      pos: json['pos'] as String?,
      tr: json['tr'] != null
          ? (json['tr'] as List)
                .map(
                  (e) => YoudaoEeWordTrItem.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  final String? pos;
  final List<YoudaoEeWordTrItem>? tr;
}

/// EE Word Translation Item model.
class YoudaoEeWordTrItem {
  YoudaoEeWordTrItem({this.tran, this.similarWords, this.examples});

  factory YoudaoEeWordTrItem.fromJson(Map<String, dynamic> json) {
    return YoudaoEeWordTrItem(
      tran: json['tran'] as String?,
      similarWords: json['similar-words'] != null
          ? (json['similar-words'] as List).map((e) => e.toString()).toList()
          : null,
      examples: json['examples'] != null
          ? (json['examples'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  final String? tran;
  final List<String>? similarWords;
  final List<String>? examples;
}
