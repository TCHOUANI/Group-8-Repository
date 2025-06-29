 import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SafeRoad Cameroon'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @notificationsHeader.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsHeader;

  /// No description provided for @enableAlerts.
  ///
  /// In en, this message translates to:
  /// **'Enable Alerts'**
  String get enableAlerts;

  /// No description provided for @enableAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive real-time alerts about road conditions'**
  String get enableAlertsSubtitle;

  /// No description provided for @voiceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Voice Alerts'**
  String get voiceAlerts;

  /// No description provided for @voiceAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hear alerts spoken aloud for hands-free awareness'**
  String get voiceAlertsSubtitle;

  /// No description provided for @smsNotifications.
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get smsNotifications;

  /// No description provided for @smsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get alerts via SMS for critical updates'**
  String get smsNotificationsSubtitle;

  /// No description provided for @alertSoundOptions.
  ///
  /// In en, this message translates to:
  /// **'Alert Sound Options'**
  String get alertSoundOptions;

  /// No description provided for @alertSoundOptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a sound for new alert notifications'**
  String get alertSoundOptionsSubtitle;

  /// No description provided for @languageHeader.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageHeader;

  /// No description provided for @languagePreferences.
  ///
  /// In en, this message translates to:
  /// **'Language Preferences'**
  String get languagePreferences;

  /// No description provided for @locationHeader.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationHeader;

  /// No description provided for @gpsAccess.
  ///
  /// In en, this message translates to:
  /// **'GPS Access'**
  String get gpsAccess;

  /// No description provided for @gpsAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow the app to access your GPS location'**
  String get gpsAccessSubtitle;

  /// No description provided for @preferredTravelZones.
  ///
  /// In en, this message translates to:
  /// **'Preferred Travel Zones'**
  String get preferredTravelZones;

  /// No description provided for @preferredTravelZonesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set zones for relevant road condition updates'**
  String get preferredTravelZonesSubtitle;

  /// No description provided for @editProfileHeader.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileHeader;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @privacyPermissionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Permissions'**
  String get privacyPermissionsHeader;

  /// No description provided for @dataUsagePolicy.
  ///
  /// In en, this message translates to:
  /// **'Data Usage Policy'**
  String get dataUsagePolicy;

  /// No description provided for @manageAppPermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage App Permissions'**
  String get manageAppPermissions;

  /// No description provided for @backgroundDataSync.
  ///
  /// In en, this message translates to:
  /// **'Background Data Sync'**
  String get backgroundDataSync;

  /// No description provided for @backgroundDataSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control background data synchronization'**
  String get backgroundDataSyncSubtitle;

  /// No description provided for @helpSupportHeader.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportHeader;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportIssue;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @ewondo.
  ///
  /// In en, this message translates to:
  /// **'Ewondo'**
  String get ewondo;

  /// No description provided for @travelZonesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Travel Zones feature coming soon!'**
  String get travelZonesComingSoon;

  /// No description provided for @dataUsagePolicyComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Data Usage Policy feature coming soon!'**
  String get dataUsagePolicyComingSoon;

  /// No description provided for @managePermissionsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Manage Permissions feature coming soon!'**
  String get managePermissionsComingSoon;

  /// No description provided for @faqComingSoon.
  ///
  /// In en, this message translates to:
  /// **'FAQ feature coming soon!'**
  String get faqComingSoon;

  /// No description provided for @contactSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Contact Support feature coming soon!'**
  String get contactSupportComingSoon;

  /// No description provided for @reportIssueComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Report Issue feature coming soon!'**
  String get reportIssueComingSoon;

  /// No description provided for @alertSoundOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert Sound Options'**
  String get alertSoundOptionsTitle;

  /// No description provided for @defaultSound.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultSound;

  /// No description provided for @chimeSound.
  ///
  /// In en, this message translates to:
  /// **'Chime'**
  String get chimeSound;

  /// No description provided for @bellSound.
  ///
  /// In en, this message translates to:
  /// **'Bell'**
  String get bellSound;

  /// No description provided for @notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationSound;

  /// No description provided for @languagePreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Preferences'**
  String get languagePreferencesTitle;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutTitle;

  /// No description provided for @signOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @signedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get signedOutSuccessfully;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to '**
  String get welcomeTo;

  /// No description provided for @yourSmartRoadCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your Smart Road Companion for Safer Travel'**
  String get yourSmartRoadCompanion;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  // MISSING GETTERS THAT YOUR SETTINGS PAGE NEEDS:

  /// User Preferences Section
  String get userPreferencesHeader;
  String get editProfileSubtitle;
  String get language;
  String get alertType;
  String get selectLanguage;

  /// Permissions Section
  String get permissionsHeader;

  /// Safety Features Section
  String get safetyFeaturesHeader;
  String get roadHazardAlerts;
  String get roadHazardAlertsSubtitle;
  String get locationTracking;
  String get locationTrackingSubtitle;
  String get roadSignTips;
  String get roadSignTipsSubtitle;

  /// Account Actions Section
  String get accountActionsHeader;
  String get privacyPolicy;
  String get privacyPolicySubtitle;
  String get termsOfService;
  String get termsOfServiceSubtitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}