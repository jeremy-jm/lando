// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Lando Dicionário';

  @override
  String get settings => 'Configurações';

  @override
  String get profile => 'Perfil';

  @override
  String get about => 'Sobre';

  @override
  String get notFound => '404';

  @override
  String get pageNotFound => 'Página não encontrada';

  @override
  String get themeMode => 'Modo de Tema';

  @override
  String get themeModeDescription =>
      'Alternar entre claro, escuro ou seguir o sistema';

  @override
  String get followSystem => 'Seguir Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get translation => 'Tradução';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar Idioma';

  @override
  String get chinese => 'Chinês';

  @override
  String get english => 'Inglês';

  @override
  String get japanese => 'Japonês';

  @override
  String get hindi => 'Hindi';

  @override
  String get indonesian => 'Indonésio';

  @override
  String get portuguese => 'Português';

  @override
  String get russian => 'Russo';

  @override
  String get pronunciationSource => 'Fonte de Pronúncia';

  @override
  String get pronunciationSourceDescription =>
      'Selecione o serviço de pronúncia a ser usado';

  @override
  String get pronunciationSystem => 'Sistema';

  @override
  String get pronunciationYoudao => 'Youdao';

  @override
  String get pronunciationBaidu => 'Baidu';

  @override
  String get pronunciationBing => 'Bing';

  @override
  String get pronunciationGoogle => 'Google';

  @override
  String get pronunciationApple => 'Apple';

  @override
  String get me => 'Eu';

  @override
  String get favorites => 'Favoritos';

  @override
  String get history => 'Histórico';

  @override
  String get noHistory => 'Nenhum histórico de consulta';

  @override
  String get clearHistory => 'Limpar Histórico';

  @override
  String get delete => 'Excluir';

  @override
  String get confirmClearHistory =>
      'Tem certeza de que deseja limpar todo o histórico?';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get noFavorites => 'Nenhum favorito';

  @override
  String get clearFavorites => 'Limpar Favoritos';

  @override
  String get confirmClearFavorites =>
      'Tem certeza de que deseja limpar todos os favoritos?';

  @override
  String get cannotFavorite =>
      'Não é possível favoritar: tradução não disponível';

  @override
  String get removedFromFavorites => 'Removido dos favoritos';

  @override
  String get addedToFavorites => 'Adicionado aos favoritos';

  @override
  String get general => 'Geral';

  @override
  String get dictionary => 'Dicionário';

  @override
  String get dictionarySettings => 'Configurações do Dicionário';

  @override
  String get dictionarySettingsDescription =>
      'Configurar configurações de pronúncia e tradução';

  @override
  String get appDescription =>
      'Um software de tradução que usa serviços de terceiros para pesquisa de palavras e não possui anúncios';

  @override
  String get version => 'Versão';

  @override
  String get buildNumber => 'Número da Build';

  @override
  String get versionInfo => 'Informações da Versão';

  @override
  String get versionInfoCopied =>
      'Informações da versão copiadas para a área de transferência';

  @override
  String get copy => 'Copiar';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get privacyPolicyContent =>
      'Este aplicativo respeita sua privacidade. Não coletamos, armazenamos ou compartilhamos informações pessoais. Todas as consultas de tradução são processadas por meio de serviços de terceiros.';

  @override
  String get termsOfService => 'Termos de Serviço';

  @override
  String get termsOfServiceContent =>
      'Ao usar este aplicativo, você concorda em usá-lo de forma responsável. Este aplicativo fornece serviços de tradução por meio de APIs de terceiros. Não somos responsáveis pela precisão das traduções.';

  @override
  String get openSourceLicenses => 'Licenças de Código Aberto';

  @override
  String get copyright =>
      'Direitos autorais © 2024 Lando Dicionário. Todos os direitos reservados.';

  @override
  String get close => 'Fechar';

  @override
  String get aboutDescription =>
      'Sobre este aplicativo, informações da versão e documentos legais';

  @override
  String get noSuggestionsFound =>
      'Nenhuma sugestão encontrada para sua consulta';

  @override
  String get enterTextToTranslate => 'Digite o texto para traduzir';

  @override
  String get playAudio => 'Reproduzir áudio';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get detectedAs => 'Detectado como';

  @override
  String get pronunciationNotAvailable => 'Pronúncia não disponível';

  @override
  String get errorPlayingPronunciation => 'Erro ao reproduzir pronúncia';

  @override
  String errorPlayingPronunciationWithDetails(String error) {
    return 'Erro ao reproduzir pronúncia: $error';
  }

  @override
  String errorWithDetails(String error) {
    return 'Erro: $error';
  }

  @override
  String get partOfSpeech => 'Classe Gramatical';

  @override
  String get tense => 'Tempo';

  @override
  String get phrases => 'Frases';

  @override
  String get webTranslations => 'Traduções da Web';

  @override
  String get navigateBack => 'Voltar';

  @override
  String get navigateForward => 'Avançar';

  @override
  String get shortcuts => 'Atalhos';

  @override
  String get showWindowHotkey => 'Atalho Mostrar Janela';

  @override
  String get showWindowHotkeyDescription =>
      'Defina um atalho global para mostrar a janela principal';

  @override
  String get currentHotkey => 'Atalho Atual';

  @override
  String get recordHotkey => 'Gravar';

  @override
  String get recording => 'Gravando...';

  @override
  String get pressKeysToRecord => 'Pressione as teclas para gravar...';

  @override
  String get hotkeySaved => 'Atalho salvo';

  @override
  String get hotkeyRequiresModifier =>
      'Por favor, inclua pelo menos uma tecla modificadora (Ctrl/Cmd, Alt ou Shift) ou use F1-F20';

  @override
  String get hotkeyRequiresValidKey =>
      'Por favor, inclua uma tecla de letra, dígito ou símbolo';

  @override
  String get selectSourceLanguage => 'Selecionar Idioma de Origem';

  @override
  String get selectTargetLanguage => 'Selecionar Idioma de Destino';

  @override
  String get auto => 'Automático';

  @override
  String get clearLocalData => 'Limpar Dados Locais';

  @override
  String get clearLocalDataDescription =>
      'Limpar todos os dados armazenados localmente, incluindo configurações, cookies e cache';

  @override
  String get confirmClearLocalData =>
      'Tem certeza de que deseja limpar todos os dados locais? Esta ação não pode ser desfeita.';

  @override
  String get localDataCleared => 'Dados locais limpos';

  @override
  String get proxySettings => 'Proxy Settings';

  @override
  String get proxySettingsDescription =>
      'Configure HTTP proxy for network requests';

  @override
  String get enableProxy => 'Enable Proxy';

  @override
  String get enableProxyDescription =>
      'Enable HTTP proxy for all network requests';

  @override
  String get proxyHost => 'Proxy Host';

  @override
  String get proxyHostHint => 'e.g., localhost';

  @override
  String get proxyPort => 'Proxy Port';

  @override
  String get proxyPortHint => 'e.g., 9091';

  @override
  String get validatingProxy => 'Validating proxy connection...';

  @override
  String get proxyValidationSuccess => 'Proxy connection successful';

  @override
  String get proxyValidationFailed => 'Failed to connect to proxy server';

  @override
  String get validateProxy => 'Validate Proxy';

  @override
  String get proxyConfigured => 'Proxy configured';

  @override
  String get proxyInfo => 'Proxy Information';

  @override
  String get proxyInfoDescription =>
      'Configure a local proxy server (e.g., localhost:9091) to route all network requests through it. The proxy will be used for all API calls when enabled.';
}
