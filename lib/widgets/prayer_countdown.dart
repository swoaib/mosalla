import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:mosalla/providers/prayer_time_provider.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';

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

    return widget.endTime == null
        ? Text(l10n.noMorePrayersToday)
        : CountdownTimer(
            onEnd: () {
              // Safety: Ensure widget is still mounted before accessing context for Provider usage
              if (!mounted) return;

              if (countDownTomorrow) {
                context.read<PrayerTimeProvider>().fetchPrayerTimes();
              } else {
                context.read<PrayerTimeProvider>().updateDisplay();
              }
            },
            widgetBuilder: (_, time) => FittedBox(
                child: Text(
                    '${time?.hours ?? 0}h ${time?.min ?? 0}m ${time?.sec ?? 0}s',
                    style: (Theme.of(context).textTheme.headlineSmall ??
                            const TextStyle())
                        .copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500))),
            endWidget: FittedBox(child: Text(l10n.noMorePrayersToday)),
            endTime: time?.millisecondsSinceEpoch ?? 0,
          );
  }
}
