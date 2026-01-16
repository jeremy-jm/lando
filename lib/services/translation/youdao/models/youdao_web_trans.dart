/// Youdao Web Translation model.
class YoudaoWebTrans {
  YoudaoWebTrans({
    this.webTranslation,
  });

  factory YoudaoWebTrans.fromJson(Map<String, dynamic> json) {
    return YoudaoWebTrans(
      webTranslation: json['web-translation'] != null
          ? (json['web-translation'] as List)
              .map((e) =>
                  YoudaoWebTranslation.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final List<YoudaoWebTranslation>? webTranslation;
}

/// Web Translation item model.
class YoudaoWebTranslation {
  YoudaoWebTranslation({
    this.same,
    this.key,
    this.keySpeech,
    this.trans,
  });

  factory YoudaoWebTranslation.fromJson(Map<String, dynamic> json) {
    return YoudaoWebTranslation(
      same: json['@same'] as String?,
      key: json['key'] as String?,
      keySpeech: json['key-speech'] as String?,
      trans: json['trans'] != null
          ? (json['trans'] as List)
              .map((e) => YoudaoWebTransItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final String? same;
  final String? key;
  final String? keySpeech;
  final List<YoudaoWebTransItem>? trans;
}

/// Web Translation item detail model.
class YoudaoWebTransItem {
  YoudaoWebTransItem({
    this.summary,
    this.value,
    this.support,
    this.url,
    this.cls,
  });

  factory YoudaoWebTransItem.fromJson(Map<String, dynamic> json) {
    return YoudaoWebTransItem(
      summary: json['summary'] != null
          ? YoudaoWebTransSummary.fromJson(
              json['summary'] as Map<String, dynamic>)
          : null,
      value: json['value'] as String?,
      support: json['support'] as int?,
      url: json['url'] as String?,
      cls: json['cls'] != null
          ? YoudaoWebTransCls.fromJson(json['cls'] as Map<String, dynamic>)
          : null,
    );
  }

  final YoudaoWebTransSummary? summary;
  final String? value;
  final int? support;
  final String? url;
  final YoudaoWebTransCls? cls;
}

/// Web Translation Summary model.
class YoudaoWebTransSummary {
  YoudaoWebTransSummary({
    this.line,
  });

  factory YoudaoWebTransSummary.fromJson(Map<String, dynamic> json) {
    return YoudaoWebTransSummary(
      line: json['line'] != null
          ? (json['line'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  final List<String>? line;
}

/// Web Translation Classification model.
class YoudaoWebTransCls {
  YoudaoWebTransCls({
    this.cl,
  });

  factory YoudaoWebTransCls.fromJson(Map<String, dynamic> json) {
    return YoudaoWebTransCls(
      cl: json['cl'] != null
          ? (json['cl'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  final List<String>? cl;
}
