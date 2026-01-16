import 'package:lando/services/translation/youdao/models/youdao_other_models.dart';

/// Youdao EC (basic dictionary) model.
class YoudaoEc {
  YoudaoEc({
    this.webTrans,
    this.special,
    this.examType,
    this.source,
    this.word,
  });

  factory YoudaoEc.fromJson(Map<String, dynamic> json) {
    return YoudaoEc(
      webTrans: json['web_trans'] != null
          ? (json['web_trans'] as List).map((e) => e.toString()).toList()
          : null,
      special: json['special'] != null
          ? (json['special'] as List)
                .map((e) => YoudaoEcSpecial.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      examType: json['exam_type'] != null
          ? (json['exam_type'] as List).map((e) => e.toString()).toList()
          : null,
      source: json['source'] != null
          ? YoudaoSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      // json['word'] maybe it's a List<dynamic> or Map<String, dynamic>, we need to handle both cases
      word: json['word'] != null
          ? (json['word'] is List
                ? (json['word'] as List).isNotEmpty
                      ? YoudaoEcWord.fromJson(
                          (json['word'] as List).first as Map<String, dynamic>,
                        )
                      : null
                : YoudaoEcWord.fromJson(json['word'] as Map<String, dynamic>))
          : null,
    );
  }

  final List<String>? webTrans;
  final List<YoudaoEcSpecial>? special;
  final List<String>? examType;
  final YoudaoSource? source;
  final YoudaoEcWord? word;
}

/// EC Special model.
class YoudaoEcSpecial {
  YoudaoEcSpecial({this.nat, this.major});

  factory YoudaoEcSpecial.fromJson(Map<String, dynamic> json) {
    return YoudaoEcSpecial(
      nat: json['nat'] as String?,
      major: json['major'] as String?,
    );
  }

  final String? nat;
  final String? major;
}

/// Source model.
class YoudaoSource {
  YoudaoSource({this.name, this.url});

  factory YoudaoSource.fromJson(Map<String, dynamic> json) {
    return YoudaoSource(
      name: json['name'] as String?,
      url: json['url'] as String?,
    );
  }

  final String? name;
  final String? url;
}

/// EC Word model (most important part for basic translation).
class YoudaoEcWord {
  YoudaoEcWord({
    this.usphone,
    this.ukphone,
    this.ukspeech,
    this.trs,
    this.returnPhrase,
    this.usspeech,
    this.prototype,
    this.wfs,
    this.speech,
  });

  factory YoudaoEcWord.fromJson(Map<String, dynamic> json) {
    return YoudaoEcWord(
      usphone: json['usphone'] as String?,
      ukphone: json['ukphone'] as String?,
      ukspeech: json['ukspeech'] as String?,
      trs: json['trs'] != null
          ? (json['trs'] as List)
                .map((e) => YoudaoEcWordTr.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      returnPhrase: json['return-phrase'] as String?,
      usspeech: json['usspeech'] as String?,
      prototype: json['prototype'] as String?,
      wfs: json['wfs'] != null
          ? (json['wfs'] as List<dynamic>)
                .map((e) => YoudaoWf.fromJson(e['wf'] as Map<String, dynamic>))
                .toList()
          : null,
      speech: json['speech'] as String?,
    );
  }

  final String? usphone;
  final String? ukphone;
  final String? ukspeech;
  final List<YoudaoEcWordTr>? trs;
  final String? returnPhrase;
  final String? usspeech;
  final String? prototype;
  final List<YoudaoWf>? wfs;
  final String? speech;
}

/// EC Word Translation model.
class YoudaoEcWordTr {
  YoudaoEcWordTr({this.pos, this.tran, this.sentence});

  factory YoudaoEcWordTr.fromJson(Map<String, dynamic> json) {
    return YoudaoEcWordTr(
      pos: json['pos'] as String?,
      tran: json['tran'] as String?,
      sentence: json['sentence'] != null
          ? (json['sentence'] as List)
                .map((e) => YoudaoEcSentence.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  final String? pos;
  final String? tran;
  final List<YoudaoEcSentence>? sentence;
}

/// EC Sentence model (example sentence in translation).
class YoudaoEcSentence {
  YoudaoEcSentence({
    this.enShow,
    this.en,
    this.type,
    this.zh,
  });

  factory YoudaoEcSentence.fromJson(Map<String, dynamic> json) {
    return YoudaoEcSentence(
      enShow: json['enShow'] as String?,
      en: json['en'] as String?,
      type: json['type'] as String?,
      zh: json['zh'] as String?,
    );
  }

  final String? enShow;
  final String? en;
  final String? type;
  final String? zh;
}
