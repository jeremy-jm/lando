import 'package:lando/services/translation/youdao/models/youdao_ec.dart';

/// Placeholder models for other Youdao response sections.
/// These can be expanded as needed.

/// Pic Dict model.
class YoudaoPicDict {
  YoudaoPicDict({this.pic});

  factory YoudaoPicDict.fromJson(Map<String, dynamic> json) {
    return YoudaoPicDict(
      pic: json['pic'] != null
          ? (json['pic'] as List)
              .map((e) => YoudaoPic.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoPic>? pic;
}

/// Pic model.
class YoudaoPic {
  YoudaoPic({
    this.image,
    this.host,
    this.url,
  });

  factory YoudaoPic.fromJson(Map<String, dynamic> json) {
    return YoudaoPic(
      image: json['image'] as String?,
      host: json['host'] as String?,
      url: json['url'] as String?,
    );
  }

  final String? image;
  final String? host;
  final String? url;
}

/// Syno model.
class YoudaoSyno {
  YoudaoSyno({
    this.synos,
    this.word,
  });

  factory YoudaoSyno.fromJson(Map<String, dynamic> json) {
    return YoudaoSyno(
      synos: json['synos'] != null
          ? (json['synos'] as List)
              .map((e) => YoudaoSynoItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      word: json['word'] as String?,
    );
  }

  final List<YoudaoSynoItem>? synos;
  final String? word;
}

/// Syno Item model.
class YoudaoSynoItem {
  YoudaoSynoItem({
    this.pos,
    this.ws,
    this.tran,
  });

  factory YoudaoSynoItem.fromJson(Map<String, dynamic> json) {
    return YoudaoSynoItem(
      pos: json['pos'] as String?,
      ws: json['ws'] != null
          ? (json['ws'] as List).map((e) => e.toString()).toList()
          : null,
      tran: json['tran'] as String?,
    );
  }

  final String? pos;
  final List<String>? ws;
  final String? tran;
}

/// Collins model.
class YoudaoCollins {
  YoudaoCollins({this.collinsEntries});

  factory YoudaoCollins.fromJson(Map<String, dynamic> json) {
    return YoudaoCollins(
      collinsEntries: json['collins_entries'] != null
          ? (json['collins_entries'] as List)
              .map((e) =>
                  YoudaoCollinsEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoCollinsEntry>? collinsEntries;
}

/// Collins Entry model.
class YoudaoCollinsEntry {
  YoudaoCollinsEntry({
    this.entries,
    this.phonetic,
    this.basicEntries,
    this.headword,
    this.star,
  });

  factory YoudaoCollinsEntry.fromJson(Map<String, dynamic> json) {
    return YoudaoCollinsEntry(
      entries: json['entries'] != null
          ? YoudaoCollinsEntries.fromJson(
              json['entries'] as Map<String, dynamic>)
          : null,
      phonetic: json['phonetic'] as String?,
      basicEntries: json['basic_entries'] != null
          ? YoudaoBasicEntries.fromJson(
              json['basic_entries'] as Map<String, dynamic>)
          : null,
      headword: json['headword'] as String?,
      star: json['star'] as String?,
    );
  }

  final YoudaoCollinsEntries? entries;
  final String? phonetic;
  final YoudaoBasicEntries? basicEntries;
  final String? headword;
  final String? star;
}

/// Collins Entries model.
class YoudaoCollinsEntries {
  YoudaoCollinsEntries({this.entry});

  factory YoudaoCollinsEntries.fromJson(Map<String, dynamic> json) {
    return YoudaoCollinsEntries(
      entry: json['entry'] != null
          ? (json['entry'] as List)
              .map((e) => YoudaoCollinsEntryItem.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoCollinsEntryItem>? entry;
}

/// Collins Entry Item model.
class YoudaoCollinsEntryItem {
  YoudaoCollinsEntryItem({this.tranEntry});

  factory YoudaoCollinsEntryItem.fromJson(Map<String, dynamic> json) {
    return YoudaoCollinsEntryItem(
      tranEntry: json['tran_entry'] != null
          ? (json['tran_entry'] as List)
              .map((e) => YoudaoCollinsTranEntry.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoCollinsTranEntry>? tranEntry;
}

/// Collins Translation Entry model.
class YoudaoCollinsTranEntry {
  YoudaoCollinsTranEntry({
    this.posEntry,
    this.examSents,
    this.tran,
  });

  factory YoudaoCollinsTranEntry.fromJson(Map<String, dynamic> json) {
    return YoudaoCollinsTranEntry(
      posEntry: json['pos_entry'] != null
          ? YoudaoPosEntry.fromJson(json['pos_entry'] as Map<String, dynamic>)
          : null,
      examSents: json['exam_sents'] != null
          ? YoudaoExamSents.fromJson(
              json['exam_sents'] as Map<String, dynamic>)
          : null,
      tran: json['tran'] as String?,
    );
  }

  final YoudaoPosEntry? posEntry;
  final YoudaoExamSents? examSents;
  final String? tran;
}

/// Pos Entry model.
class YoudaoPosEntry {
  YoudaoPosEntry({
    this.pos,
    this.posTips,
  });

  factory YoudaoPosEntry.fromJson(Map<String, dynamic> json) {
    return YoudaoPosEntry(
      pos: json['pos'] as String?,
      posTips: json['pos_tips'] as String?,
    );
  }

  final String? pos;
  final String? posTips;
}

/// Exam Sentences model.
class YoudaoExamSents {
  YoudaoExamSents({this.sent});

  factory YoudaoExamSents.fromJson(Map<String, dynamic> json) {
    return YoudaoExamSents(
      sent: json['sent'] != null
          ? (json['sent'] as List)
              .map((e) => YoudaoExamSent.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoExamSent>? sent;
}

/// Exam Sentence model.
class YoudaoExamSent {
  YoudaoExamSent({
    this.chnSent,
    this.engSent,
  });

  factory YoudaoExamSent.fromJson(Map<String, dynamic> json) {
    return YoudaoExamSent(
      chnSent: json['chn_sent'] as String?,
      engSent: json['eng_sent'] as String?,
    );
  }

  final String? chnSent;
  final String? engSent;
}

/// Basic Entries model.
class YoudaoBasicEntries {
  YoudaoBasicEntries({this.basicEntry});

  factory YoudaoBasicEntries.fromJson(Map<String, dynamic> json) {
    return YoudaoBasicEntries(
      basicEntry: json['basic_entry'] != null
          ? (json['basic_entry'] as List)
              .map((e) => YoudaoBasicEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoBasicEntry>? basicEntry;
}

/// Basic Entry model.
class YoudaoBasicEntry {
  YoudaoBasicEntry({
    this.cet,
    this.headword,
  });

  factory YoudaoBasicEntry.fromJson(Map<String, dynamic> json) {
    return YoudaoBasicEntry(
      cet: json['cet'] as String?,
      headword: json['headword'] as String?,
    );
  }

  final String? cet;
  final String? headword;
}

/// Word Video model.
class YoudaoWordVideo {
  YoudaoWordVideo({this.wordVideos});

  factory YoudaoWordVideo.fromJson(Map<String, dynamic> json) {
    return YoudaoWordVideo(
      wordVideos: json['word_videos'] != null
          ? (json['word_videos'] as List)
              .map((e) => YoudaoWordVideoItem.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoWordVideoItem>? wordVideos;
}

/// Word Video Item model.
class YoudaoWordVideoItem {
  YoudaoWordVideoItem({
    this.ad,
    this.video,
  });

  factory YoudaoWordVideoItem.fromJson(Map<String, dynamic> json) {
    return YoudaoWordVideoItem(
      ad: json['ad'] != null
          ? YoudaoAd.fromJson(json['ad'] as Map<String, dynamic>)
          : null,
      video: json['video'] != null
          ? YoudaoVideo.fromJson(json['video'] as Map<String, dynamic>)
          : null,
    );
  }

  final YoudaoAd? ad;
  final YoudaoVideo? video;
}

/// Ad model.
class YoudaoAd {
  YoudaoAd({
    this.avatar,
    this.title,
    this.url,
  });

  factory YoudaoAd.fromJson(Map<String, dynamic> json) {
    return YoudaoAd(
      avatar: json['avatar'] as String?,
      title: json['title'] as String?,
      url: json['url'] as String?,
    );
  }

  final String? avatar;
  final String? title;
  final String? url;
}

/// Video model.
class YoudaoVideo {
  YoudaoVideo({
    this.cover,
    this.image,
    this.title,
    this.url,
  });

  factory YoudaoVideo.fromJson(Map<String, dynamic> json) {
    return YoudaoVideo(
      cover: json['cover'] as String?,
      image: json['image'] as String?,
      title: json['title'] as String?,
      url: json['url'] as String?,
    );
  }

  final String? cover;
  final String? image;
  final String? title;
  final String? url;
}

/// Wikipedia Digest model.
class YoudaoWikipediaDigest {
  YoudaoWikipediaDigest({
    this.summarys,
    this.source,
  });

  factory YoudaoWikipediaDigest.fromJson(Map<String, dynamic> json) {
    return YoudaoWikipediaDigest(
      summarys: json['summarys'] != null
          ? (json['summarys'] as List)
              .map((e) => YoudaoWikipediaSummary.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      source: json['source'] != null
          ? YoudaoSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
    );
  }

  final List<YoudaoWikipediaSummary>? summarys;
  final YoudaoSource? source;
}

/// Wikipedia Summary model.
class YoudaoWikipediaSummary {
  YoudaoWikipediaSummary({
    this.summary,
    this.key,
  });

  factory YoudaoWikipediaSummary.fromJson(Map<String, dynamic> json) {
    return YoudaoWikipediaSummary(
      summary: json['summary'] as String?,
      key: json['key'] as String?,
    );
  }

  final String? summary;
  final String? key;
}

/// Blng Sents Part model (bilingual sentences).
class YoudaoBlngSentsPart {
  YoudaoBlngSentsPart({
    this.sentenceCount,
    this.sentencePair,
    this.more,
    this.trsClassify,
  });

  factory YoudaoBlngSentsPart.fromJson(Map<String, dynamic> json) {
    return YoudaoBlngSentsPart(
      sentenceCount: json['sentence-count'] as int?,
      sentencePair: json['sentence-pair'] != null
          ? (json['sentence-pair'] as List)
              .map((e) => YoudaoSentencePair.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      more: json['more'] as String?,
      trsClassify: json['trs-classify'] != null
          ? (json['trs-classify'] as List)
              .map((e) => YoudaoTrsClassify.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final int? sentenceCount;
  final List<YoudaoSentencePair>? sentencePair;
  final String? more;
  final List<YoudaoTrsClassify>? trsClassify;
}

/// Sentence Pair model.
class YoudaoSentencePair {
  YoudaoSentencePair({
    this.sentence,
    this.sentenceEng,
    this.sentenceTranslation,
    this.speechSize,
    this.alignedWords,
    this.source,
    this.url,
    this.sentenceSpeech,
  });

  factory YoudaoSentencePair.fromJson(Map<String, dynamic> json) {
    return YoudaoSentencePair(
      sentence: json['sentence'] as String?,
      sentenceEng: json['sentence-eng'] as String?,
      sentenceTranslation: json['sentence-translation'] as String?,
      speechSize: json['speech-size'] as String?,
      alignedWords: json['aligned-words'] != null
          ? YoudaoAlignedWords.fromJson(
              json['aligned-words'] as Map<String, dynamic>)
          : null,
      source: json['source'] as String?,
      url: json['url'] as String?,
      sentenceSpeech: json['sentence-speech'] as String?,
    );
  }

  final String? sentence;
  final String? sentenceEng;
  final String? sentenceTranslation;
  final String? speechSize;
  final YoudaoAlignedWords? alignedWords;
  final String? source;
  final String? url;
  final String? sentenceSpeech;
}

/// Aligned Words model (simplified, can be expanded if needed).
class YoudaoAlignedWords {
  YoudaoAlignedWords({
    this.src,
    this.tran,
  });

  factory YoudaoAlignedWords.fromJson(Map<String, dynamic> json) {
    return YoudaoAlignedWords(
      src: json['src'] != null
          ? YoudaoAlignedChars.fromJson(json['src'] as Map<String, dynamic>)
          : null,
      tran: json['tran'] != null
          ? YoudaoAlignedChars.fromJson(json['tran'] as Map<String, dynamic>)
          : null,
    );
  }

  final YoudaoAlignedChars? src;
  final YoudaoAlignedChars? tran;
}

/// Aligned Chars model (simplified).
class YoudaoAlignedChars {
  YoudaoAlignedChars({this.chars});

  factory YoudaoAlignedChars.fromJson(Map<String, dynamic> json) {
    return YoudaoAlignedChars(
      chars: json['chars'] != null
          ? (json['chars'] as List).map((e) => e as Map<String, dynamic>).toList()
          : null,
    );
  }

  final List<Map<String, dynamic>>? chars;
}

/// Trs Classify model.
class YoudaoTrsClassify {
  YoudaoTrsClassify({
    this.proportion,
    this.tr,
  });

  factory YoudaoTrsClassify.fromJson(Map<String, dynamic> json) {
    return YoudaoTrsClassify(
      proportion: json['proportion'] as String?,
      tr: json['tr'] as String?,
    );
  }

  final String? proportion;
  final String? tr;
}

/// Individual model.
class YoudaoIndividual {
  YoudaoIndividual({
    this.sayings,
    this.anagram,
    this.idiomatic,
    this.trs,
    this.level,
    this.examInfo,
    this.returnPhrase,
    this.pastExamSents,
  });

  factory YoudaoIndividual.fromJson(Map<String, dynamic> json) {
    return YoudaoIndividual(
      sayings: json['sayings'] != null
          ? (json['sayings'] as List)
              .map((e) => YoudaoSaying.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      anagram: json['anagram'] != null
          ? YoudaoAnagram.fromJson(json['anagram'] as Map<String, dynamic>)
          : null,
      idiomatic: json['idiomatic'] != null
          ? (json['idiomatic'] as List)
              .map((e) => YoudaoIdiomatic.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      trs: json['trs'] != null
          ? (json['trs'] as List)
              .map((e) => YoudaoIndividualTr.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      level: json['level'] as String?,
      examInfo: json['examInfo'] != null
          ? YoudaoExamInfo.fromJson(json['examInfo'] as Map<String, dynamic>)
          : null,
      returnPhrase: json['return-phrase'] as String?,
      pastExamSents: json['pastExamSents'] != null
          ? (json['pastExamSents'] as List)
              .map((e) => YoudaoPastExamSent.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoSaying>? sayings;
  final YoudaoAnagram? anagram;
  final List<YoudaoIdiomatic>? idiomatic;
  final List<YoudaoIndividualTr>? trs;
  final String? level;
  final YoudaoExamInfo? examInfo;
  final String? returnPhrase;
  final List<YoudaoPastExamSent>? pastExamSents;
}

/// Saying model.
class YoudaoSaying {
  YoudaoSaying({
    this.en,
    this.zh,
  });

  factory YoudaoSaying.fromJson(Map<String, dynamic> json) {
    return YoudaoSaying(
      en: json['en'] as String?,
      zh: json['zh'] as String?,
    );
  }

  final String? en;
  final String? zh;
}

/// Anagram model.
class YoudaoAnagram {
  YoudaoAnagram({
    this.wfs,
    this.word,
  });

  factory YoudaoAnagram.fromJson(Map<String, dynamic> json) {
    return YoudaoAnagram(
      wfs: json['wfs'] != null
          ? (json['wfs'] as List)
              .map((e) => YoudaoWf.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      word: json['word'] as String?,
    );
  }

  final List<YoudaoWf>? wfs;
  final String? word;
}

/// Word Form model.
class YoudaoWf {
  YoudaoWf({
    this.name,
    this.value,
  });

  factory YoudaoWf.fromJson(Map<String, dynamic> json) {
    return YoudaoWf(
      name: json['name'] as String?,
      value: json['value'] as String?,
    );
  }

  final String? name;
  final String? value;
}

/// Idiomatic model.
class YoudaoIdiomatic {
  YoudaoIdiomatic({this.colloc});

  factory YoudaoIdiomatic.fromJson(Map<String, dynamic> json) {
    return YoudaoIdiomatic(
      colloc: json['colloc'] != null
          ? YoudaoColloc.fromJson(json['colloc'] as Map<String, dynamic>)
          : null,
    );
  }

  final YoudaoColloc? colloc;
}

/// Collocation model.
class YoudaoColloc {
  YoudaoColloc({
    this.en,
    this.zh,
  });

  factory YoudaoColloc.fromJson(Map<String, dynamic> json) {
    return YoudaoColloc(
      en: json['en'] as String?,
      zh: json['zh'] as String?,
    );
  }

  final String? en;
  final String? zh;
}

/// Individual Translation model.
class YoudaoIndividualTr {
  YoudaoIndividualTr({
    this.pos,
    this.tran,
  });

  factory YoudaoIndividualTr.fromJson(Map<String, dynamic> json) {
    return YoudaoIndividualTr(
      pos: json['pos'] as String?,
      tran: json['tran'] as String?,
    );
  }

  final String? pos;
  final String? tran;
}

/// Exam Info model.
class YoudaoExamInfo {
  YoudaoExamInfo({
    this.year,
    this.questionTypeInfo,
    this.recommendationRate,
    this.frequency,
  });

  factory YoudaoExamInfo.fromJson(Map<String, dynamic> json) {
    return YoudaoExamInfo(
      year: json['year'] as int?,
      questionTypeInfo: json['questionTypeInfo'] != null
          ? (json['questionTypeInfo'] as List)
              .map((e) => YoudaoQuestionTypeInfo.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      recommendationRate: json['recommendationRate'] as int?,
      frequency: json['frequency'] as int?,
    );
  }

  final int? year;
  final List<YoudaoQuestionTypeInfo>? questionTypeInfo;
  final int? recommendationRate;
  final int? frequency;
}

/// Question Type Info model.
class YoudaoQuestionTypeInfo {
  YoudaoQuestionTypeInfo({
    this.time,
    this.type,
  });

  factory YoudaoQuestionTypeInfo.fromJson(Map<String, dynamic> json) {
    return YoudaoQuestionTypeInfo(
      time: json['time'] as int?,
      type: json['type'] as String?,
    );
  }

  final int? time;
  final String? type;
}

/// Past Exam Sentence model.
class YoudaoPastExamSent {
  YoudaoPastExamSent({
    this.en,
    this.source,
    this.zh,
  });

  factory YoudaoPastExamSent.fromJson(Map<String, dynamic> json) {
    return YoudaoPastExamSent(
      en: json['en'] as String?,
      source: json['source'] as String?,
      zh: json['zh'] as String?,
    );
  }

  final String? en;
  final String? source;
  final String? zh;
}

/// Collins Primary model.
class YoudaoCollinsPrimary {
  YoudaoCollinsPrimary({
    this.words,
    this.gramcat,
  });

  factory YoudaoCollinsPrimary.fromJson(Map<String, dynamic> json) {
    return YoudaoCollinsPrimary(
      words: json['words'] != null
          ? YoudaoPrimaryWords.fromJson(json['words'] as Map<String, dynamic>)
          : null,
      gramcat: json['gramcat'] != null
          ? (json['gramcat'] as List)
              .map((e) => YoudaoGramcat.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final YoudaoPrimaryWords? words;
  final List<YoudaoGramcat>? gramcat;
}

/// Primary Words model.
class YoudaoPrimaryWords {
  YoudaoPrimaryWords({
    this.indexforms,
    this.word,
  });

  factory YoudaoPrimaryWords.fromJson(Map<String, dynamic> json) {
    return YoudaoPrimaryWords(
      indexforms: json['indexforms'] != null
          ? (json['indexforms'] as List).map((e) => e.toString()).toList()
          : null,
      word: json['word'] as String?,
    );
  }

  final List<String>? indexforms;
  final String? word;
}

/// Gramcat model.
class YoudaoGramcat {
  YoudaoGramcat({
    this.audiourl,
    this.pronunciation,
    this.senses,
    this.lang,
    this.partofspeech,
    this.audio,
    this.forms,
  });

  factory YoudaoGramcat.fromJson(Map<String, dynamic> json) {
    return YoudaoGramcat(
      audiourl: json['audiourl'] as String?,
      pronunciation: json['pronunciation'] as String?,
      senses: json['senses'] != null
          ? (json['senses'] as List)
              .map((e) => YoudaoSense.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      lang: json['lang'] as String?,
      partofspeech: json['partofspeech'] as String?,
      audio: json['audio'] as String?,
      forms: json['forms'] != null
          ? (json['forms'] as List)
              .map((e) => YoudaoForm.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final String? audiourl;
  final String? pronunciation;
  final List<YoudaoSense>? senses;
  final String? lang;
  final String? partofspeech;
  final String? audio;
  final List<YoudaoForm>? forms;
}

/// Sense model.
class YoudaoSense {
  YoudaoSense({
    this.examples,
    this.definition,
    this.lang,
    this.word,
  });

  factory YoudaoSense.fromJson(Map<String, dynamic> json) {
    return YoudaoSense(
      examples: json['examples'] != null
          ? (json['examples'] as List)
              .map((e) => YoudaoExample.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      definition: json['definition'] as String?,
      lang: json['lang'] as String?,
      word: json['word'] as String?,
    );
  }

  final List<YoudaoExample>? examples;
  final String? definition;
  final String? lang;
  final String? word;
}

/// Example model.
class YoudaoExample {
  YoudaoExample({
    this.sense,
    this.example,
  });

  factory YoudaoExample.fromJson(Map<String, dynamic> json) {
    return YoudaoExample(
      sense: json['sense'] != null
          ? YoudaoSenseLang.fromJson(json['sense'] as Map<String, dynamic>)
          : null,
      example: json['example'] as String?,
    );
  }

  final YoudaoSenseLang? sense;
  final String? example;
}

/// Sense Lang model.
class YoudaoSenseLang {
  YoudaoSenseLang({
    this.lang,
    this.word,
  });

  factory YoudaoSenseLang.fromJson(Map<String, dynamic> json) {
    return YoudaoSenseLang(
      lang: json['lang'] as String?,
      word: json['word'] as String?,
    );
  }

  final String? lang;
  final String? word;
}

/// Form model.
class YoudaoForm {
  YoudaoForm({this.form});

  factory YoudaoForm.fromJson(Map<String, dynamic> json) {
    return YoudaoForm(
      form: json['form'] as String?,
    );
  }

  final String? form;
}

/// Auth Sents Part model.
class YoudaoAuthSentsPart {
  YoudaoAuthSentsPart({
    this.sentenceCount,
    this.more,
    this.sent,
  });

  factory YoudaoAuthSentsPart.fromJson(Map<String, dynamic> json) {
    return YoudaoAuthSentsPart(
      sentenceCount: json['sentence-count'] as int?,
      more: json['more'] as String?,
      sent: json['sent'] != null
          ? (json['sent'] as List)
              .map((e) => YoudaoAuthSent.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final int? sentenceCount;
  final String? more;
  final List<YoudaoAuthSent>? sent;
}

/// Auth Sentence model.
class YoudaoAuthSent {
  YoudaoAuthSent({
    this.score,
    this.speech,
    this.speechSize,
    this.source,
    this.url,
    this.foreign,
  });

  factory YoudaoAuthSent.fromJson(Map<String, dynamic> json) {
    return YoudaoAuthSent(
      score: (json['score'] as num?)?.toDouble(),
      speech: json['speech'] as String?,
      speechSize: json['speech-size'] as String?,
      source: json['source'] as String?,
      url: json['url'] as String?,
      foreign: json['foreign'] as String?,
    );
  }

  final double? score;
  final String? speech;
  final String? speechSize;
  final String? source;
  final String? url;
  final String? foreign;
}

/// Magic Words model.
class YoudaoMagicWords {
  YoudaoMagicWords({this.magicWords});

  factory YoudaoMagicWords.fromJson(Map<String, dynamic> json) {
    return YoudaoMagicWords(
      magicWords: json['magic_words'] != null
          ? (json['magic_words'] as List)
              .map((e) => YoudaoMagicWord.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoMagicWord>? magicWords;
}

/// Magic Word model.
class YoudaoMagicWord {
  YoudaoMagicWord({
    this.paraphrase,
    this.word,
    this.info,
    this.premiumVideoStatus,
  });

  factory YoudaoMagicWord.fromJson(Map<String, dynamic> json) {
    return YoudaoMagicWord(
      paraphrase: json['paraphrase'] as String?,
      word: json['word'] as String?,
      info: json['info'] != null
          ? (json['info'] as List)
              .map((e) => YoudaoMagicWordInfo.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      premiumVideoStatus: json['premiumVideoStatus'] as int?,
    );
  }

  final String? paraphrase;
  final String? word;
  final List<YoudaoMagicWordInfo>? info;
  final int? premiumVideoStatus;
}

/// Magic Word Info model.
class YoudaoMagicWordInfo {
  YoudaoMagicWordInfo({
    this.phonetic,
    this.videoUrl,
    this.phoneticType,
    this.videoCover,
    this.watermarkVideoUrl,
  });

  factory YoudaoMagicWordInfo.fromJson(Map<String, dynamic> json) {
    return YoudaoMagicWordInfo(
      phonetic: json['phonetic'] as String?,
      videoUrl: json['videoUrl'] as String?,
      phoneticType: json['phoneticType'] as String?,
      videoCover: json['videoCover'] as String?,
      watermarkVideoUrl: json['watermarkVideoUrl'] as String?,
    );
  }

  final String? phonetic;
  final String? videoUrl;
  final String? phoneticType;
  final String? videoCover;
  final String? watermarkVideoUrl;
}

/// Media Sents Part model.
class YoudaoMediaSentsPart {
  YoudaoMediaSentsPart({
    this.query,
    this.sent,
  });

  factory YoudaoMediaSentsPart.fromJson(Map<String, dynamic> json) {
    return YoudaoMediaSentsPart(
      query: json['query'] as String?,
      sent: json['sent'] != null
          ? (json['sent'] as List)
              .map((e) => YoudaoMediaSent.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final String? query;
  final List<YoudaoMediaSent>? sent;
}

/// Media Sentence model.
class YoudaoMediaSent {
  YoudaoMediaSent({
    this.mediatype,
    this.snippets,
    this.speechSize,
    this.eng,
    this.chn,
  });

  factory YoudaoMediaSent.fromJson(Map<String, dynamic> json) {
    return YoudaoMediaSent(
      mediatype: json['@mediatype'] as String?,
      snippets: json['snippets'] != null
          ? YoudaoSnippets.fromJson(json['snippets'] as Map<String, dynamic>)
          : null,
      speechSize: json['speech-size'] as String?,
      eng: json['eng'] as String?,
      chn: json['chn'] as String?,
    );
  }

  final String? mediatype;
  final YoudaoSnippets? snippets;
  final String? speechSize;
  final String? eng;
  final String? chn;
}

/// Snippets model.
class YoudaoSnippets {
  YoudaoSnippets({this.snippet});

  factory YoudaoSnippets.fromJson(Map<String, dynamic> json) {
    return YoudaoSnippets(
      snippet: json['snippet'] != null
          ? (json['snippet'] as List)
              .map((e) => YoudaoSnippet.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoSnippet>? snippet;
}

/// Snippet model.
class YoudaoSnippet {
  YoudaoSnippet({
    this.streamUrl,
    this.duration,
    this.swf,
    this.name,
    this.source,
    this.win8,
    this.sourceUrl,
    this.imageUrl,
  });

  factory YoudaoSnippet.fromJson(Map<String, dynamic> json) {
    return YoudaoSnippet(
      streamUrl: json['streamUrl'] as String?,
      duration: json['duration'] as String?,
      swf: json['swf'] as String?,
      name: json['name'] as String?,
      source: json['source'] as String?,
      win8: json['win8'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  final String? streamUrl;
  final String? duration;
  final String? swf;
  final String? name;
  final String? source;
  final String? win8;
  final String? sourceUrl;
  final String? imageUrl;
}

/// Etym model.
class YoudaoEtym {
  YoudaoEtym({
    this.etyms,
    this.word,
  });

  factory YoudaoEtym.fromJson(Map<String, dynamic> json) {
    return YoudaoEtym(
      etyms: json['etyms'] != null
          ? YoudaoEtyms.fromJson(json['etyms'] as Map<String, dynamic>)
          : null,
      word: json['word'] as String?,
    );
  }

  final YoudaoEtyms? etyms;
  final String? word;
}

/// Etyms model.
class YoudaoEtyms {
  YoudaoEtyms({this.zh});

  factory YoudaoEtyms.fromJson(Map<String, dynamic> json) {
    return YoudaoEtyms(
      zh: json['zh'] != null
          ? (json['zh'] as List)
              .map((e) => YoudaoEtymZh.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoEtymZh>? zh;
}

/// Etym Zh model.
class YoudaoEtymZh {
  YoudaoEtymZh({
    this.source,
    this.word,
    this.value,
    this.url,
    this.desc,
  });

  factory YoudaoEtymZh.fromJson(Map<String, dynamic> json) {
    return YoudaoEtymZh(
      source: json['source'] as String?,
      word: json['word'] as String?,
      value: json['value'] as String?,
      url: json['url'] as String?,
      desc: json['desc'] as String?,
    );
  }

  final String? source;
  final String? word;
  final String? value;
  final String? url;
  final String? desc;
}

/// Special model.
class YoudaoSpecial {
  YoudaoSpecial({
    this.summary,
    this.coAdd,
    this.total,
    this.entries,
  });

  factory YoudaoSpecial.fromJson(Map<String, dynamic> json) {
    return YoudaoSpecial(
      summary: json['summary'] != null
          ? YoudaoSpecialSummary.fromJson(
              json['summary'] as Map<String, dynamic>)
          : null,
      coAdd: json['co-add'] as String?,
      total: json['total'] as String?,
      entries: json['entries'] != null
          ? (json['entries'] as List)
              .map((e) => YoudaoSpecialEntry.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final YoudaoSpecialSummary? summary;
  final String? coAdd;
  final String? total;
  final List<YoudaoSpecialEntry>? entries;
}

/// Special Summary model.
class YoudaoSpecialSummary {
  YoudaoSpecialSummary({
    this.sources,
    this.text,
  });

  factory YoudaoSpecialSummary.fromJson(Map<String, dynamic> json) {
    return YoudaoSpecialSummary(
      sources: json['sources'] != null
          ? YoudaoSpecialSources.fromJson(
              json['sources'] as Map<String, dynamic>)
          : null,
      text: json['text'] as String?,
    );
  }

  final YoudaoSpecialSources? sources;
  final String? text;
}

/// Special Sources model.
class YoudaoSpecialSources {
  YoudaoSpecialSources({this.source});

  factory YoudaoSpecialSources.fromJson(Map<String, dynamic> json) {
    return YoudaoSpecialSources(
      source: json['source'] != null
          ? YoudaoSpecialSource.fromJson(
              json['source'] as Map<String, dynamic>)
          : null,
    );
  }

  final YoudaoSpecialSource? source;
}

/// Special Source model.
class YoudaoSpecialSource {
  YoudaoSpecialSource({
    this.site,
    this.url,
  });

  factory YoudaoSpecialSource.fromJson(Map<String, dynamic> json) {
    return YoudaoSpecialSource(
      site: json['site'] as String?,
      url: json['url'] as String?,
    );
  }

  final String? site;
  final String? url;
}

/// Special Entry model.
class YoudaoSpecialEntry {
  YoudaoSpecialEntry({this.entry});

  factory YoudaoSpecialEntry.fromJson(Map<String, dynamic> json) {
    return YoudaoSpecialEntry(
      entry: json['entry'] != null
          ? YoudaoSpecialEntryItem.fromJson(
              json['entry'] as Map<String, dynamic>)
          : null,
    );
  }

  final YoudaoSpecialEntryItem? entry;
}

/// Special Entry Item model.
class YoudaoSpecialEntryItem {
  YoudaoSpecialEntryItem({
    this.major,
    this.trs,
    this.num,
  });

  factory YoudaoSpecialEntryItem.fromJson(Map<String, dynamic> json) {
    return YoudaoSpecialEntryItem(
      major: json['major'] as String?,
      trs: json['trs'] != null
          ? (json['trs'] as List)
              .map((e) => YoudaoSpecialTr.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      num: json['num'] as int?,
    );
  }

  final String? major;
  final List<YoudaoSpecialTr>? trs;
  final int? num;
}

/// Special Translation model.
class YoudaoSpecialTr {
  YoudaoSpecialTr({this.tr});

  factory YoudaoSpecialTr.fromJson(Map<String, dynamic> json) {
    return YoudaoSpecialTr(
      tr: json['tr'] != null
          ? YoudaoSpecialTrItem.fromJson(json['tr'] as Map<String, dynamic>)
          : null,
    );
  }

  final YoudaoSpecialTrItem? tr;
}

/// Special Translation Item model.
class YoudaoSpecialTrItem {
  YoudaoSpecialTrItem({
    this.nat,
    this.chnSent,
    this.cite,
    this.docTitle,
    this.engSent,
    this.url,
  });

  factory YoudaoSpecialTrItem.fromJson(Map<String, dynamic> json) {
    return YoudaoSpecialTrItem(
      nat: json['nat'] as String?,
      chnSent: json['chnSent'] as String?,
      cite: json['cite'] as String?,
      docTitle: json['docTitle'] as String?,
      engSent: json['engSent'] as String?,
      url: json['url'] as String?,
    );
  }

  final String? nat;
  final String? chnSent;
  final String? cite;
  final String? docTitle;
  final String? engSent;
  final String? url;
}

/// Fanyi (Translation) model.
class YoudaoFanyi {
  YoudaoFanyi({
    this.voice,
    this.input,
    this.type,
    this.tran,
  });

  factory YoudaoFanyi.fromJson(Map<String, dynamic> json) {
    return YoudaoFanyi(
      voice: json['voice'] as String?,
      input: json['input'] as String?,
      type: json['type'] as String?,
      tran: json['tran'] as String?,
    );
  }

  final String? voice;
  final String? input;
  final String? type;
  final String? tran;
}

/// Word Elaboration model (encrypted data).
class YoudaoWordElaboration {
  YoudaoWordElaboration({required this.encryptedData});

  factory YoudaoWordElaboration.fromJson(Map<String, dynamic> json) {
    return YoudaoWordElaboration(
      encryptedData: json['encryptedData'] as String,
    );
  }

  final String encryptedData;
}

/// Related Word model.
class YoudaoRelWord {
  YoudaoRelWord({
    this.word,
    this.stem,
    this.rels,
  });

  factory YoudaoRelWord.fromJson(Map<String, dynamic> json) {
    return YoudaoRelWord(
      word: json['word'] as String?,
      stem: json['stem'] as String?,
      rels: json['rels'] != null
          ? (json['rels'] as List)
              .map((e) => YoudaoRelWordRel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final String? word;
  final String? stem;
  final List<YoudaoRelWordRel>? rels;
}

/// Related Word Relation model.
class YoudaoRelWordRel {
  YoudaoRelWordRel({this.rel});

  factory YoudaoRelWordRel.fromJson(Map<String, dynamic> json) {
    return YoudaoRelWordRel(
      rel: json['rel'] != null
          ? YoudaoRelWordRelItem.fromJson(json['rel'] as Map<String, dynamic>)
          : null,
    );
  }

  final YoudaoRelWordRelItem? rel;
}

/// Related Word Relation Item model.
class YoudaoRelWordRelItem {
  YoudaoRelWordRelItem({
    this.pos,
    this.words,
  });

  factory YoudaoRelWordRelItem.fromJson(Map<String, dynamic> json) {
    return YoudaoRelWordRelItem(
      pos: json['pos'] as String?,
      words: json['words'] != null
          ? (json['words'] as List)
              .map((e) =>
                  YoudaoRelWordWord.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final String? pos;
  final List<YoudaoRelWordWord>? words;
}

/// Related Word Word model.
class YoudaoRelWordWord {
  YoudaoRelWordWord({
    this.word,
    this.tran,
  });

  factory YoudaoRelWordWord.fromJson(Map<String, dynamic> json) {
    return YoudaoRelWordWord(
      word: json['word'] as String?,
      tran: json['tran'] as String?,
    );
  }

  final String? word;
  final String? tran;
}
