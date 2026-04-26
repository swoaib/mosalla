import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ja')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mosalla'**
  String get appTitle;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @duhr.
  ///
  /// In en, this message translates to:
  /// **'Duhr'**
  String get duhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @jumuah.
  ///
  /// In en, this message translates to:
  /// **'Jumu\'ah'**
  String get jumuah;

  /// No description provided for @nextPrayerIn.
  ///
  /// In en, this message translates to:
  /// **'{prayer} in'**
  String nextPrayerIn(String prayer);

  /// No description provided for @noMorePrayersToday.
  ///
  /// In en, this message translates to:
  /// **'No more prayers today'**
  String get noMorePrayersToday;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @pastEvents.
  ///
  /// In en, this message translates to:
  /// **'Past Events'**
  String get pastEvents;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @upcomingEvent.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Event'**
  String get upcomingEvent;

  /// No description provided for @adhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get adhan;

  /// No description provided for @jamaat.
  ///
  /// In en, this message translates to:
  /// **'Jamaat'**
  String get jamaat;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @monthlyTable.
  ///
  /// In en, this message translates to:
  /// **'Monthly Table'**
  String get monthlyTable;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @qiblaCompass.
  ///
  /// In en, this message translates to:
  /// **'Qibla Compass'**
  String get qiblaCompass;

  /// No description provided for @locationPermissionsDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied'**
  String get locationPermissionsDenied;

  /// No description provided for @locationPermissionsPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied, we cannot request permissions.'**
  String get locationPermissionsPermanentlyDenied;

  /// No description provided for @calibratingCompassLocation.
  ///
  /// In en, this message translates to:
  /// **'Calibrating Compass & Location...'**
  String get calibratingCompassLocation;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @bearingToMakkah.
  ///
  /// In en, this message translates to:
  /// **'Bearing to Makkah'**
  String get bearingToMakkah;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @hourUnit.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hourUnit;

  /// No description provided for @minuteUnit.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minuteUnit;

  /// No description provided for @secondUnit.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get secondUnit;

  /// No description provided for @prayerTimesFor.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times for {month}'**
  String prayerTimesFor(Object month);

  /// No description provided for @nameJapanese.
  ///
  /// In en, this message translates to:
  /// **'Name (Japanese)'**
  String get nameJapanese;

  /// No description provided for @descriptionJapanese.
  ///
  /// In en, this message translates to:
  /// **'Bio/Description (Japanese)'**
  String get descriptionJapanese;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @sendPasswordResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Password Reset Email'**
  String get sendPasswordResetEmail;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}'**
  String passwordResetEmailSent(String email);

  /// No description provided for @errorSendingPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Error sending password reset email'**
  String get errorSendingPasswordReset;

  /// No description provided for @northShort.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get northShort;

  /// No description provided for @southShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get southShort;

  /// No description provided for @eastShort.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get eastShort;

  /// No description provided for @westShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get westShort;

  /// No description provided for @turnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn Left'**
  String get turnLeft;

  /// No description provided for @turnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn Right'**
  String get turnRight;

  /// No description provided for @facingMakkah.
  ///
  /// In en, this message translates to:
  /// **'Facing Makkah'**
  String get facingMakkah;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All Notifications'**
  String get allNotifications;

  /// No description provided for @prayerTimeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time Notifications'**
  String get prayerTimeNotifications;

  /// No description provided for @prayerTimeNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified for prayer times at your selected Mosalla'**
  String get prayerTimeNotificationsDesc;

  /// No description provided for @eventNotifications.
  ///
  /// In en, this message translates to:
  /// **'Event Notifications'**
  String get eventNotifications;

  /// No description provided for @eventNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with new events and announcements'**
  String get eventNotificationsDesc;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @locationStatus.
  ///
  /// In en, this message translates to:
  /// **'Location Status'**
  String get locationStatus;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Disabled in settings'**
  String get permissionDenied;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @locationSettings.
  ///
  /// In en, this message translates to:
  /// **'Location Settings'**
  String get locationSettings;

  /// No description provided for @locationAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Location access is required for accurate prayer times and qibla direction.'**
  String get locationAccessRequired;

  /// No description provided for @notificationAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification access is required to receive prayer and event alerts.'**
  String get notificationAccessRequired;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events scheduled'**
  String get noUpcomingEvents;

  /// No description provided for @noPastEvents.
  ///
  /// In en, this message translates to:
  /// **'No past events'**
  String get noPastEvents;

  /// No description provided for @noUpcomingEventsAdmin.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events scheduled. Click + to add one.'**
  String get noUpcomingEventsAdmin;

  /// No description provided for @noPastEventsAdmin.
  ///
  /// In en, this message translates to:
  /// **'No past events found.'**
  String get noPastEventsAdmin;

  /// No description provided for @eventCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get eventCancelled;

  /// No description provided for @notificationUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update notification settings. Please check your internet connection.'**
  String get notificationUpdateError;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackSentimentTitle.
  ///
  /// In en, this message translates to:
  /// **'How is your experience?'**
  String get feedbackSentimentTitle;

  /// No description provided for @feedbackSentimentSad.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get feedbackSentimentSad;

  /// No description provided for @feedbackSentimentNeutral.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get feedbackSentimentNeutral;

  /// No description provided for @feedbackSentimentHappy.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get feedbackSentimentHappy;

  /// No description provided for @feedbackImprovementTitle.
  ///
  /// In en, this message translates to:
  /// **'How can we improve?'**
  String get feedbackImprovementTitle;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you think...'**
  String get feedbackHint;

  /// No description provided for @feedbackOptionalEmail.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get feedbackOptionalEmail;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackThanks;

  /// No description provided for @feedbackError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit feedback. Try again.'**
  String get feedbackError;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reviewAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Mosalla?'**
  String get reviewAlertTitle;

  /// No description provided for @reviewAlertBody.
  ///
  /// In en, this message translates to:
  /// **'Please take a moment to review us on the App Store.'**
  String get reviewAlertBody;

  /// No description provided for @reviewAlertAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewAlertAction;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @addYourMosque.
  ///
  /// In en, this message translates to:
  /// **'Add your Mosque'**
  String get addYourMosque;
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
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
