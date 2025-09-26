import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeMessage => 'Welcome to PromoRuta';

  @override
  String get description => 'Connect advertisers with promoters for effective campaigns.';

  @override
  String get start => 'Start';

  @override
  String get next => 'Next';

  @override
  String get login => 'Login';

  @override
  String get permissionsAccess => 'Permissions and Access';

  @override
  String get permissionsSubtitle => 'Activate these permissions for a better experience';

  @override
  String get locationTitle => 'Access to your location';

  @override
  String get locationSubtitle => 'Essential to follow the route and see campaigns near you';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Follow the status of campaigns and don\'t miss what\'s coming up';

  @override
  String get microphoneTitle => 'Allow microphone';

  @override
  String get microphoneSubtitle => 'Record audio campaigns and play promotional content';

  @override
  String get allowAllPermissions => 'Allow all accesses';

  @override
  String get continueButton => 'Continue';

  @override
  String get permissionGranted => 'Permission granted';
}
