import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';

import '../model/prayer_data.dart';
import '../repositories/mosalla_repository.dart';

class MonthlyPrayerCalendar extends StatefulWidget {
  final String mosallaId;
  final DateTime monthYear;

  const MonthlyPrayerCalendar({
    Key? key,
    required this.mosallaId,
    required this.monthYear,
  }) : super(key: key);

  @override
  State<MonthlyPrayerCalendar> createState() => _MonthlyPrayerCalendarState();
}

class _MonthlyPrayerCalendarState extends State<MonthlyPrayerCalendar> {
  bool _isLoading = true;
  late int _daysInMonth;
  late List<PrayerData?> _monthData;

  @override
  void initState() {
    super.initState();
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    setState(() => _isLoading = true);

    final year = widget.monthYear.year;
    final month = widget.monthYear.month;
    _daysInMonth = DateUtils.getDaysInMonth(year, month);
    _monthData = List.filled(_daysInMonth, null);

    try {
      final futures = <Future>[];
      final monthStr = DateFormat('MM-yyyy').format(widget.monthYear);
      final repo = context.read<MosallaRepository>();

      for (int i = 1; i <= _daysInMonth; i++) {
        final dayStr = i.toString().padLeft(2, '0');
        final docId = '$dayStr-$monthStr';

        futures.add(repo.getPrayerTime(widget.mosallaId, docId).then((prayerData) {
          if (prayerData != null) {
            _monthData[i - 1] = prayerData;
          }
        }));
      }

      await Future.wait(futures);
    } catch (e) {
      debugPrint('Error loading bulk data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '-';
    return DateFormat.Hm().format(time);
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(widget.monthYear);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$monthName ${l10n.prayerTimes}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      columns: [
                        DataColumn(label: Text(l10n.date)),
                        DataColumn(label: Text(l10n.fajr)),
                        DataColumn(label: Text(l10n.duhr)),
                        DataColumn(label: Text(l10n.asr)),
                        DataColumn(label: Text(l10n.maghrib)),
                        DataColumn(label: Text(l10n.isha)),
                        DataColumn(label: Text(l10n.jumuah)),
                      ],
                      rows: List.generate(_daysInMonth, (index) {
                        final day = index + 1;
                        final data = _monthData[index];
                        
                        final isToday = DateTime.now().year == widget.monthYear.year &&
                                        DateTime.now().month == widget.monthYear.month &&
                                        DateTime.now().day == day;

                        return DataRow(
                          color: isToday ? WidgetStateProperty.resolveWith((states) => Colors.teal.withValues(alpha: 0.1)) : null,
                          cells: [
                            DataCell(Text(
                              '$day',
                              style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
                            )),
                            DataCell(Text(_formatTime(data?.fajr))),
                            DataCell(Text(_formatTime(data?.duhr))),
                            DataCell(Text(_formatTime(data?.asr))),
                            DataCell(Text(_formatTime(data?.maghrib))),
                            DataCell(Text(_formatTime(data?.isha))),
                            DataCell(Text(_formatTime(data?.jumma))),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
