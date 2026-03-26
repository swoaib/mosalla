import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:mosalla/providers/prayer_time_provider.dart';
import 'package:provider/provider.dart';

class PrayerCountDown extends StatelessWidget {
  final DateTime? endTime;
  const PrayerCountDown({Key? key, required this.endTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final countDownTomorrow =
        context.watch<PrayerTimeProvider>().countDownTomorrow;
    DateTime? time;
    if (endTime != null) {
      time = DateTime(
          now.year, now.month, now.day, endTime!.hour, endTime!.minute);
    }
    return endTime == null
        ? const Text('No more prayers today')
        : CountdownTimer(
            //textStyle: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.grey[700]),
            onEnd: () {
              // I think the date is one second before end time, for safety we add 10 second even thogh 2 should be enough
              if (countDownTomorrow) {
                context.read<PrayerTimeProvider>().fetchPrayerTimes();
              } else {
                context.read<PrayerTimeProvider>().updateDisplay();
              }
            },
            widgetBuilder: (_, time) => FittedBox(
                child: countDownTomorrow
                    ? const Text('No more prayers today')
                    : Text(
                        '${time!.hours ?? 0}h ${time.min ?? 0}m ${time.sec ?? 0}s',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: Colors.grey[700]))),
            endWidget: const FittedBox(child: Text('No more prayers today')),
            endTime: time!.millisecondsSinceEpoch,
          );
  }
}
