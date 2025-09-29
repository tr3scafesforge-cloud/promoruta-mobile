import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// Welcome message displayed to users
  ///
  /// In en, this message translates to:
  /// **'Welcome to PromoRuta'**
  String get welcomeMessage;

  /// Description of the application
  ///
  /// In en, this message translates to:
  /// **'Connect advertisers with promoters for effective campaigns.'**
  String get description;

  /// Label for the button to start the onboarding or process
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Label for the button to go to the next step
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Label for the login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Title for the permissions and access screen
  ///
  /// In en, this message translates to:
  /// **'Permissions and Access'**
  String get permissionsAccess;

  /// Subtitle explaining why permissions are needed
  ///
  /// In en, this message translates to:
  /// **'Activate these permissions for a better experience'**
  String get permissionsSubtitle;

  /// Title for location permission
  ///
  /// In en, this message translates to:
  /// **'Access to your location'**
  String get locationTitle;

  /// Subtitle for location permission
  ///
  /// In en, this message translates to:
  /// **'Essential to follow the route and see campaigns near you'**
  String get locationSubtitle;

  /// Title for notifications permission
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// Subtitle for notifications permission
  ///
  /// In en, this message translates to:
  /// **'Follow the status of campaigns and don\'t miss what\'s coming up'**
  String get notificationsSubtitle;

  /// Title for microphone permission
  ///
  /// In en, this message translates to:
  /// **'Allow microphone'**
  String get microphoneTitle;

  /// Subtitle for microphone permission
  ///
  /// In en, this message translates to:
  /// **'Record audio campaigns and play promotional content'**
  String get microphoneSubtitle;

  /// Button text to allow all permissions
  ///
  /// In en, this message translates to:
  /// **'Allow all accesses'**
  String get allowAllPermissions;

  /// Button text to continue to next screen
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Text indicating permission has been granted
  ///
  /// In en, this message translates to:
  /// **'Permission granted'**
  String get permissionGranted;

  /// Title for location permission dialog
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequiredTitle;

  /// Explanation for why location permission is needed
  ///
  /// In en, this message translates to:
  /// **'We need access to your location to show you campaigns near you and help with navigation.'**
  String get locationPermissionExplanation;

  /// Button text to cancel an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text to allow permission
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// Title when permission is denied
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// Message when permissions are permanently denied
  ///
  /// In en, this message translates to:
  /// **'Permissions have been permanently denied. Please go to settings to enable them.'**
  String get permissionPermanentlyDenied;

  /// Button text to open app settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Status text when permission is granted
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// Status text when permission is required
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Status text when permission is optional
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Main title for the choose role screen
  ///
  /// In en, this message translates to:
  /// **'Advertiser or promoter?\nChoose your role'**
  String get chooseRoleTitle;

  /// Subtitle for the choose role screen
  ///
  /// In en, this message translates to:
  /// **'How do you prefer to use PromoRuta?'**
  String get chooseRoleSubtitle;

  /// Title for the advertiser role option
  ///
  /// In en, this message translates to:
  /// **'I\'m an advertiser'**
  String get advertiserTitle;

  /// Description for the advertiser role
  ///
  /// In en, this message translates to:
  /// **'Create audio campaigns, choose routes and receive reports on how your message was broadcast'**
  String get advertiserDescription;

  /// Title for the promoter role option
  ///
  /// In en, this message translates to:
  /// **'I\'m a promoter'**
  String get promoterTitle;

  /// Description for the promoter role
  ///
  /// In en, this message translates to:
  /// **'Look for nearby opportunities, accept campaigns and earn income with sound advertising'**
  String get promoterDescription;

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'PROMORUTA'**
  String get appName;

  /// Welcome back message
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// Prompt to log in to continue
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get loginToContinue;

  /// Instruction to enter credentials
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access your account'**
  String get enterCredentials;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Hint text for email input
  ///
  /// In en, this message translates to:
  /// **'myemail@email.com'**
  String get emailHint;

  /// Validation message for empty email
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Validation message for invalid email
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// Label for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Hint text for password input
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Validation message for empty password
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Validation message for short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// Divider text for social login
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// Text before sign up link
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet? '**
  String get noAccountYet;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
