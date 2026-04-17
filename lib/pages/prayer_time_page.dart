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
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.isError || prayerData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(l10n.bearingToMakkah.isEmpty
                          ? 'Error loading data'
                          : 'Error loading prayer times'), // Fallback or hardcoded
                      ElevatedButton(
                        onPressed: () => provider.fetchPrayerTimes(),
                        child: Text(l10n.retry),
                      )
                    ],
                  ),
                )
              : SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        if (provider.mosallas.length > 1)
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 16.0, top: 4.0),
                              child: PopupMenuButton<String>(
                                onSelected: (String newValue) {
                                  provider.setSelectedMosalla(newValue);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                itemBuilder: (BuildContext context) {
                                  return provider.mosallas
                                      .map<PopupMenuEntry<String>>((mosalla) {
                                    return PopupMenuItem<String>(
                                      value: mosalla.id,
                                      child: Text(mosalla.localizedName(l10n.localeName).isNotEmpty
                                          ? mosalla.localizedName(l10n.localeName)
                                          : mosalla.id),
                                    );
                                  }).toList();
                                },
                                child: OutlinedButton(
                                  onPressed:
                                      null, // Tap handled by PopupMenuButton
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).primaryColor,
                                    disabledForegroundColor:
                                        Theme.of(context).primaryColor,
                                    side: BorderSide(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.5),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 0),
                                    minimumSize: const Size(0, 32),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        selectedMosalla?.localizedName(l10n.localeName).isNotEmpty == true
                                            ? selectedMosalla!.localizedName(l10n.localeName)
                                            : provider.selectedMosallaId,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Icon(Icons.arrow_drop_down, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 16),
                              selectedMosalla?.logo != null &&
                                      selectedMosalla!.logo!.isNotEmpty
                                  ? Image.network(
                                      selectedMosalla.logo!,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => Image.asset(
                                          'assets/icon/logo_dark.png',
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.contain),
                                    )
                                  : Image.asset(
                                      'assets/icon/logo_dark.png',
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
                                                  ? l10n
                                                      .nextPrayerIn(l10n.sunrise)
                                                  : countDownPrayer == 2
                                                      ? l10n
                                                          .nextPrayerIn(l10n.duhr)
                                                      : countDownPrayer == 3
                                                          ? l10n.nextPrayerIn(
                                                              l10n.asr)
                                                          : countDownPrayer == 4
                                                              ? l10n.nextPrayerIn(
                                                                  l10n.maghrib)
                                                              : countDownPrayer ==
                                                                      5
                                                                  ? l10n.nextPrayerIn(
                                                                      l10n.isha)
                                                                  : countDownPrayer ==
                                                                          6
                                                                      ? l10n.nextPrayerIn(l10n
                                                                          .jumuah)
                                                                      : selectedMosalla?.name.isNotEmpty ==
                                                                              true
                                                                          ? selectedMosalla!
                                                                              .name
                                                                          : 'Mosalla',
                                          style: (Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium ??
                                                  const TextStyle())
                                              .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor),
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
                          child: SingleChildScrollView(
                            key: const PageStorageKey<String>('prayer_time_scroll'),
                            child: PrayerTime(
                              prayerData: prayerData,
                              activePrayer: activePrayer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
    );
  }
}
