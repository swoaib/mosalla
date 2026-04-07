import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/mosalla_repository.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../services/ai_prayer_extractor.dart';
import '../model/prayer_data.dart';
import '../providers/admin_dashboard_provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';

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
  bool _isSaving = false;
  bool _isExtracting = false;

  // Array of days. Index 0 = day 1.
  late int _daysInMonth;
  int _selectedTab = 0;

  // Track modified days index -> Map of fields to update
  final Map<int, Map<String, dynamic>> _modifiedRows = {};

  // Cache controllers by "dayIndex|fieldName" to avoid recreation on rebuild
  final Map<String, TextEditingController> _cellControllers = {};

  @override
  void initState() {
    super.initState();
    _daysInMonth =
        DateUtils.getDaysInMonth(widget.monthYear.year, widget.monthYear.month);
  }

  @override
  void didUpdateWidget(MonthlyPrayerTimeEditor oldWidget) {
    if (oldWidget.monthYear.month != widget.monthYear.month ||
        oldWidget.monthYear.year != widget.monthYear.year) {
      _daysInMonth = DateUtils.getDaysInMonth(
          widget.monthYear.year, widget.monthYear.month);
      _modifiedRows.clear();
      // Dispose old controllers when month changes
      for (final c in _cellControllers.values) {
        c.dispose();
      }
      _cellControllers.clear();
      _editingKey = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (final c in _cellControllers.values) {
      c.dispose();
    }
    _cellControllers.clear();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  TimeOfDay? _parseTimeString(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    // Accept HH:mm or H:mm
    final parts = trimmed.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return TimeOfDay(hour: h, minute: m);
  }

  void _onCellSubmitted(int dayIndex, String fieldName, String value) {
    final parsed = _parseTimeString(value);
    if (parsed == null) return;

    // Get original time from provider data (not from _modifiedRows)
    final adminProvider = context.read<AdminDashboardProvider>();
    final monthData = adminProvider.getCachedMonth(
        widget.mosallaId, widget.monthYear);
    final originalTime = monthData != null
        ? _getOriginalTime(dayIndex, fieldName, monthData)
        : null;

    setState(() {
      // If same as original, remove any pending modification
      if (originalTime != null &&
          parsed.hour == originalTime.hour &&
          parsed.minute == originalTime.minute) {
        _modifiedRows[dayIndex]?.remove(fieldName);
        if (_modifiedRows[dayIndex]?.isEmpty == true) {
          _modifiedRows.remove(dayIndex);
        }
      } else {
        if (!_modifiedRows.containsKey(dayIndex)) {
          _modifiedRows[dayIndex] = {};
        }
        _modifiedRows[dayIndex]![fieldName] = parsed;
      }
    });
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
      final locale = Localizations.localeOf(context).languageCode;
      final monthStr = DateFormat('MM-yyyy', locale).format(widget.monthYear);
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
        _modifiedRows.clear();
        context.read<AdminDashboardProvider>().invalidateCache();
        // The parent AdminDashboardPage will trigger a reload via build -> ensureMonthLoaded
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

  void _cancelChanges() {
    if (_modifiedRows.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Changes?'),
        content: const Text(
            'Are you sure you want to discard all unsaved changes for this month?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep Editing'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _modifiedRows.clear();
                _cellControllers.clear();
                _editingKey = null;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

  /// Gets the original time from Firestore data, ignoring any pending modifications.
  TimeOfDay? _getOriginalTime(
      int dayIndex, String fieldName, List<PrayerData?> monthData) {
    final existingData = monthData[dayIndex];
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

  TimeOfDay? _getLatestTime(
      int dayIndex, String fieldName, List<PrayerData?> monthData) {
    if (_modifiedRows[dayIndex]?.containsKey(fieldName) == true) {
      return _modifiedRows[dayIndex]![fieldName] as TimeOfDay?;
    }
    final existingData = monthData[dayIndex];
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

  /// Returns a cached [TextEditingController] for this cell, creating one if needed.
  /// The controller text is kept in sync with the latest time value.
  TextEditingController _getController(
      int dayIndex, String fieldName, TimeOfDay? time) {
    final key = '$dayIndex|$fieldName';
    final displayText = time != null ? _formatTimeOfDay(time) : '';

    if (_cellControllers.containsKey(key)) {
      final existing = _cellControllers[key]!;
      // Only update controller text when the source value changed externally
      // (e.g. AI fill), but NOT while the user is actively editing.
      if (existing.text != displayText && _editingKey != key) {
        existing.text = displayText;
      }
      return existing;
    }

    final controller = TextEditingController(text: displayText);
    _cellControllers[key] = controller;
    return controller;
  }

  // Which cell is currently in edit mode (null = none)
  String? _editingKey;

  void _startEditing(int dayIndex, String fieldName, TimeOfDay? currentTime) {
    final key = '$dayIndex|$fieldName';
    final controller = _getController(dayIndex, fieldName, currentTime);
    // Select all text for easy replacement
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
    setState(() => _editingKey = key);
  }

  void _stopEditing(int dayIndex, String fieldName, String value) {
    _onCellSubmitted(dayIndex, fieldName, value);
    if (_editingKey == '$dayIndex|$fieldName') {
      setState(() => _editingKey = null);
    }
  }

  Widget _buildCell(
      int dayIndex, String fieldName, List<PrayerData?> monthData) {
    final t = _getLatestTime(dayIndex, fieldName, monthData);
    final isModified = _modifiedRows[dayIndex]?.containsKey(fieldName) ?? false;
    final key = '$dayIndex|$fieldName';
    final isEditing = _editingKey == key;

    const double cellWidth = 90;
    const double cellHeight = 36;

    if (isEditing) {
      final controller = _getController(dayIndex, fieldName, t);
      return Container(
        width: cellWidth,
        height: cellHeight,
        alignment: Alignment.center,
        child: Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              _stopEditing(dayIndex, fieldName, controller.text);
            }
          },
          child: TextField(
            controller: controller,
            autofocus: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.teal[800],
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              hintText: 'HH:mm',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
              filled: true,
              fillColor: Colors.teal.withAlpha(15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.teal, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.teal, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.teal, width: 1.5),
              ),
            ),
            keyboardType: TextInputType.datetime,
            textInputAction: TextInputAction.next,
            onSubmitted: (value) {
              _stopEditing(dayIndex, fieldName, value);
            },
          ),
        ),
      );
    }

    // Default: tappable text button (original look)
    return InkWell(
      onTap: () => _startEditing(dayIndex, fieldName, t),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: cellWidth,
        height: cellHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isModified ? Colors.orange.withAlpha(30) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          t != null ? _formatTimeOfDay(t) : '-',
          style: TextStyle(
            color: isModified ? Colors.orange[800] : Colors.teal[800],
            fontWeight: isModified ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataTable(List<String> fieldNames, List<String> fieldLabels,
      List<PrayerData?> monthData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 0,
        horizontalMargin: 0,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 56,
        columns: [
          _buildLocalizedColumn(0, 'Day'),
          ...fieldLabels.asMap().entries.map((entry) {
            final colIdx = entry.key + 1;
            return _buildLocalizedColumn(colIdx, entry.value);
          }),
        ],
        rows: List.generate(_daysInMonth, (index) {
          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>((states) {
              if (_modifiedRows.containsKey(index)) {
                return Colors.orange.withAlpha(20);
              }
              return null;
            }),
            cells: [
              _wrapWithColumnColor(
                  0,
                  Text('${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              ...fieldNames.asMap().entries.map((entry) {
                final colIdx = entry.key + 1; // 1-indexed for the fieldNames
                return _wrapWithColumnColor(
                    colIdx, _buildCell(index, entry.value, monthData));
              }),
            ],
          );
        }),
      ),
    );
  }

  DataColumn _buildLocalizedColumn(int index, String label) {
    final isOdd = index % 2 == 0;
    return DataColumn(
      label: Expanded(
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isOdd ? Colors.blueGrey.withValues(alpha: 0.05) : null,
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  DataCell _wrapWithColumnColor(int colIndex, Widget child) {
    // Odd columns (1, 3, 5, 7) -> index 0, 2, 4, 6
    final isOdd = colIndex % 2 == 0;
    return DataCell(
      Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: isOdd ? Colors.blueGrey.withValues(alpha: 0.05) : null,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminDashboardProvider>();
    final monthData =
        adminProvider.getCachedMonth(widget.mosallaId, widget.monthYear);
    final isMonthLoading = monthData == null;

    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final monthStr = DateFormat.yMMMM(locale).format(widget.monthYear);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.onPreviousMonth != null)
                            IconButton(
                              icon: const Icon(Icons.chevron_left,
                                  color: Colors.teal),
                              onPressed: widget.onPreviousMonth,
                              tooltip: 'Previous month',
                            ),
                          Flexible(
                            child: Text(
                              l10n.prayerTimesFor(monthStr),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                          ),
                          if (widget.onNextMonth != null)
                            IconButton(
                              icon: const Icon(Icons.chevron_right,
                                  color: Colors.teal),
                              onPressed: widget.onNextMonth,
                              tooltip: 'Next month',
                            ),
                        ],
                      ),
                      if (_modifiedRows.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_modifiedRows.length} day(s) staged for saving',
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed:
                        (_isExtracting || isMonthLoading) ? null : _scanWithAI,
                    icon: _isExtracting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome, size: 18),
                    label:
                        Text(_isExtracting ? 'Scanning...' : 'Auto-Fill (AI)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            if (isMonthLoading)
              const Padding(
                padding: EdgeInsets.all(60.0),
                child: CircularProgressIndicator(color: Colors.teal),
              )
            else
              Column(
                children: [
                  Center(
                    child: SegmentedButton<int>(
                      segments: const <ButtonSegment<int>>[
                        ButtonSegment<int>(
                          value: 0,
                          label: Text('Adhan Times'),
                          icon: Icon(Icons.notifications_none, size: 18),
                        ),
                        ButtonSegment<int>(
                          value: 1,
                          label: Text('Jamaat Times'),
                          icon: Icon(Icons.groups_outlined, size: 18),
                        ),
                      ],
                      selected: <int>{_selectedTab},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          _selectedTab = newSelection.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Colors.grey.withValues(alpha: 0.05),
                        selectedBackgroundColor: Colors.teal,
                        selectedForegroundColor: Colors.white,
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.teal.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      showSelectedIcon: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                          _selectedTab == 0
                      ? _buildDataTable(
                          ['Fajr', 'Duhr', 'Asr', 'Maghrib', 'Isha'],
                          ['Fajr', 'Duhr', 'Asr', 'Maghrib', 'Isha'],
                          monthData,
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
                          monthData,
                        ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_modifiedRows.isNotEmpty) ...[
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: _isSaving ? null : _cancelChanges,
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.red[300]!),
                              foregroundColor: Colors.red[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving || _modifiedRows.isEmpty
                              ? null
                              : _saveMonth,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.cloud_upload),
                          label: Text(
                              _isSaving ? 'Saving...' : 'Save All Changes',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor: _modifiedRows.isNotEmpty
                                ? Colors.teal
                                : Colors.grey[400],
                            foregroundColor: Colors.white,
                            elevation: _modifiedRows.isNotEmpty ? 4 : 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
