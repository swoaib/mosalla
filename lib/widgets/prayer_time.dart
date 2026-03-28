import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:mosalla/model/prayer_data.dart';
import 'package:mosalla/providers/prayer_time_provider.dart';
import 'package:provider/provider.dart';

class PrayerTime extends StatelessWidget {
  final PrayerData prayerData;
  final int? activePrayer;
  final activeColor = Colors.teal[300];

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
      const ListTile(
        minVerticalPadding: 0,
          //dense: true,
          //onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Time left'))),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mosque_rounded),
              SizedBox(width: 10),
              Text('Prayers'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Jamaat'),
              SizedBox(width: 10),
              Icon(Icons.access_time_outlined),
            ],
          )),
      Expanded(
        child: SingleChildScrollView(
          child: Card(
            elevation: 0,
            color: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
          children: [
            ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                textColor: activePrayer != null && activePrayer == 0
                    ? Colors.white
                    : null,
                tileColor: activePrayer != null && activePrayer == 0
                    ? activeColor
                    : null, // Colors.teal[50],
                leading: const Text('الفجر'),
                title: const Text('Fajr'),
                trailing: Text(prayerData.fajr == null
                    ? '- -'
                    : DateFormat.Hm().format(prayerData.fajr!))),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                textColor: activePrayer != null && activePrayer == 1
                    ? Colors.white
                    : null,
                tileColor: activePrayer != null && activePrayer == 1
                    ? activeColor
                    : null, // Colors.teal[50],
                leading: const Text('الشروق'),
                title: const Text('Sunrise'),
                trailing: Text(prayerData.sunrise == null
                    ? '- -'
                    : DateFormat.Hm().format(prayerData.sunrise!))),
            ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                textColor: activePrayer != null && activePrayer == 2
                    ? Colors.white
                    : null,
                tileColor: activePrayer != null && activePrayer == 2
                    ? activeColor
                    : null, // Colors.teal[50],
                leading: const Text('لظهر'),
                title: const Text('Duhr'),
                trailing: Text(prayerData.duhr == null
                    ? '- -'
                    : DateFormat.Hm().format(prayerData.duhr!))),
            ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                textColor: activePrayer != null && activePrayer == 3
                    ? Colors.white
                    : null,
                tileColor: activePrayer != null && activePrayer == 3
                    ? activeColor
                    : null, // Colors.teal[50],
                leading: const Text('لعصر'),
                title: const Text('Asr'),
                trailing: Text(prayerData.asr == null
                    ? '- -'
                    : DateFormat.Hm().format(prayerData.asr!))),
            ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                textColor: activePrayer != null && activePrayer == 4
                    ? Colors.white
                    : null,
                tileColor: activePrayer != null && activePrayer == 4
                    ? activeColor
                    : null, // Colors.teal[50],
                leading: const Text('المغرب'),
                title: const Text('Maghrib'),
                trailing: Text(prayerData.maghrib == null
                    ? '- -'
                    : DateFormat.Hm().format(prayerData.maghrib!))),
            ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                textColor: activePrayer != null && activePrayer == 5
                    ? Colors.white
                    : null,
                tileColor: activePrayer != null && activePrayer == 5
                    ? activeColor
                    : null, // Colors.teal[50],
                leading: const Text('العشاء'),
                title: const Text('Isha'),
                trailing: Text(prayerData.isha == null
                    ? '- -'
                    : DateFormat.Hm().format(prayerData.isha!))),
            ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                textColor: activePrayer != null && activePrayer == 6
                    ? Colors.white
                    : null,
                tileColor: activePrayer != null && activePrayer == 6
                    ? activeColor
                    : null,     
                leading: const Text('الجمعة'),
                title: const Text('Jumu‘ah'),
                trailing: Text(prayerData.jumma == null
                    ? '- -'
                    : DateFormat.Hm().format(prayerData.jumma!))),
              ],
            ),
          ),
        ),
      ),
      ListTile(
        //dense: true,
        //onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Time left'))),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.date_range_rounded),
            const SizedBox(width: 10),
            Text(DateFormat.MMMMd().format(date)),
          ],
        ),
        trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mosalla?.location.isNotEmpty == true 
                    ? mosalla!.location 
                    : (mosalla?.name.isNotEmpty == true ? mosalla!.name : 'Mosalla'),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.place_rounded),
            ],
          ),
      )
      // trailing: Row(
      //   mainAxisSize: MainAxisSize.min,
      //   children: const [
      //     Text('Jamaat'),
      //     SizedBox(width: 10),
      //     Icon(Icons.access_time_outlined),
      //   ],
      // )),
    ]);
  }
}
