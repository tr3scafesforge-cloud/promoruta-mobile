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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
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

  /// Message when critical permissions (location and notifications) are not granted
  ///
  /// In en, this message translates to:
  /// **'Location and notifications are required to continue'**
  String get criticalPermissionsRequired;

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

  /// Hint text for email input field
  ///
  /// In en, this message translates to:
  /// **'user@example.com'**
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

  /// Validation error for empty password field
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

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

  /// Greeting in the morning
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Subtitle for the home screen
  ///
  /// In en, this message translates to:
  /// **'Ready to create your next campaign'**
  String get readyToCreateNextCampaign;

  /// Snackbar message for create campaign button
  ///
  /// In en, this message translates to:
  /// **'Create campaign (WIP)'**
  String get createCampaignWip;

  /// Bottom navigation label for home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Bottom navigation label for campaigns
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get campaigns;

  /// Bottom navigation label for live
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// Bottom navigation label for history
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Bottom navigation label for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Label for active campaigns
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Label for zones covered stat
  ///
  /// In en, this message translates to:
  /// **'Zones covered'**
  String get zonesCovered;

  /// Time period for stats
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get thisWeek;

  /// Top label for this week stat card (feminine)
  ///
  /// In en, this message translates to:
  /// **'This'**
  String get thisWeekLabelTop;

  /// Bottom label for this week stat card
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get thisWeekLabelBottom;

  /// Top label for this month stat card (masculine)
  ///
  /// In en, this message translates to:
  /// **'This'**
  String get thisMonthLabelTop;

  /// Bottom label for this month stat card
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get thisMonthLabelBottom;

  /// Label for investment stat
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get investment;

  /// Label for accumulated investment
  ///
  /// In en, this message translates to:
  /// **'accumulated'**
  String get accumulated;

  /// Section header for active campaigns
  ///
  /// In en, this message translates to:
  /// **'Active campaigns'**
  String get activeCampaigns;

  /// Button text to see all campaigns
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Snackbar message for see all button
  ///
  /// In en, this message translates to:
  /// **'See all (WIP)'**
  String get seeAllWip;

  /// Title for create first campaign card
  ///
  /// In en, this message translates to:
  /// **'Create your first campaign'**
  String get createYourFirstCampaign;

  /// Description for create first campaign card
  ///
  /// In en, this message translates to:
  /// **'Design an audio ad, mark your route and start promoting'**
  String get designAudioAdMarkRouteStartPromoting;

  /// Button text to start campaign
  ///
  /// In en, this message translates to:
  /// **'Start campaign'**
  String get startCampaign;

  /// Snackbar message for start campaign button
  ///
  /// In en, this message translates to:
  /// **'Start campaign (WIP)'**
  String get startCampaignWip;

  /// Campaign title example
  ///
  /// In en, this message translates to:
  /// **'Coffee Shop Promotion'**
  String get coffeeShopPromotion;

  /// Time label for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for route metric
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// Label for audio metric
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// Label for completed metric
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Subtitle for campaign card
  ///
  /// In en, this message translates to:
  /// **'2 Active promoters'**
  String get twoActivePromoters;

  /// Campaign title example
  ///
  /// In en, this message translates to:
  /// **'Store Opening'**
  String get storeOpening;

  /// Status label for pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Subtitle for pending campaign
  ///
  /// In en, this message translates to:
  /// **'Waiting for promoters'**
  String get waitingForPromoters;

  /// Suffix for placeholder tabs
  ///
  /// In en, this message translates to:
  /// **' (pending)'**
  String get placeholderPending;

  /// Hint text for search campaigns input
  ///
  /// In en, this message translates to:
  /// **'Search campaigns'**
  String get searchCampaigns;

  /// Message when no campaigns are found
  ///
  /// In en, this message translates to:
  /// **'No campaigns found'**
  String get noCampaignsFound;

  /// Message when no campaigns are found for the selected filters
  ///
  /// In en, this message translates to:
  /// **'There are no campaigns for the selected filters.'**
  String get noCampaignsForSelectedFilters;

  /// Button text to apply filters
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// Button text to clear filters
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Status label for completed campaigns
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Status label for canceled campaigns
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get statusCanceled;

  /// Status label for expired campaigns
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// Status label for unknown campaign status
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// Button text to view campaign report
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get viewReport;

  /// Button text to duplicate campaign
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// Button text to reactivate campaign
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get reactivate;

  /// Label for campaign status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Label for canceled status option
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// Label for expired status option
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Label for all status option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Button text to reset filter
  ///
  /// In en, this message translates to:
  /// **'Reset Filter'**
  String get resetFilter;

  /// Button text to apply filter
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// Label for dark mode toggle
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Label for security settings
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Label for language settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language name
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Portuguese language name
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// Title for change language dialog
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguageTitle;

  /// Message for change language dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change the language to {language}?'**
  String changeLanguageMessage(String language);

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Filter option for all campaigns
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get campaignFilterAll;

  /// Filter option for active campaigns
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get campaignFilterActive;

  /// Filter option for pending campaigns
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get campaignFilterPending;

  /// Filter option for completed campaigns
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get campaignFilterCompleted;

  /// Filter option for cancelled campaigns
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get campaignFilterCancelled;

  /// Filter option for urgent campaigns
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get campaignFilterUrgent;

  /// Filter option for nearby campaigns
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get campaignFilterNearby;

  /// Filter option for best paid campaigns
  ///
  /// In en, this message translates to:
  /// **'Best paid'**
  String get campaignFilterBestPaid;

  /// Tab label for active promoters
  ///
  /// In en, this message translates to:
  /// **'Active Promoters'**
  String get activePromoters;

  /// Tab label for live map
  ///
  /// In en, this message translates to:
  /// **'Live Map'**
  String get liveMap;

  /// Tab label for alerts
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// Title for active promoters section
  ///
  /// In en, this message translates to:
  /// **'👥 Active Promoters'**
  String get activePromotersTitle;

  /// Title for real-time location section
  ///
  /// In en, this message translates to:
  /// **'📍 Real-time Location'**
  String get realTimeLocation;

  /// Section header for active promoters
  ///
  /// In en, this message translates to:
  /// **'Active promoters'**
  String get activePromotersSection;

  /// Description for active promoters section
  ///
  /// In en, this message translates to:
  /// **'Here you will see the promoters who are currently active in your campaigns.'**
  String get activePromotersDescription;

  /// Section header for live map
  ///
  /// In en, this message translates to:
  /// **'Live map'**
  String get liveMapSection;

  /// Description for live map section
  ///
  /// In en, this message translates to:
  /// **'View the real-time location of your promoters on the map.'**
  String get liveMapDescription;

  /// Section header for alerts and notifications
  ///
  /// In en, this message translates to:
  /// **'Alerts and Notifications'**
  String get alertsAndNotifications;

  /// Description for alerts section
  ///
  /// In en, this message translates to:
  /// **'Here you will receive important alerts about your campaigns and promoters.'**
  String get alertsDescription;

  /// Alert title for promoter out of zone
  ///
  /// In en, this message translates to:
  /// **'Promoter out of zone'**
  String get promoterOutOfZone;

  /// Alert message for promoter out of zone
  ///
  /// In en, this message translates to:
  /// **'Juan Pérez is outside the assigned zone'**
  String get promoterOutOfZoneMessage;

  /// Alert title for campaign completed
  ///
  /// In en, this message translates to:
  /// **'Campaign completed'**
  String get campaignCompleted;

  /// Alert message for campaign completed
  ///
  /// In en, this message translates to:
  /// **'The campaign \"Coffee Shop Promotion\" has finished'**
  String get campaignCompletedMessage;

  /// Time format for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// Time format for hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours} hour ago'**
  String hoursAgo(int hours);

  /// Placeholder text for map location
  ///
  /// In en, this message translates to:
  /// **'Map location in real time'**
  String get mapLocationRealTime;

  /// Label for live indicator
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveLabel;

  /// Button label for layers
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get layers;

  /// Button label for now/time
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// Filter label for no signal
  ///
  /// In en, this message translates to:
  /// **'No signal'**
  String get noSignal;

  /// Text for last updated timestamp
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// Alert message for promoter starting route
  ///
  /// In en, this message translates to:
  /// **'Started the route'**
  String get startedRoute;

  /// Alert message for promoter preparing for route
  ///
  /// In en, this message translates to:
  /// **'Preparing for the route'**
  String get preparingForRoute;

  /// Label for payment methods option in security settings
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// Label for two-factor authentication option in security settings
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// Label for current password field
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// Label for new password input field
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Label for confirm new password field
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// Validation message for empty current password
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// Validation message for empty new password
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// Validation message for short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// Validation message for empty password confirmation
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required'**
  String get confirmPasswordRequired;

  /// Validation error when passwords don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Validation message when new password is the same as current
  ///
  /// In en, this message translates to:
  /// **'New password cannot be the same as the current password'**
  String get newPasswordCannotBeSameAsCurrent;

  /// Button text to change password
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Title for password change confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm password change'**
  String get confirmPasswordChange;

  /// Message for password change confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change your password? This action cannot be undone.'**
  String get confirmPasswordChangeMessage;

  /// Success message when password is changed
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// Error message prefix when password change fails
  ///
  /// In en, this message translates to:
  /// **'Error changing password'**
  String get errorChangingPassword;

  /// Error message when current password is wrong (401)
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect. Please try again.'**
  String get currentPasswordIncorrect;

  /// Error message for validation errors (422)
  ///
  /// In en, this message translates to:
  /// **'Invalid password format. Please check your input.'**
  String get invalidPasswordFormat;

  /// Generic error message for password change failures
  ///
  /// In en, this message translates to:
  /// **'Unable to change password. Please try again later.'**
  String get unableToChangePassword;

  /// Error message for network issues during password change
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get networkErrorPasswordChange;

  /// Error message for server errors (500) during password change
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again later.'**
  String get serverErrorPasswordChange;

  /// Label for new campaign
  ///
  /// In en, this message translates to:
  /// **'New Campaign'**
  String get newCampaign;

  /// Label for user ID
  ///
  /// In en, this message translates to:
  /// **'UID'**
  String get uid;

  /// Label for username
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Label for email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for registration date
  ///
  /// In en, this message translates to:
  /// **'Registration Date'**
  String get registrationDate;

  /// Button text to delete account
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Confirmation message for deleting account
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. Are you sure you want to continue?'**
  String get deleteAccountConfirmation;

  /// Button text to confirm deletion
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Button text to sign out
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Confirmation message for signing out
  ///
  /// In en, this message translates to:
  /// **'Do you want to sign out?'**
  String get signOutConfirmation;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Message when no user is logged in
  ///
  /// In en, this message translates to:
  /// **'No user logged in'**
  String get noUserLoggedIn;

  /// Title for create campaign page
  ///
  /// In en, this message translates to:
  /// **'Create campaign'**
  String get createCampaign;

  /// Subtitle for create campaign page
  ///
  /// In en, this message translates to:
  /// **'Design your audio promotion campaign'**
  String get createCampaignSubtitle;

  /// Section header for basic information
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// Label for campaign title field
  ///
  /// In en, this message translates to:
  /// **'Campaign title'**
  String get campaignTitle;

  /// Hint for campaign name input
  ///
  /// In en, this message translates to:
  /// **'Campaign name'**
  String get campaignNameHint;

  /// Validation message for empty campaign title
  ///
  /// In en, this message translates to:
  /// **'Please enter the campaign title'**
  String get pleaseEnterCampaignTitle;

  /// Hint for campaign description input
  ///
  /// In en, this message translates to:
  /// **'Brief campaign description'**
  String get briefCampaignDescription;

  /// Validation message for empty description
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// Section header for audio announcement
  ///
  /// In en, this message translates to:
  /// **'Audio announcement'**
  String get audioAnnouncement;

  /// Label for upload audio file section
  ///
  /// In en, this message translates to:
  /// **'Upload audio file'**
  String get uploadAudioFile;

  /// Button text to add audio file
  ///
  /// In en, this message translates to:
  /// **'Add audio file'**
  String get addAudioFile;

  /// Button text to change audio file
  ///
  /// In en, this message translates to:
  /// **'Change audio file'**
  String get changeAudioFile;

  /// Audio file specifications
  ///
  /// In en, this message translates to:
  /// **'MP3 / WAV / AAC · Up to 30 s · 10 MB max'**
  String get audioFileSpecs;

  /// Section header for budget and location
  ///
  /// In en, this message translates to:
  /// **'Budget and location'**
  String get budgetAndLocation;

  /// Label for budget field
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// Validation message for empty budget
  ///
  /// In en, this message translates to:
  /// **'Please enter the budget'**
  String get pleaseEnterBudget;

  /// Validation message for invalid number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// Label for coverage zone
  ///
  /// In en, this message translates to:
  /// **'Coverage zone'**
  String get coverageZone;

  /// Placeholder text for map location
  ///
  /// In en, this message translates to:
  /// **'Map Location'**
  String get mapLocation;

  /// Section header for campaign schedule
  ///
  /// In en, this message translates to:
  /// **'Campaign schedule'**
  String get campaignSchedule;

  /// Label for date field
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Date format hint
  ///
  /// In en, this message translates to:
  /// **'mm/dd/yyyy'**
  String get dateFormatHint;

  /// Validation message for empty date
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// Label for campaign start time
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// Label for campaign end time
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// Loading message when uploading audio
  ///
  /// In en, this message translates to:
  /// **'Uploading audio file...'**
  String get uploadingAudioFile;

  /// Error message for file too large
  ///
  /// In en, this message translates to:
  /// **'File is too large. Maximum 10 MB.'**
  String get fileTooLarge;

  /// Success message when file is selected
  ///
  /// In en, this message translates to:
  /// **'File selected: {fileName}'**
  String fileSelected(String fileName);

  /// Error message when selecting file fails
  ///
  /// In en, this message translates to:
  /// **'Error selecting file: {error}'**
  String errorSelectingFile(String error);

  /// Message for pending location selection feature
  ///
  /// In en, this message translates to:
  /// **'Location selection feature pending implementation'**
  String get locationSelectionPending;

  /// Validation message for missing audio file
  ///
  /// In en, this message translates to:
  /// **'Please select an audio file'**
  String get pleaseSelectAudioFile;

  /// Success message when campaign is created
  ///
  /// In en, this message translates to:
  /// **'Campaign created. Uploading audio...'**
  String get campaignCreatedUploadingAudio;

  /// Success message with campaign details
  ///
  /// In en, this message translates to:
  /// **'Campaign created successfully'**
  String get campaignCreatedSuccessfully;

  /// Error message when creating campaign fails
  ///
  /// In en, this message translates to:
  /// **'Error creating campaign: {error}'**
  String errorCreatingCampaign(String error);

  /// Title for campaign creation confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm campaign creation'**
  String get confirmCampaignCreation;

  /// Warning message in campaign creation confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Once the campaign is created, you will not be able to modify any data. Are you sure all the information is correct?'**
  String get campaignCreationWarning;

  /// Title for invalid time range error
  ///
  /// In en, this message translates to:
  /// **'Invalid time range'**
  String get invalidTimeRange;

  /// Error message when start time is not before end time
  ///
  /// In en, this message translates to:
  /// **'Start time must be before end time. If your campaign crosses midnight (e.g., 23:00 to 01:00), please select dates on different days.'**
  String get startTimeMustBeBeforeEndTime;

  /// Label for active campaigns with plural message
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Active} other{Actives}} '**
  String nActive(num count);

  /// Message shown when there are no active campaigns
  ///
  /// In en, this message translates to:
  /// **'No active campaigns'**
  String get noActiveCampaigns;

  /// Button text to preview a campaign
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Button text to accept a promotion
  ///
  /// In en, this message translates to:
  /// **'Accept promotion'**
  String get acceptPromotion;

  /// Section header for nearby campaigns
  ///
  /// In en, this message translates to:
  /// **'Nearby campaigns'**
  String get nearbyCampaigns;

  /// Page title for nearby campaigns
  ///
  /// In en, this message translates to:
  /// **'Nearby campaigns'**
  String get nearbyCampaignsTitle;

  /// Subtitle for nearby campaigns page
  ///
  /// In en, this message translates to:
  /// **'Discover campaigns near you'**
  String get discoverNearbyCampaigns;

  /// Label for available campaigns count with plural support
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No available campaigns} one{Available campaign ({count})} other{Available campaigns ({count})}}'**
  String availableCampaignsCount(int count);

  /// Button text to view map
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get viewMap;

  /// Bottom navigation label for nearby campaigns in your area
  ///
  /// In en, this message translates to:
  /// **'In your area'**
  String get inYourArea;

  /// Bottom navigation label for active campaign (singular)
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeSingular;

  /// Label for earnings
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// AppBar title for promoter home page
  ///
  /// In en, this message translates to:
  /// **'Ready to earn income?'**
  String get readyToEarnIncome;

  /// AppBar subtitle for promoter home page
  ///
  /// In en, this message translates to:
  /// **'Take nearby campaigns and start the promo.'**
  String get takeCampaignsNearbyStartPromo;

  /// Title for campaign details page
  ///
  /// In en, this message translates to:
  /// **'Campaign Details'**
  String get campaignDetails;

  /// Button text to cancel a campaign
  ///
  /// In en, this message translates to:
  /// **'Cancel Campaign'**
  String get cancelCampaign;

  /// Label for cancellation reason input
  ///
  /// In en, this message translates to:
  /// **'Cancellation Reason'**
  String get cancelReason;

  /// Placeholder for cancellation reason input
  ///
  /// In en, this message translates to:
  /// **'Enter cancellation reason'**
  String get enterCancellationReason;

  /// Title for confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get confirmCancellation;

  /// Message for cancellation confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this campaign? This action cannot be undone.'**
  String get areYouSureCancelCampaign;

  /// Success message after campaign cancellation
  ///
  /// In en, this message translates to:
  /// **'Campaign cancelled successfully'**
  String get campaignCancelled;

  /// Label for suggested price
  ///
  /// In en, this message translates to:
  /// **'Suggested Price'**
  String get suggestedPrice;

  /// Label for final price
  ///
  /// In en, this message translates to:
  /// **'Final Price'**
  String get finalPrice;

  /// Label for bid deadline
  ///
  /// In en, this message translates to:
  /// **'Bid Deadline'**
  String get bidDeadline;

  /// Status text for cancelled campaign
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Validation message for cancellation reason
  ///
  /// In en, this message translates to:
  /// **'Reason is required'**
  String get reasonIsRequired;

  /// Title for forgot password page
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// Main title on forgot password page
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// Description text on forgot password page
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a 6-digit verification code.'**
  String get resetPasswordDescription;

  /// Button text to send verification code
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// Title for reset password page
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordPageTitle;

  /// Title text on verify code page
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// Message showing where code was sent
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}'**
  String codeSentToEmail(String email);

  /// Warning message about code expiration
  ///
  /// In en, this message translates to:
  /// **'Code expires in 10 minutes'**
  String get codeExpiresIn;

  /// Label for verification code input field
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// Hint text for verification code field
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get codeHint;

  /// Validation error for empty code field
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get pleaseEnterVerificationCode;

  /// Error message for code not being 6 digits
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 digits'**
  String get codeMustBeSixDigits;

  /// Button text to resend verification code
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? Resend'**
  String get didntReceiveCodeResend;

  /// Hint text for password field minimum length
  ///
  /// In en, this message translates to:
  /// **'Min 8 characters'**
  String get minCharacters;

  /// Label for confirm password input field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Validation error for password too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLengthEight;

  /// Validation error for empty confirm password field
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Button text to reset password
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Title for earnings page
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsPageTitle;

  /// Subtitle for earnings page
  ///
  /// In en, this message translates to:
  /// **'Track your campaign earnings and manage your payments'**
  String get earningsPageSubtitle;

  /// Label for total earnings
  ///
  /// In en, this message translates to:
  /// **'Total earnings'**
  String get totalEarnings;

  /// Label for this month earnings
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// Percentage increase from last month
  ///
  /// In en, this message translates to:
  /// **'{percentage}% more than last month'**
  String percentageMoreThanLastMonth(String percentage);

  /// Label for available earnings
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Button text to withdraw funds
  ///
  /// In en, this message translates to:
  /// **'Withdraw funds'**
  String get withdrawFunds;

  /// Label for pending earnings with amount
  ///
  /// In en, this message translates to:
  /// **'Pending earnings: {amount}'**
  String pendingEarningsAmount(String amount);

  /// Message indicating funds available after campaign ends
  ///
  /// In en, this message translates to:
  /// **'Available for withdrawal when the campaign ends.'**
  String get availableAfterCampaign;

  /// Label for historical tab
  ///
  /// In en, this message translates to:
  /// **'Historical'**
  String get historical;

  /// Label for statistics tab
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Label for payments tab
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// Label for recent earnings section
  ///
  /// In en, this message translates to:
  /// **'Recent earnings'**
  String get recentEarnings;

  /// Button text to download report
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get downloadReport;

  /// Status label for paid transaction
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// Label for bank transfer payment method
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// Label for earnings per month chart
  ///
  /// In en, this message translates to:
  /// **'Earnings per month'**
  String get earningsPerMonth;

  /// Label for last 6 months period
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get lastSixMonths;

  /// Abbreviation for January
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// Abbreviation for December
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// Abbreviation for November
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// Abbreviation for October
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// Abbreviation for September
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// Abbreviation for August
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// Button text to add payment method
  ///
  /// In en, this message translates to:
  /// **'Add payment method'**
  String get addPaymentMethod;

  /// Label for primary payment method
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// Button text to edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Title for active jobs page
  ///
  /// In en, this message translates to:
  /// **'Active jobs'**
  String get activeJobs;

  /// Subtitle for active jobs page
  ///
  /// In en, this message translates to:
  /// **'Control your campaigns in progress'**
  String get controlYourCampaigns;

  /// Label for active jobs count
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get activeJobsCount;

  /// Label for today's earnings
  ///
  /// In en, this message translates to:
  /// **'Earnings today'**
  String get earningsToday;

  /// Label for hours worked
  ///
  /// In en, this message translates to:
  /// **'Hours worked'**
  String get hoursWorked;

  /// Label for in-progress tab
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// Label for completed today tab
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get completedToday;

  /// Status badge for in-progress campaign
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgressStatus;

  /// Label for hours count
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String hoursCount(String count);

  /// Label for progress section
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Label for remaining time
  ///
  /// In en, this message translates to:
  /// **'{time} remaining'**
  String timeRemaining(String time);

  /// Label for completion percentage
  ///
  /// In en, this message translates to:
  /// **'{percentage}% completed'**
  String percentageCompleted(String percentage);

  /// Button text to pause promotion
  ///
  /// In en, this message translates to:
  /// **'Pause promotion'**
  String get pausePromotion;

  /// Message when no campaigns completed today
  ///
  /// In en, this message translates to:
  /// **'No campaigns completed today'**
  String get noCampaignsCompletedToday;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Label for local business
  ///
  /// In en, this message translates to:
  /// **'Local Business'**
  String get localBusiness;

  /// Label for navigation route
  ///
  /// In en, this message translates to:
  /// **'Navigation Route'**
  String get navigationRoute;

  /// Label for campaign audio
  ///
  /// In en, this message translates to:
  /// **'Campaign audio'**
  String get campaignAudio;

  /// Label for next direction
  ///
  /// In en, this message translates to:
  /// **'Next direction'**
  String get nextDirection;

  /// Direction instruction to turn right
  ///
  /// In en, this message translates to:
  /// **'Turn right in {distance} m'**
  String turnRightIn(String distance);

  /// Status label for completed campaign
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStatus;

  /// Label for earned amount
  ///
  /// In en, this message translates to:
  /// **'{amount} earned'**
  String earned(String amount);

  /// Label for completion time
  ///
  /// In en, this message translates to:
  /// **'Completed at {time}'**
  String completedAt(String time);

  /// Button text to view details
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// Title for job details page
  ///
  /// In en, this message translates to:
  /// **'Job details'**
  String get jobDetails;

  /// Subtitle for completed campaign info
  ///
  /// In en, this message translates to:
  /// **'Completed campaign info'**
  String get completedCampaignInfo;

  /// Label for local merchant
  ///
  /// In en, this message translates to:
  /// **'Local merchant'**
  String get localMerchant;

  /// Label for location
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Label for duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Label for completed time
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// Label for customer opinion section
  ///
  /// In en, this message translates to:
  /// **'Customer opinion'**
  String get customerOpinion;

  /// Label for rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Label for comment
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// Message showing campaign closes in X hours
  ///
  /// In en, this message translates to:
  /// **'Closes in {hours} h'**
  String closesInHours(int hours);

  /// Label for accept campaign button
  ///
  /// In en, this message translates to:
  /// **'Accept campaign'**
  String get acceptCampaign;

  /// Message while fetching user location
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get gettingYourLocation;

  /// Error message when location services are disabled
  ///
  /// In en, this message translates to:
  /// **'Location unavailable. Enable location services for nearby campaigns.'**
  String get locationUnavailableEnableServices;

  /// Error message when location permission is denied
  ///
  /// In en, this message translates to:
  /// **'Location permission required for nearby campaigns.'**
  String get locationPermissionRequired;

  /// Success message showing campaigns within radius
  ///
  /// In en, this message translates to:
  /// **'Showing campaigns within 10km of your location'**
  String get showingCampaignsWithinRadius;

  /// Loading message while fetching campaigns
  ///
  /// In en, this message translates to:
  /// **'Loading campaigns...'**
  String get loadingCampaigns;

  /// Button text to view on map
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get viewOnMap;

  /// Distance indicator from user location
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(String distance);

  /// Title for disable 2FA dialog
  ///
  /// In en, this message translates to:
  /// **'Disable 2FA'**
  String get disable2FA;

  /// Message to enter password to disable 2FA
  ///
  /// In en, this message translates to:
  /// **'Enter your password to disable two-factor authentication:'**
  String get enterPasswordToDisable2FA;

  /// Label for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Button text to disable
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// Success message when 2FA is disabled
  ///
  /// In en, this message translates to:
  /// **'2FA Disabled'**
  String get twoFactorAuthDisabled;

  /// Error message when disabling 2FA fails
  ///
  /// In en, this message translates to:
  /// **'Error disabling 2FA: {error}'**
  String errorDisabling2FA(String error);

  /// Label for two-factor authentication
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthentication;

  /// Status label for enabled state
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Status label for disabled state
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Label for authenticator app
  ///
  /// In en, this message translates to:
  /// **'Authenticator App'**
  String get authenticatorApp;

  /// Google Authenticator app name
  ///
  /// In en, this message translates to:
  /// **'Google Authenticator'**
  String get googleAuthenticator;

  /// Label for SMS option
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get sms;

  /// Label for unavailable option
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// Label for recovery codes
  ///
  /// In en, this message translates to:
  /// **'Recovery Codes'**
  String get recoveryCodes;

  /// Description for recovery codes option
  ///
  /// In en, this message translates to:
  /// **'View or regenerate recovery codes'**
  String get viewOrRegenerateRecoveryCodes;

  /// Title asking why enable 2FA
  ///
  /// In en, this message translates to:
  /// **'Why enable two-factor authentication?'**
  String get whyEnable2FA;

  /// Description explaining what 2FA does
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication adds an extra layer of security to your account. In addition to your password, you\'ll need a code generated by your device.'**
  String get twoFactorAuthDescription;

  /// Button text to enable 2FA
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA'**
  String get enable2FA;

  /// Message shown when authenticator is already configured
  ///
  /// In en, this message translates to:
  /// **'Your authenticator app is configured correctly. Use it to generate codes when you sign in.'**
  String get authenticatorConfiguredMessage;

  /// Error title for invalid code
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCode;

  /// Error message for incorrect code
  ///
  /// In en, this message translates to:
  /// **'Incorrect code: {error}'**
  String incorrectCode(String error);

  /// Message to save recovery codes
  ///
  /// In en, this message translates to:
  /// **'Save these codes in a safe place. You\'ll need them if you lose access to your device:'**
  String get saveRecoveryCodesMessage;

  /// Success message when codes are copied
  ///
  /// In en, this message translates to:
  /// **'Codes copied'**
  String get codesCopied;

  /// Button text to copy codes
  ///
  /// In en, this message translates to:
  /// **'Copy codes'**
  String get copyCodes;

  /// Title for 2FA setup page
  ///
  /// In en, this message translates to:
  /// **'Setup 2FA'**
  String get setup2FA;

  /// Error message when setting up 2FA fails
  ///
  /// In en, this message translates to:
  /// **'Error setting up 2FA'**
  String get errorSettingUp2FA;

  /// Generic unknown error message
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Button text to retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Step 1 title for 2FA setup
  ///
  /// In en, this message translates to:
  /// **'Download an authenticator app'**
  String get downloadAuthenticatorApp;

  /// Text before list of recommended apps
  ///
  /// In en, this message translates to:
  /// **'We recommend:'**
  String get weRecommend;

  /// Step 2 title for 2FA setup
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code'**
  String get scanQRCode;

  /// Alternative to scanning QR code
  ///
  /// In en, this message translates to:
  /// **'Or enter this key manually:'**
  String get orEnterKeyManually;

  /// Success message when key is copied
  ///
  /// In en, this message translates to:
  /// **'Key copied'**
  String get keyCopied;

  /// Step 3 title for 2FA setup
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// Instruction to enter 6-digit code
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code that appears in your app:'**
  String get enterSixDigitCode;

  /// Button text to verify and enable 2FA
  ///
  /// In en, this message translates to:
  /// **'Verify and Enable'**
  String get verifyAndEnable;

  /// Microsoft Authenticator app name
  ///
  /// In en, this message translates to:
  /// **'Microsoft Authenticator'**
  String get microsoftAuthenticator;

  /// Authy app name
  ///
  /// In en, this message translates to:
  /// **'Authy'**
  String get authy;

  /// Title for sign up page
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpTitle;

  /// Main heading for sign up page
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// Subtitle for sign up page
  ///
  /// In en, this message translates to:
  /// **'Enter your information to get started'**
  String get signUpSubtitle;

  /// Label for full name field
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// Hint for full name field
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// Validation error for empty name field
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Label for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// Hint for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// Label for role selection
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get selectRole;

  /// Validation error for no role selected
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get roleRequired;

  /// Promoter role option
  ///
  /// In en, this message translates to:
  /// **'Promoter'**
  String get promoter;

  /// Advertiser role option
  ///
  /// In en, this message translates to:
  /// **'Advertiser'**
  String get advertiser;

  /// Description for promoter role
  ///
  /// In en, this message translates to:
  /// **'Earn income by executing sound advertising campaigns'**
  String get promoterRoleDescription;

  /// Description for advertiser role
  ///
  /// In en, this message translates to:
  /// **'Create and manage advertising campaigns'**
  String get advertiserRoleDescription;

  /// Text before login link on sign up page
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Login link text
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// Title for email verification page
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// Subtitle for email verification page
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification code to'**
  String get verifyEmailSubtitle;

  /// Instruction to enter verification code
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code to verify your email:'**
  String get enterVerificationCodeEmail;

  /// Verify button text
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Resend code button text
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// Text before resend code link
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get didntReceiveCode;

  /// Countdown text for resend button
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendInSeconds(int seconds);

  /// Success message when verification code is resent
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get verificationCodeSent;

  /// Success message when email is verified
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully'**
  String get emailVerified;

  /// Error message for invalid verification code
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidVerificationCode;

  /// Error message for expired verification code
  ///
  /// In en, this message translates to:
  /// **'Code has expired. Please request a new one'**
  String get verificationCodeExpired;

  /// Success message after registration
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please verify your email.'**
  String get registrationSuccessful;

  /// Error message for duplicate email
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get emailAlreadyRegistered;

  /// Description for entering 2FA code during login
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your authenticator app to continue signing in.'**
  String get enter2FACodeDescription;

  /// Description for entering recovery code during login
  ///
  /// In en, this message translates to:
  /// **'Enter one of your recovery codes to continue signing in.'**
  String get enterRecoveryCodeDescription;

  /// Label for recovery code input
  ///
  /// In en, this message translates to:
  /// **'Enter your recovery code:'**
  String get enterRecoveryCode;

  /// Validation error for empty recovery code
  ///
  /// In en, this message translates to:
  /// **'Please enter your recovery code'**
  String get pleaseEnterRecoveryCode;

  /// Button text to switch to recovery code mode
  ///
  /// In en, this message translates to:
  /// **'Use a recovery code instead'**
  String get useRecoveryCode;

  /// Button text to switch to authenticator code mode
  ///
  /// In en, this message translates to:
  /// **'Use authenticator code instead'**
  String get useAuthenticatorCode;

  /// Success message after login
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
