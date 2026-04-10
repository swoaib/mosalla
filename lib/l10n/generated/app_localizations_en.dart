// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mosalla';

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get duhr => 'Duhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get jumuah => 'Jumu\'ah';

  @override
  String nextPrayerIn(String prayer) {
    return '$prayer in';
  }

  @override
  String get noMorePrayersToday => 'No more prayers today';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get english => 'English';

  @override
  String get japanese => 'Japanese';

  @override
  String get events => 'Events';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get pastEvents => 'Past Events';

  @override
  String get seeAll => 'See all';

  @override
  String get upcomingEvent => 'Upcoming Event';

  @override
  String get adhan => 'Adhan';

  @override
  String get jamaat => 'Jamaat';

  @override
  String get selectDate => 'Select Date';

  @override
  String get monthlyTable => 'Monthly Table';

  @override
  String get preferences => 'Preferences';

  @override
  String get date => 'Date';

  @override
  String get home => 'Home';

  @override
  String get qibla => 'Qibla';

  @override
  String get library => 'Library';

  @override
  String get qiblaCompass => 'Qibla Compass';

  @override
  String get locationPermissionsDenied => 'Location permissions are denied';

  @override
  String get locationPermissionsPermanentlyDenied =>
      'Location permissions are permanently denied, we cannot request permissions.';

  @override
  String get calibratingCompassLocation => 'Calibrating Compass & Location...';

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String get bearingToMakkah => 'Bearing to Makkah';

  @override
  String get retry => 'Retry';

  @override
  String get map => 'Map';

  @override
  String get hourUnit => 'h';

  @override
  String get minuteUnit => 'm';

  @override
  String get secondUnit => 's';

  @override
  String prayerTimesFor(Object month) {
    return 'Prayer Times for $month';
  }

  @override
  String get nameJapanese => 'Name (Japanese)';

  @override
  String get descriptionJapanese => 'Bio/Description (Japanese)';

  @override
  String get account => 'Account';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get sendPasswordResetEmail => 'Send Password Reset Email';

  @override
  String passwordResetEmailSent(String email) {
    return 'Password reset email sent to $email';
  }

  @override
  String get errorSendingPasswordReset => 'Error sending password reset email';

  @override
  String get northShort => 'N';

  @override
  String get southShort => 'S';

  @override
  String get eastShort => 'E';

  @override
  String get westShort => 'W';

  @override
  String get turnLeft => 'Turn Left';

  @override
  String get turnRight => 'Turn Right';

  @override
  String get facingMakkah => 'Facing Makkah';

  @override
  String get notifications => 'Notifications';

  @override
  String get allNotifications => 'All Notifications';

  @override
  String get prayerTimeNotifications => 'Prayer Time Notifications';

  @override
  String get prayerTimeNotificationsDesc =>
      'Get notified for prayer times at your selected Mosalla';

  @override
  String get eventNotifications => 'Event Notifications';

  @override
  String get eventNotificationsDesc =>
      'Stay updated with new events and announcements';

  @override
  String get appearance => 'Appearance';

  @override
  String get locationStatus => 'Location Status';

  @override
  String get permissionGranted => 'Granted';

  @override
  String get permissionDenied => 'Denied';

  @override
  String get permissions => 'Permissions';

  @override
  String get location => 'Location';
}
