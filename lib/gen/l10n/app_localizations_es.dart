import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcomeMessage => 'Bienvenido a PromoRuta';

  @override
  String get description => 'Conecta anunciantes con promotores para campañas efectivas.';

  @override
  String get start => 'Empezar';

  @override
  String get next => 'Siguiente';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get permissionsAccess => 'Permisos y accesos';

  @override
  String get permissionsSubtitle => 'Actívá estos permisos para una mejor experiencia';

  @override
  String get locationTitle => 'Acceso a tu ubicación';

  @override
  String get locationSubtitle => 'Indispensable para seguir la ruta y ver campañas cerca tuyo';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsSubtitle => 'Seguí el estado de las campañas y no te pierdas lo que vaya surgiendo';

  @override
  String get microphoneTitle => 'Permitir micrófono';

  @override
  String get microphoneSubtitle => 'Grabar campañas de audio y reproducir contenido promocional';

  @override
  String get allowAllPermissions => 'Permitir todos los accesos';

  @override
  String get continueButton => 'Continuar';

  @override
  String get permissionGranted => 'Permiso concedido';
}
