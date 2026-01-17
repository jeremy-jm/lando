import 'package:lando/services/translation/youdao/models/youdao_simple_phonetic.dart';

/// Youdao Simple model (phonetic and basic info).
class YoudaoSimple {
  YoudaoSimple({this.query, this.word});

  factory YoudaoSimple.fromJson(Map<String, dynamic> json) {
    return YoudaoSimple(
      query: json['query'] as String?,
      word: json['word'] != null
          ? (json['word'] as List)
                .map(
                  (e) => YoudaoSimpleWord.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  final String? query;
  final List<YoudaoSimpleWord>? word;
}

/// Simple Word model.
class YoudaoSimpleWord {
  YoudaoSimpleWord({
    this.usphone,
    this.ukphone,
    this.ukspeech,
    this.returnPhrase,
    this.usspeech,
    this.collegeExamVoice,
    this.speech,
    this.multiPhone,
  });

  factory YoudaoSimpleWord.fromJson(Map<String, dynamic> json) {
    return YoudaoSimpleWord(
      usphone: json['usphone'] as String?,
      ukphone: json['ukphone'] as String?,
      ukspeech: json['ukspeech'] as String?,
      returnPhrase: json['return-phrase'] as String?,
      usspeech: json['usspeech'] as String?,
      collegeExamVoice: json['collegeExamVoice'] != null
          ? YoudaoCollegeExamVoice.fromJson(
              json['collegeExamVoice'] as Map<String, dynamic>,
            )
          : null,
      speech: json['speech'] as String?,
      multiPhone: json['multiPhone'] != null
          ? YoudaoMultiPhone.fromJson(
              json['multiPhone'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String? usphone;
  final String? ukphone;
  final String? ukspeech;
  final String? returnPhrase;
  final String? usspeech;
  final YoudaoCollegeExamVoice? collegeExamVoice;
  final String? speech;
  final YoudaoMultiPhone? multiPhone;
}

/// College Exam Voice model.
class YoudaoCollegeExamVoice {
  YoudaoCollegeExamVoice({this.speechWord});

  factory YoudaoCollegeExamVoice.fromJson(Map<String, dynamic> json) {
    return YoudaoCollegeExamVoice(speechWord: json['speechWord'] as String?);
  }

  final String? speechWord;
}
