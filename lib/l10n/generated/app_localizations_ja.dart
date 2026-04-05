// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'モサッラ';

  @override
  String get prayerTimes => '礼拝時間';

  @override
  String get fajr => 'ファジュル';

  @override
  String get sunrise => '日の出';

  @override
  String get duhr => 'ズフル';

  @override
  String get asr => 'アスル';

  @override
  String get maghrib => 'マグリブ';

  @override
  String get isha => 'イシャー';

  @override
  String get jumuah => 'ジュムア';

  @override
  String nextPrayerIn(String prayer) {
    return '$prayer まで';
  }

  @override
  String get noMorePrayersToday => '今日の祈りは終了しました';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get systemDefault => 'システム設定';

  @override
  String get english => '英語';

  @override
  String get japanese => '日本語';

  @override
  String get adhan => 'アザーン';

  @override
  String get jamaat => 'ジャマア';

  @override
  String get selectDate => '日付を選択';

  @override
  String get monthlyTable => '月間スケジュール';

  @override
  String get preferences => '詳細設定';

  @override
  String get date => '日付';

  @override
  String get home => 'ホーム';

  @override
  String get qibla => 'キブラ';

  @override
  String get library => 'ライブラリ';

  @override
  String get qiblaCompass => 'キブラコンパス';

  @override
  String get locationPermissionsDenied => '位置情報の権限が拒否されました';

  @override
  String get locationPermissionsPermanentlyDenied =>
      '位置情報の権限が永久に拒否されています。設定から許可してください。';

  @override
  String get calibratingCompassLocation => 'コンパスと位置情報を調整中...';

  @override
  String get qiblaDirection => 'キブラの方向';

  @override
  String get bearingToMakkah => 'メッカへの方位';

  @override
  String get retry => '再試行';
}
