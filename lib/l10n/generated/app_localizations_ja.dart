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
  String get theme => 'テーマ';

  @override
  String get light => 'ライトモード';

  @override
  String get dark => 'ダークモード';

  @override
  String get english => '英語';

  @override
  String get japanese => '日本語';

  @override
  String get events => 'イベント';

  @override
  String get upcomingEvents => '今後のイベント';

  @override
  String get pastEvents => '過去のイベント';

  @override
  String get seeAll => '全て表示';

  @override
  String get upcomingEvent => '次のイベント';

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

  @override
  String get map => 'マップ';

  @override
  String get hourUnit => '時';

  @override
  String get minuteUnit => '分';

  @override
  String get secondUnit => '秒';

  @override
  String prayerTimesFor(Object month) {
    return '$month の礼拝時間';
  }

  @override
  String get nameJapanese => '名前 (日本語)';

  @override
  String get descriptionJapanese => '説明 (日本語)';

  @override
  String get account => 'アカウント';

  @override
  String get resetPassword => 'パスワードのリセット';

  @override
  String get sendPasswordResetEmail => 'パスワードリセットメールを送信';

  @override
  String passwordResetEmailSent(String email) {
    return 'パスワードリセットメールを $email に送信しました';
  }

  @override
  String get errorSendingPasswordReset => 'パスワードリセットメールの送信中にエラーが発生しました';

  @override
  String get northShort => '北';

  @override
  String get southShort => '南';

  @override
  String get eastShort => '東';

  @override
  String get westShort => '西';

  @override
  String get turnLeft => '左に回す';

  @override
  String get turnRight => '右に回す';

  @override
  String get facingMakkah => 'メッカの方向です';
}
