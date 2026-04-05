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
}
