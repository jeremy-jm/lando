import 'package:lando/services/translation/youdao/models/youdao_ec.dart';
import 'package:lando/services/translation/youdao/models/youdao_ee.dart';
import 'package:lando/services/translation/youdao/models/youdao_meta.dart';
import 'package:lando/services/translation/youdao/models/youdao_other_models.dart';
import 'package:lando/services/translation/youdao/models/youdao_phrs.dart';
import 'package:lando/services/translation/youdao/models/youdao_simple.dart';
import 'package:lando/services/translation/youdao/models/youdao_web_trans.dart';

/// Main response model for Youdao API.
class YoudaoResponse {
  YoudaoResponse({
    this.webTrans,
    this.oxfordAdvanceHtml,
    this.picDict,
    this.oxfordAdvanceTen,
    this.simple,
    this.phrs,
    this.oxford,
    this.syno,
    this.collins,
    this.wordVideo,
    this.webster,
    this.wikipediaDigest,
    this.lang,
    this.ec,
    this.ee,
    this.blngSentsPart,
    this.individual,
    this.collinsPrimary,
    this.authSentsPart,
    this.magicWords,
    this.mediaSentsPart,
    this.etym,
    this.special,
    this.senior,
    this.input,
    this.meta,
    this.le,
    this.oxfordAdvance,
  });

  factory YoudaoResponse.fromJson(Map<String, dynamic> json) {
    return YoudaoResponse(
      webTrans: json['web_trans'] != null
          ? YoudaoWebTrans.fromJson(json['web_trans'] as Map<String, dynamic>)
          : null,
      oxfordAdvanceHtml: json['oxfordAdvanceHtml'] != null
          ? YoudaoEncryptedData.fromJson(
              json['oxfordAdvanceHtml'] as Map<String, dynamic>,
            )
          : null,
      picDict: json['pic_dict'] != null
          ? YoudaoPicDict.fromJson(json['pic_dict'] as Map<String, dynamic>)
          : null,
      oxfordAdvanceTen: json['oxfordAdvanceTen'] != null
          ? YoudaoEncryptedData.fromJson(
              json['oxfordAdvanceTen'] as Map<String, dynamic>,
            )
          : null,
      simple: json['simple'] != null
          ? YoudaoSimple.fromJson(json['simple'] as Map<String, dynamic>)
          : null,
      phrs: json['phrs'] != null
          ? YoudaoPhrs.fromJson(json['phrs'] as Map<String, dynamic>)
          : null,
      oxford: json['oxford'] != null
          ? YoudaoEncryptedData.fromJson(json['oxford'] as Map<String, dynamic>)
          : null,
      syno: json['syno'] != null
          ? YoudaoSyno.fromJson(json['syno'] as Map<String, dynamic>)
          : null,
      collins: json['collins'] != null
          ? YoudaoCollins.fromJson(json['collins'] as Map<String, dynamic>)
          : null,
      wordVideo: json['word_video'] != null
          ? YoudaoWordVideo.fromJson(json['word_video'] as Map<String, dynamic>)
          : null,
      webster: json['webster'] != null
          ? YoudaoEncryptedData.fromJson(
              json['webster'] as Map<String, dynamic>,
            )
          : null,
      wikipediaDigest: json['wikipedia_digest'] != null
          ? YoudaoWikipediaDigest.fromJson(
              json['wikipedia_digest'] as Map<String, dynamic>,
            )
          : null,
      lang: json['lang'] as String?,
      ec: json['ec'] != null
          ? YoudaoEc.fromJson(json['ec'] as Map<String, dynamic>)
          : null,
      ee: json['ee'] != null
          ? YoudaoEe.fromJson(json['ee'] as Map<String, dynamic>)
          : null,
      blngSentsPart: json['blng_sents_part'] != null
          ? YoudaoBlngSentsPart.fromJson(
              json['blng_sents_part'] as Map<String, dynamic>,
            )
          : null,
      individual: json['individual'] != null
          ? YoudaoIndividual.fromJson(
              json['individual'] as Map<String, dynamic>,
            )
          : null,
      collinsPrimary: json['collins_primary'] != null
          ? YoudaoCollinsPrimary.fromJson(
              json['collins_primary'] as Map<String, dynamic>,
            )
          : null,
      authSentsPart: json['auth_sents_part'] != null
          ? YoudaoAuthSentsPart.fromJson(
              json['auth_sents_part'] as Map<String, dynamic>,
            )
          : null,
      magicWords: json['magic_words'] != null
          ? YoudaoMagicWords.fromJson(
              json['magic_words'] as Map<String, dynamic>,
            )
          : null,
      mediaSentsPart: json['media_sents_part'] != null
          ? YoudaoMediaSentsPart.fromJson(
              json['media_sents_part'] as Map<String, dynamic>,
            )
          : null,
      etym: json['etym'] != null
          ? YoudaoEtym.fromJson(json['etym'] as Map<String, dynamic>)
          : null,
      special: json['special'] != null
          ? YoudaoSpecial.fromJson(json['special'] as Map<String, dynamic>)
          : null,
      senior: json['senior'] != null
          ? YoudaoEncryptedData.fromJson(json['senior'] as Map<String, dynamic>)
          : null,
      input: json['input'] as String?,
      meta: json['meta'] != null
          ? YoudaoMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      le: json['le'] as String?,
      oxfordAdvance: json['oxfordAdvance'] != null
          ? YoudaoEncryptedData.fromJson(
              json['oxfordAdvance'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final YoudaoWebTrans? webTrans;
  final YoudaoEncryptedData? oxfordAdvanceHtml;
  final YoudaoPicDict? picDict;
  final YoudaoEncryptedData? oxfordAdvanceTen;
  final YoudaoSimple? simple;
  final YoudaoPhrs? phrs;
  final YoudaoEncryptedData? oxford;
  final YoudaoSyno? syno;
  final YoudaoCollins? collins;
  final YoudaoWordVideo? wordVideo;
  final YoudaoEncryptedData? webster;
  final YoudaoWikipediaDigest? wikipediaDigest;
  final String? lang;
  final YoudaoEc? ec;
  final YoudaoEe? ee;
  final YoudaoBlngSentsPart? blngSentsPart;
  final YoudaoIndividual? individual;
  final YoudaoCollinsPrimary? collinsPrimary;
  final YoudaoAuthSentsPart? authSentsPart;
  final YoudaoMagicWords? magicWords;
  final YoudaoMediaSentsPart? mediaSentsPart;
  final YoudaoEtym? etym;
  final YoudaoSpecial? special;
  final YoudaoEncryptedData? senior;
  final String? input;
  final YoudaoMeta? meta;
  final String? le;
  final YoudaoEncryptedData? oxfordAdvance;
}

/// Encrypted data model (used for various encrypted fields).
class YoudaoEncryptedData {
  YoudaoEncryptedData({required this.encryptedData});

  factory YoudaoEncryptedData.fromJson(Map<String, dynamic> json) {
    return YoudaoEncryptedData(encryptedData: json['encryptedData'] as String);
  }

  final String encryptedData;
}
