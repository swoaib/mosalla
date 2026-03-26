import 'package:flutter/material.dart';
import 'package:mosalla/providers/prayer_time_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/prayer_countdown.dart';
import '../widgets/prayer_time.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({Key? key}) : super(key: key);

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    context.read<PrayerTimeProvider>().fetchPrayerTimes();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (AppLifecycleState.resumed == state) {
      context.read<PrayerTimeProvider>().updateDisplay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayerData = context.watch<PrayerTimeProvider>().prayerData;
    final activePrayer = context.watch<PrayerTimeProvider>().activePrayer;
    final countDownPrayer = context.watch<PrayerTimeProvider>().countDownPrayer;
    final endTime = context.watch<PrayerTimeProvider>().endTime;
    final isLoading = context.watch<PrayerTimeProvider>().isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // decoration: const BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage("assets/images/bg.jpeg"),
              //     fit: BoxFit.cover,
              //   ),
              // ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 190,
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  child: Text(
                                    countDownPrayer == 0
                                        ? 'Fajr Jamaat in'
                                        : countDownPrayer == 1
                                            ? 'Sunrise in'
                                            : countDownPrayer == 2
                                                ? 'Duhr Jamaat in'
                                                : countDownPrayer == 3
                                                    ? 'Asr Jamaat in'
                                                    : countDownPrayer == 4
                                                        ? 'Maghrib Jamaat in'
                                                        : countDownPrayer == 5
                                                            ? 'Isha Jamaat in'
                                                            : countDownPrayer ==
                                                                    6
                                                                ? 'Jumu‘ah Jamaat in'
                                                                : 'Mosalla',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                PrayerCountDown(
                                  endTime: endTime,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: PrayerTime(
                        prayerData: prayerData!,
                        activePrayer: activePrayer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
