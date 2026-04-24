import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../model/prayer_data.dart';
import '../pages/events_page.dart';
import '../providers/prayer_time_provider.dart';
import 'monthly_prayer_calendar.dart';
import 'custom_bottom_navigation_bar.dart';

class PrayerTime extends StatelessWidget {
  const PrayerTime({
    super.key,
    required this.prayerData,
    this.activePrayer,
  });

  final PrayerData prayerData;
  final int? activePrayer;

  Widget _buildPrayerTile(BuildContext context, int prayerIndex, String name,
      IconData icon, DateTime? adhanTime, DateTime? jamaatTime,
      {bool isSunrise = false,
      bool isJumma = false,
      DateTime? jamaatTime2,
      DateTime? jamaatTime3}) {
    final locale = Localizations.localeOf(context).languageCode;
    Color activeColor = Theme.of(context).primaryColor;
    bool isActive = activePrayer != null && activePrayer == prayerIndex;

    final adhanStr =
        adhanTime == null ? '- -' : DateFormat.Hm(locale).format(adhanTime);
    List<String> jamaatTimes = [];
    if (jamaatTime != null) {
      jamaatTimes.add(DateFormat.Hm(locale).format(jamaatTime));
    }
    if (jamaatTime2 != null) {
      jamaatTimes.add(DateFormat.Hm(locale).format(jamaatTime2));
    }
    if (jamaatTime3 != null) {
      jamaatTimes.add(DateFormat.Hm(locale).format(jamaatTime3));
    }
    String jamaatStr = jamaatTimes.isEmpty ? '- -' : jamaatTimes.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? activeColor : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey[700],
            size: 20,
          ),
          const SizedBox(width: 16),
          Text(name, style: TextStyle(fontWeight: FontWeight.w500, color: isActive ? Colors.white : null)),
          const SizedBox(width: 16),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Adhan Column
                if (!isJumma)
                  SizedBox(
                      width: 60,
                      child: Text(adhanStr, textAlign: TextAlign.center, style: TextStyle(color: isActive ? Colors.white : null))),
                if (!isJumma) const SizedBox(width: 20),

            // Jamaat Column
            Flexible(
              child: SizedBox(
                  width: isJumma ? null : 60,
                  child: isJumma && !isSunrise && jamaatTimes.isNotEmpty
                      ? Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 6,
                          runSpacing: 4,
                          children: jamaatTimes
                              .map((t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(t,
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.white
                                              : null,
                                        )),
                                  ))
                              .toList(),
                        )
                      : Text(isSunrise ? ' ' : jamaatStr,
                          textAlign: TextAlign.center, style: TextStyle(color: isActive ? Colors.white : null))),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<PrayerTimeProvider>();
    DateTime date = provider.date;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filled(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => provider.changeDate(false),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            children: [
                              Text(l10n.selectDate,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Expanded(
                                child: CalendarDatePicker(
                                  initialDate: date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  onDateChanged: (newDate) {
                                    provider.fetchPrayerTimes(newDate: newDate);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.MMMMEEEEd(
                                Localizations.localeOf(context).languageCode)
                            .format(date),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (() {
                          final languageCode =
                              Localizations.localeOf(context).languageCode;
                          // hijri package (3.0.0) only supports ar, en, id, tr, pt.
                          // Setting it to 'ja' or other unsupported locales throws an exception.
                          const supportedHijriLocales = [
                            'ar',
                            'en',
                            'id',
                            'tr',
                            'pt'
                          ];
                          final hijriLocale =
                              supportedHijriLocales.contains(languageCode)
                                  ? languageCode
                                  : 'en';
                          HijriCalendar.setLocal(hijriLocale);
                          return HijriCalendar.fromDate(date)
                              .toFormat("dd MMMM yyyy");
                        })(),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => provider.changeDate(true),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const PageStorageKey<String>('prayer_time_scroll'),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: CustomBottomNavigationBar.contentBottomPadding +
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 20.0, top: 16.0, bottom: 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                      width: 60,
                                      child: Text(l10n.adhan,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600]))),
                                  const SizedBox(width: 20),
                                  SizedBox(
                                      width: 60,
                                      child: Text(l10n.jamaat,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600]))),
                                ],
                              ),
                            ),
                            _buildPrayerTile(
                                context,
                                0,
                                l10n.fajr,
                                LucideIcons.moonStar,
                                prayerData.fajr,
                                prayerData.fajrJamaat),
                            _buildPrayerTile(context, 1, l10n.sunrise,
                                LucideIcons.sunrise, prayerData.sunrise, null,
                                isSunrise: true),
                            _buildPrayerTile(
                                context,
                                2,
                                l10n.duhr,
                                LucideIcons.sun,
                                prayerData.duhr,
                                prayerData.duhrJamaat),
                            _buildPrayerTile(
                                context,
                                3,
                                l10n.asr,
                                LucideIcons.cloudSun,
                                prayerData.asr,
                                prayerData.asrJamaat),
                            _buildPrayerTile(
                                context,
                                4,
                                l10n.maghrib,
                                LucideIcons.sunset,
                                prayerData.maghrib,
                                prayerData.maghribJamaat),
                            _buildPrayerTile(
                                context,
                                5,
                                l10n.isha,
                                LucideIcons.moon,
                                prayerData.isha,
                                prayerData.ishaJamaat),
                            if (date.weekday == DateTime.friday)
                              _buildPrayerTile(context, 6, l10n.jumuah,
                                  Icons.mosque_outlined, null, prayerData.jumma,
                                  isJumma: true,
                                  jamaatTime2: prayerData.jumma2,
                                  jamaatTime3: prayerData.jumma3),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  child: MonthlyPrayerCalendar(
                                    mosallaId: provider.selectedMosallaId,
                                    monthYear: provider.date,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.table_chart_outlined),
                            label: Text(l10n.monthlyTable),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.teal[700],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor:
                                  Colors.teal.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const EventsPage()),
                              );
                            },
                            icon: const Icon(Icons.event_outlined),
                            label: Text(l10n.events),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.teal[700],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor:
                                  Colors.teal.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
