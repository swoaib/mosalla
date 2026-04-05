import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/prayer_data.dart';
import '../providers/prayer_time_provider.dart';
import 'monthly_prayer_calendar.dart';

class PrayerTime extends StatelessWidget {
  const PrayerTime({
    super.key,
    required this.prayerData,
    this.activePrayer,
  });

  final PrayerData prayerData;
  final int? activePrayer;

  Widget _buildPrayerTile(BuildContext context, int prayerIndex, String name,
      DateTime? adhanTime, DateTime? jamaatTime,
      {bool isSunrise = false, bool isJumma = false}) {
    Color activeColor = Theme.of(context).primaryColor;
    bool isActive = activePrayer != null && activePrayer == prayerIndex;

    final adhanStr =
        adhanTime == null ? '- -' : DateFormat.Hm().format(adhanTime);
    final jamaatStr =
        jamaatTime == null ? '- -' : DateFormat.Hm().format(jamaatTime);

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textColor: isActive ? Colors.white : null,
      tileColor: isActive ? activeColor : null,
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: SizedBox(
        width: 160,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Adhan Column
            if (!isJumma)
              SizedBox(
                  width: 60,
                  child: Text(adhanStr, textAlign: TextAlign.center)),
            if (!isJumma) const SizedBox(width: 20),

            // Jamaat Column
            SizedBox(
                width: 60,
                child: Text(isSunrise ? ' ' : jamaatStr,
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<PrayerTimeProvider>();
    DateTime date = provider.date;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => provider.changeDate(false),
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
                              const Text('Select Date',
                                  style: TextStyle(
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
                  child: Text(
                    DateFormat.MMMMEEEEd().format(date),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => provider.changeDate(true),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
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
                                    child: Text('Adhan',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600]))),
                                const SizedBox(width: 20),
                                SizedBox(
                                    width: 60,
                                    child: Text('Jamaat',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600]))),
                              ],
                            ),
                          ),
                          _buildPrayerTile(context, 0, 'Fajr', prayerData.fajr,
                              prayerData.fajrJamaat),
                          _buildPrayerTile(
                              context, 1, 'Sunrise', prayerData.sunrise, null,
                              isSunrise: true),
                          _buildPrayerTile(context, 2, 'Duhr', prayerData.duhr,
                              prayerData.duhrJamaat),
                          _buildPrayerTile(context, 3, 'Asr', prayerData.asr,
                              prayerData.asrJamaat),
                          _buildPrayerTile(context, 4, 'Maghrib',
                              prayerData.maghrib, prayerData.maghribJamaat),
                          _buildPrayerTile(context, 5, 'Isha', prayerData.isha,
                              prayerData.ishaJamaat),
                          if (date.weekday == DateTime.friday)
                            _buildPrayerTile(
                                context, 6, 'Jumu\'ah', null, prayerData.jumma,
                                isJumma: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: MonthlyPrayerCalendar(
                            mosallaId: provider.selectedMosallaId,
                            monthYear: provider.date,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.table_chart_outlined),
                    label: const Text('Monthly Table'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.teal[700],
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.teal.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
