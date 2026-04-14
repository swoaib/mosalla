// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ムサラー';

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

  @override
  String get notifications => '通知';

  @override
  String get allNotifications => '全ての通知';

  @override
  String get prayerTimeNotifications => '礼拝時間の通知';

  @override
  String get prayerTimeNotificationsDesc => '選択したムサラーの礼拝時間の通知を受け取ります';

  @override
  String get eventNotifications => 'イベントの通知';

  @override
  String get eventNotificationsDesc => '新しいイベントや重要なお知らせを受け取ります';

  @override
  String get appearance => '外観';

  @override
  String get locationStatus => '位置情報の権限';

  @override
  String get permissionGranted => '有効';

  @override
  String get permissionDenied => '設定で無効になっています';

  @override
  String get permissions => '権限';

  @override
  String get location => '位置情報';

  @override
  String get enabled => '有効';

  @override
  String get disabled => '無効';

  @override
  String get openSettings => '設定を開く';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get locationSettings => '位置情報設定';

  @override
  String get locationAccessRequired => '正確な礼拝時間とキブラ方向のために位置情報のアクセスが必要です。';

  @override
  String get notificationAccessRequired => '礼拝やイベントの通知を受け取るために通知のアクセスが必要です。';

  @override
  String get getDirections => '経路';

  @override
  String get noUpcomingEvents => '予定されているイベントはありません';

  @override
  String get noPastEvents => '過去のイベントはありません';

  @override
  String get noUpcomingEventsAdmin => '予定されているイベントはありません。「+」をクリックして追加してください。';

  @override
  String get noPastEventsAdmin => '過去のイベントは見つかりませんでした。';
}
