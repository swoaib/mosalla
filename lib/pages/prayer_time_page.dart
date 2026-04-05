import 'package:flutter/material.dart';
import 'package:mosalla/providers/prayer_time_provider.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';

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
    final provider = context.watch<PrayerTimeProvider>();
    final prayerData = provider.prayerData;
    final activePrayer = provider.activePrayer;
    final countDownPrayer = provider.countDownPrayer;
    final endTime = provider.endTime;
    final isLoading = provider.isLoading;
    final selectedMosalla = provider.selectedMosalla;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (provider.mosallas.length > 1)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 4.0),
                        child: DropdownButton<String>(
                          value: provider.selectedMosallaId,
                          icon: const Icon(Icons.arrow_drop_down),
                          underline: Container(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              provider.setSelectedMosalla(newValue);
                            }
                          },
                          items: provider.mosallas
                              .map<DropdownMenuItem<String>>((mosalla) {
                            return DropdownMenuItem<String>(
                              value: mosalla.id,
                              child: Text(mosalla.name.isNotEmpty
                                  ? mosalla.name
                                  : mosalla.id),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        selectedMosalla?.logo != null &&
                                selectedMosalla!.logo!.isNotEmpty
                            ? Image.network(
                                selectedMosalla.logo!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => Image.asset(
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? 'assets/icon/logo_dark.png'
                                        : 'assets/icon/logo.png',
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.contain),
                              )
                            : Image.asset(
                                Theme.of(context).brightness == Brightness.dark
                                    ? 'assets/icon/logo_dark.png'
                                    : 'assets/icon/logo.png',
                                height: 100,
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  child: Text(
                                    countDownPrayer == 0
                                        ? l10n.nextPrayerIn(l10n.fajr)
                                        : countDownPrayer == 1
                                            ? l10n.nextPrayerIn(l10n.sunrise)
                                            : countDownPrayer == 2
                                                ? l10n.nextPrayerIn(l10n.duhr)
                                                : countDownPrayer == 3
                                                    ? l10n.nextPrayerIn(l10n.asr)
                                                    : countDownPrayer == 4
                                                        ? l10n.nextPrayerIn(l10n.maghrib)
                                                        : countDownPrayer == 5
                                                            ? l10n.nextPrayerIn(l10n.isha)
                                                            : countDownPrayer == 6
                                                                ? l10n.nextPrayerIn(l10n.jumuah)
                                                                : selectedMosalla
                                                                            ?.name
                                                                            .isNotEmpty ==
                                                                        true
                                                                    ? selectedMosalla!
                                                                        .name
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
                  ),
                  Expanded(
                    child: PrayerTime(
                      prayerData: prayerData!,
                      activePrayer: activePrayer,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
