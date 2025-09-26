import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get welcomeMessage => 'Bem-vindo ao PromoRuta';

  @override
  String get description => 'Conecte anunciantes com promotores para campanhas eficazes.';

  @override
  String get start => 'Começar';

  @override
  String get next => 'Próximo';

  @override
  String get login => 'Entrar';

  @override
  String get permissionsAccess => 'Permissões e Acessos';

  @override
  String get permissionsSubtitle => 'Ative essas permissões para uma melhor experiência';

  @override
  String get locationTitle => 'Acesso à sua localização';

  @override
  String get locationSubtitle => 'Essencial para seguir a rota e ver campanhas perto de você';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationsSubtitle => 'Acompanhe o status das campanhas e não perca o que está por vir';

  @override
  String get microphoneTitle => 'Permitir microfone';

  @override
  String get microphoneSubtitle => 'Gravar campanhas de áudio e reproduzir conteúdo promocional';

  @override
  String get allowAllPermissions => 'Permitir todos os acessos';

  @override
  String get continueButton => 'Continuar';

  @override
  String get permissionGranted => 'Permissão concedida';
}
