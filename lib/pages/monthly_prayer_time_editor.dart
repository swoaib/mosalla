import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/mosalla_repository.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../services/ai_prayer_extractor.dart';
import '../model/prayer_data.dart';

class MonthlyPrayerTimeEditor extends StatefulWidget {
  final DateTime monthYear;
  final String mosallaId;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  const MonthlyPrayerTimeEditor({
    Key? key,
    required this.monthYear,
    required this.mosallaId,
    this.onPreviousMonth,
    this.onNextMonth,
  }) : super(key: key);

  @override
  State<MonthlyPrayerTimeEditor> createState() =>
      _MonthlyPrayerTimeEditorState();
}

class _MonthlyPrayerTimeEditorState extends State<MonthlyPrayerTimeEditor> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isExtracting = false;

  // Array of days. Index 0 = day 1.
  late List<PrayerData?> _monthData;
  late int _daysInMonth;
  int _selectedTab = 0;

  // Track modified days index -> Map of fields to update
  final Map<int, Map<String, dynamic>> _modifiedRows = {};

  @override
  void initState() {
    super.initState();
    _loadMonthData();
  }

  @override
  void didUpdateWidget(MonthlyPrayerTimeEditor oldWidget) {
    if (oldWidget.monthYear.month != widget.monthYear.month ||
        oldWidget.monthYear.year != widget.monthYear.year ||
        oldWidget.mosallaId != widget.mosallaId) {
      _loadMonthData();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadMonthData() async {
    setState(() => _isLoading = true);
    _modifiedRows.clear();

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

        futures
            .add(repo.getPrayerTime(widget.mosallaId, docId).then((prayerData) {
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

  DateTime _toLocalThenUtc(TimeOfDay t, int day) {
    final local = DateTime(
        widget.monthYear.year, widget.monthYear.month, day, t.hour, t.minute);
    return local.toUtc();
  }

  Future<void> _saveMonth() async {
    if (_modifiedRows.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No changes to save.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = context.read<MosallaRepository>();
      final monthStr = DateFormat('MM-yyyy').format(widget.monthYear);
      final Map<String, Map<String, dynamic>> updatesByDocId = {};

      _modifiedRows.forEach((dayIndex, updates) {
        final dayStr = (dayIndex + 1).toString().padLeft(2, '0');
        final docId = '$dayStr-$monthStr';

        final data = <String, dynamic>{
          'Date': docId,
        };

        updates.forEach((key, timeOfDay) {
          if (timeOfDay != null) {
            data[key] = _toLocalThenUtc(timeOfDay, dayIndex + 1);
          }
        });

        updatesByDocId[docId] = data;
      });

      await repo.bulkSavePrayerTimes(widget.mosallaId, updatesByDocId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Month saved successfully!')));
        await _loadMonthData(); // Reload so _monthData reflects saved values
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save batch: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _scanWithAI() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to read file.')));
      }
      return;
    }

    setState(() => _isExtracting = true);

    try {
      String mimeType = 'application/pdf';
      final ext = file.extension?.toLowerCase() ?? '';
      if (ext == 'png') {
        mimeType = 'image/png';
      } else if (ext == 'jpg' || ext == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (ext == 'webp') {
        mimeType = 'image/webp';
      }

      final extractedData = await AIPrayerExtractor.extractPrayerTimes(
        bytes: file.bytes!,
        mimeType: mimeType,
      );

      if (extractedData != null && extractedData.isNotEmpty) {
        for (final dayData in extractedData) {
          final int? day = dayData['day'] as int?;
          if (day == null || day < 1 || day > _daysInMonth) continue;

          final int rowIndex = day - 1;

          TimeOfDay? parseTime(String? timeStr) {
            if (timeStr == null || timeStr.isEmpty) return null;
            try {
              final parts = timeStr.split(':');
              if (parts.length >= 2) {
                final h = int.parse(parts[0]);
                final m = int.parse(parts[1]);
                return TimeOfDay(hour: h, minute: m);
              }
            } catch (_) {}
            return null;
          }

          final fajr = parseTime(dayData['fajr']);
          final duhr = parseTime(dayData['duhr']);
          final asr = parseTime(dayData['asr']);
          final maghrib = parseTime(dayData['maghrib']);
          final isha = parseTime(dayData['isha']);
          final jumma = parseTime(dayData['jumma']);

          final Map<String, dynamic> rowChanges = {};
          if (_selectedTab == 0) {
            // Mapping to Adhan Times
            if (fajr != null) rowChanges['Fajr'] = fajr;
            if (duhr != null) rowChanges['Duhr'] = duhr;
            if (asr != null) rowChanges['Asr'] = asr;
            if (maghrib != null) rowChanges['Maghrib'] = maghrib;
            if (isha != null) rowChanges['Isha'] = isha;
          } else {
            // Mapping to Jamaat/Congregation Times
            if (fajr != null) rowChanges['FajrJamaat'] = fajr;
            if (duhr != null) rowChanges['DuhrJamaat'] = duhr;
            if (asr != null) rowChanges['AsrJamaat'] = asr;
            if (maghrib != null) rowChanges['MaghribJamaat'] = maghrib;
            if (isha != null) rowChanges['IshaJamaat'] = isha;
            if (jumma != null) rowChanges['Jumma'] = jumma;
          }

          if (rowChanges.isNotEmpty) {
            if (_modifiedRows.containsKey(rowIndex)) {
              _modifiedRows[rowIndex]!.addAll(rowChanges);
            } else {
              _modifiedRows[rowIndex] = rowChanges;
            }
          }
        }

        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'AI extraction complete! Highlighted rows are staged for saving.')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('No structured data could be pulled.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('AI Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExtracting = false);
    }
  }

  Future<void> _pickTime(
      int dayIndex, String fieldName, TimeOfDay? currentTime) async {
    final t = await showTimePicker(
      context: context,
      initialTime: currentTime ?? const TimeOfDay(hour: 12, minute: 0),
    );

    if (t != null) {
      setState(() {
        if (!_modifiedRows.containsKey(dayIndex)) {
          _modifiedRows[dayIndex] = {};
        }
        _modifiedRows[dayIndex]![fieldName] = t;
      });
    }
  }

  TimeOfDay? _getLatestTime(int dayIndex, String fieldName) {
    if (_modifiedRows[dayIndex]?.containsKey(fieldName) == true) {
      return _modifiedRows[dayIndex]![fieldName] as TimeOfDay?;
    }
    final existingData = _monthData[dayIndex];
    if (existingData == null) return null;

    DateTime? time;
    switch (fieldName) {
      case 'Fajr':
        time = existingData.fajr;
        break;
      case 'FajrJamaat':
        time = existingData.fajrJamaat;
        break;
      case 'Duhr':
        time = existingData.duhr;
        break;
      case 'DuhrJamaat':
        time = existingData.duhrJamaat;
        break;
      case 'Asr':
        time = existingData.asr;
        break;
      case 'AsrJamaat':
        time = existingData.asrJamaat;
        break;
      case 'Maghrib':
        time = existingData.maghrib;
        break;
      case 'MaghribJamaat':
        time = existingData.maghribJamaat;
        break;
      case 'Isha':
        time = existingData.isha;
        break;
      case 'IshaJamaat':
        time = existingData.ishaJamaat;
        break;
      case 'Jumma':
        time = existingData.jumma;
        break;
    }
    if (time == null) return null;
    return TimeOfDay.fromDateTime(time.toLocal());
  }

  Widget _buildCell(int dayIndex, String fieldName) {
    final t = _getLatestTime(dayIndex, fieldName);
    final isModified = _modifiedRows[dayIndex]?.containsKey(fieldName) ?? false;

    return InkWell(
      onTap: () => _pickTime(dayIndex, fieldName, t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isModified ? Colors.orange.withAlpha(30) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          t?.format(context) ?? '-',
          style: TextStyle(
            color: isModified ? Colors.orange[800] : Colors.teal[800],
            fontWeight: isModified ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataTable(List<String> fieldNames, List<String> fieldLabels) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowMinHeight: 48,
        dataRowMaxHeight: 56,
        columns: [
          const DataColumn(
            label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...fieldLabels.map((label) => DataColumn(
                label: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
        ],
        rows: List.generate(_daysInMonth, (index) {
          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>((states) {
              if (_modifiedRows.containsKey(index)) {
                return Colors.orange.withAlpha(15);
              }
              return null;
            }),
            cells: [
              DataCell(Text('${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
              ...fieldNames.map((fieldName) => DataCell(_buildCell(index, fieldName))),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthStr = DateFormat('MMMM yyyy').format(widget.monthYear);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.onPreviousMonth != null)
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: widget.onPreviousMonth,
                            tooltip: 'Previous month',
                          ),
                        Text('Prayer Times for $monthStr',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        if (widget.onNextMonth != null)
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: widget.onNextMonth,
                            tooltip: 'Next month',
                          ),
                      ],
                    ),
                    if (_modifiedRows.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('${_modifiedRows.length} day(s) modified',
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: (_isExtracting || _isLoading) ? null : _scanWithAI,
                  icon: _isExtracting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isExtracting ? 'Scanning...' : 'Auto-Fill (AI)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[50],
                    foregroundColor: Colors.purple[800],
                    elevation: 0,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              )
            else
              DefaultTabController(
                length: 2,
                child: Builder(builder: (context) {
                  final TabController tabController = DefaultTabController.of(context);
                  tabController.addListener(() {
                    if (!tabController.indexIsChanging) {
                      setState(() {
                        _selectedTab = tabController.index;
                      });
                    }
                  });

                  return Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.teal,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.teal,
                        tabs: [
                          Tab(text: 'Adhan Times'),
                          Tab(text: 'Jamaat Times'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _selectedTab == 0
                          ? _buildDataTable(
                              ['Fajr', 'Duhr', 'Asr', 'Maghrib', 'Isha'],
                              ['Fajr', 'Duhr', 'Asr', 'Maghrib', 'Isha'],
                            )
                          : _buildDataTable(
                              [
                                'FajrJamaat',
                                'DuhrJamaat',
                                'AsrJamaat',
                                'MaghribJamaat',
                                'IshaJamaat',
                                'Jumma'
                              ],
                              [
                                'Fajr J.',
                                'Duhr J.',
                                'Asr J.',
                                'Maghrib J.',
                                'Isha J.',
                                'Jumu\u0027ah'
                              ],
                            ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveMonth,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isSaving ? 'Saving...' : 'Save Month',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor:
                        _modifiedRows.isNotEmpty ? Colors.teal : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

