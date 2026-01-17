/// Youdao Simple MultiPhone model.
/// Represents multiple phonetic pronunciations for US and UK.
class YoudaoMultiPhone {
  YoudaoMultiPhone({this.uk, this.us});

  factory YoudaoMultiPhone.fromJson(Map<String, dynamic> json) {
    return YoudaoMultiPhone(
      uk: json['uk'] != null
          ? (json['uk'] as List)
                .map((e) => YoudaoPhoneItem.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      us: json['us'] != null
          ? (json['us'] as List)
                .map((e) => YoudaoPhoneItem.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  final List<YoudaoPhoneItem>? uk;
  final List<YoudaoPhoneItem>? us;
}

/// Phone item model (phonetic pronunciation with part of speech).
class YoudaoPhoneItem {
  YoudaoPhoneItem({this.phone, this.pos, this.speech});

  factory YoudaoPhoneItem.fromJson(Map<String, dynamic> json) {
    return YoudaoPhoneItem(
      phone: json['phone'] as String?,
      pos: json['pos'] != null
          ? (json['pos'] as List).map((e) => e.toString()).toList()
          : null,
      speech: json['speech'] as String?,
    );
  }

  final String? phone;
  final List<String>? pos;
  final String? speech;
}
