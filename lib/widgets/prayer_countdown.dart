import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:mosalla/providers/prayer_time_provider.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';

import '../providers/theme_provider.dart';

class PrayerCountDown extends StatefulWidget {
  final DateTime? endTime;
  const PrayerCountDown({Key? key, required this.endTime}) : super(key: key);

  @override
  State<PrayerCountDown> createState() => _PrayerCountDownState();
}

class _PrayerCountDownState extends State<PrayerCountDown> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final countDownTomorrow =
        context.watch<PrayerTimeProvider>().countDownTomorrow;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    DateTime? time;
    if (widget.endTime != null) {
      time = DateTime(now.year, now.month, now.day, widget.endTime!.hour,
          widget.endTime!.minute);
      if (countDownTomorrow) {
        time = time.add(const Duration(days: 1));
      }
    }

    final themeProvider = Provider.of<ThemeProvider?>(context);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final isTealTheme = (themeProvider?.isTealTheme ?? false) ||
        scaffoldBg == Colors.teal ||
        scaffoldBg == const Color(0xFF00695C);
    final isDarkBg =
        ThemeData.estimateBrightnessForColor(scaffoldBg) == Brightness.dark ||
            isTealTheme;

    return widget.endTime == null
        ? Text(l10n.noMorePrayersToday,
            style: TextStyle(color: isDarkBg ? Colors.white70 : null))
        : CountdownTimer(
            onEnd: () {
              // Safety: Ensure widget is still mounted before accessing context for Provider usage
              if (!mounted) return;

              context
                  .read<PrayerTimeProvider>()
                  .updateDisplay(isFromTimer: true);
            },
            widgetBuilder: (_, time) => FittedBox(
                child: Text(
                    '${time?.hours ?? 0}${l10n.hourUnit} ${time?.min ?? 0}${l10n.minuteUnit} ${time?.sec ?? 0}${l10n.secondUnit}',
                    style: (Theme.of(context).textTheme.headlineSmall ??
                            const TextStyle())
                        .copyWith(
                            color: isDarkBg ? Colors.white70 : Colors.grey[700],
                            fontWeight: FontWeight.w500))),
            endWidget: FittedBox(
                child: Text(l10n.noMorePrayersToday,
                    style: TextStyle(color: isDarkBg ? Colors.white70 : null))),
            endTime: time?.millisecondsSinceEpoch ?? 0,
          );
  }
}
