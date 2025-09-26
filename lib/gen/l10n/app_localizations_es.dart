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

  @override
  String get locationPermissionRequiredTitle => 'Permiso de ubicación requerido';

  @override
  String get locationPermissionExplanation => 'Necesitamos acceso a tu ubicación para mostrarte campañas cerca de ti y ayudarte con la navegación.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get allow => 'Permitir';

  @override
  String get permissionDenied => 'Permiso denegado';

  @override
  String get permissionPermanentlyDenied => 'Los permisos han sido denegados permanentemente. Por favor, ve a configuración para habilitarlos.';

  @override
  String get settings => 'Configuración';

  @override
  String get granted => 'Concedido';

  @override
  String get required => 'Requerido';

  @override
  String get optional => 'Opcional';

  @override
  String get chooseRoleTitle => '¿Anunciante o promotor?\nElegí tu rol';

  @override
  String get chooseRoleSubtitle => '¿Cómo preferís usar Promoruta?';

  @override
  String get advertiserTitle => 'Soy anunciante';

  @override
  String get advertiserDescription => 'Crea campañas de audio, elegí los recorridos y recibí reportes de cómo se difundió tu mensaje';

  @override
  String get promoterTitle => 'Soy promotor';

  @override
  String get promoterDescription => 'Mirá oportunidades cerca, aceptá campañas y sumá ingresos con publicidad sonora';
}
