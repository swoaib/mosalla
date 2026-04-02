import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:mosalla/model/prayer_data.dart';
import 'package:mosalla/providers/prayer_time_provider.dart';
import 'package:provider/provider.dart';

class PrayerTime extends StatelessWidget {
  final PrayerData prayerData;
  final int? activePrayer;
  final activeColor = Colors.teal[500];

  PrayerTime({
    Key? key,
    required this.prayerData,
    required this.activePrayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();
    final date = provider.date;
    final mosalla = provider.selectedMosalla;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => provider.changeDate(false),
            ),
            Text(
              DateFormat.MMMMd().format(date),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textColor: activePrayer != null && activePrayer == 0
                          ? Colors.white
                          : null,
                      tileColor: activePrayer != null && activePrayer == 0
                          ? activeColor
                          : null, // Colors.teal[50],
                      //leading: const Text('الفجر'),
                      title: const Text('Fajr'),
                      trailing: Text(prayerData.fajr == null
                          ? '- -'
                          : DateFormat.Hm().format(prayerData.fajr!))),
                  ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textColor: activePrayer != null && activePrayer == 1
                          ? Colors.white
                          : null,
                      tileColor: activePrayer != null && activePrayer == 1
                          ? activeColor
                          : null, // Colors.teal[50],
                      //leading: const Text('الشروق'),
                      title: const Text('Sunrise'),
                      trailing: Text(prayerData.sunrise == null
                          ? '- -'
                          : DateFormat.Hm().format(prayerData.sunrise!))),
                  ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textColor: activePrayer != null && activePrayer == 2
                          ? Colors.white
                          : null,
                      tileColor: activePrayer != null && activePrayer == 2
                          ? activeColor
                          : null, // Colors.teal[50],
                      //leading: const Text('لظهر'),
                      title: const Text('Duhr'),
                      trailing: Text(prayerData.duhr == null
                          ? '- -'
                          : DateFormat.Hm().format(prayerData.duhr!))),
                  ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textColor: activePrayer != null && activePrayer == 3
                          ? Colors.white
                          : null,
                      tileColor: activePrayer != null && activePrayer == 3
                          ? activeColor
                          : null, // Colors.teal[50],
                      //leading: const Text('لعصر'),
                      title: const Text('Asr'),
                      trailing: Text(prayerData.asr == null
                          ? '- -'
                          : DateFormat.Hm().format(prayerData.asr!))),
                  ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textColor: activePrayer != null && activePrayer == 4
                          ? Colors.white
                          : null,
                      tileColor: activePrayer != null && activePrayer == 4
                          ? activeColor
                          : null, // Colors.teal[50],
                      //leading: const Text('المغرب'),
                      title: const Text('Maghrib'),
                      trailing: Text(prayerData.maghrib == null
                          ? '- -'
                          : DateFormat.Hm().format(prayerData.maghrib!))),
                  ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textColor: activePrayer != null && activePrayer == 5
                          ? Colors.white
                          : null,
                      tileColor: activePrayer != null && activePrayer == 5
                          ? activeColor
                          : null, // Colors.teal[50],
                      //leading: const Text('العشاء'),
                      title: const Text('Isha'),
                      trailing: Text(prayerData.isha == null
                          ? '- -'
                          : DateFormat.Hm().format(prayerData.isha!))),
                  ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textColor: activePrayer != null && activePrayer == 6
                          ? Colors.white
                          : null,
                      tileColor: activePrayer != null && activePrayer == 6
                          ? activeColor
                          : null,
                      //leading: const Text('الجمعة'),
                      title: const Text('Jumu‘ah'),
                      trailing: Text(prayerData.jumma == null
                          ? '- -'
                          : DateFormat.Hm().format(prayerData.jumma!))),
                ],
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.place_rounded),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                mosalla?.location.isNotEmpty == true
                    ? mosalla!.location
                    : (mosalla?.name.isNotEmpty == true
                        ? mosalla!.name
                        : 'Mosalla'),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      )
    ]);
  }
}
