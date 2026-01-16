/// Enumeration of available translation service types.
enum TranslationServiceType {
  youdao,
  google,
  bing,
}

/// Extension to get display names for translation service types.
extension TranslationServiceTypeExtension on TranslationServiceType {
  String get displayName {
    switch (this) {
      case TranslationServiceType.youdao:
        return 'Youdao';
      case TranslationServiceType.google:
        return 'Google';
      case TranslationServiceType.bing:
        return 'Bing';
    }
  }
}
