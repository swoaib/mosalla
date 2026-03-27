import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/prayer_data.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  DateTime _selectedDate = DateTime.now();

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String docId = DateFormat('dd-MM-yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/admin');
              }
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered content for responsiveness
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selected Date: ${DateFormat.yMMMMd().format(_selectedDate)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Change Date'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: PrayerTimeEditor(date: _selectedDate, docId: docId),
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

class PrayerTimeEditor extends StatefulWidget {
  final DateTime date;
  final String docId;
  const PrayerTimeEditor({Key? key, required this.date, required this.docId}) : super(key: key);

  @override
  State<PrayerTimeEditor> createState() => _PrayerTimeEditorState();
}

class _PrayerTimeEditorState extends State<PrayerTimeEditor> {
  // state vars for times
  TimeOfDay? fajr;
  TimeOfDay? duhr;
  TimeOfDay? asr;
  TimeOfDay? maghrib;
  TimeOfDay? isha;
  TimeOfDay? jumma;

  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(PrayerTimeEditor oldWidget) {
    if (oldWidget.docId != widget.docId) {
      _loadData();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('mosalla/MSS/prayer_times').doc(widget.docId).get();
      if (doc.exists) {
        final p = PrayerData.fromFirestore(doc);
        setState(() {
          fajr = p.fajr != null ? TimeOfDay.fromDateTime(p.fajr!) : null;
          duhr = p.duhr != null ? TimeOfDay.fromDateTime(p.duhr!) : null;
          asr = p.asr != null ? TimeOfDay.fromDateTime(p.asr!) : null;
          maghrib = p.maghrib != null ? TimeOfDay.fromDateTime(p.maghrib!) : null;
          isha = p.isha != null ? TimeOfDay.fromDateTime(p.isha!) : null;
          jumma = p.jumma != null ? TimeOfDay.fromDateTime(p.jumma!) : null;
        });
      } else {
        setState(() {
          fajr = null; duhr = null; asr = null; maghrib = null; isha = null; jumma = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime? _toLocalThenUtc(TimeOfDay? t) {
    if (t == null) return null;
    final local = DateTime(widget.date.year, widget.date.month, widget.date.day, t.hour, t.minute);
    return local.toUtc();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final data = {
      'Date': widget.docId,
      if (fajr != null) 'Fajr': Timestamp.fromDate(_toLocalThenUtc(fajr)!),
      if (duhr != null) 'Duhr': Timestamp.fromDate(_toLocalThenUtc(duhr)!),
      if (asr != null) 'Asr': Timestamp.fromDate(_toLocalThenUtc(asr)!),
      if (maghrib != null) 'Maghrib': Timestamp.fromDate(_toLocalThenUtc(maghrib)!),
      if (isha != null) 'Isha': Timestamp.fromDate(_toLocalThenUtc(isha)!),
      if (jumma != null) 'Jumma': Timestamp.fromDate(_toLocalThenUtc(jumma)!),
    };

    try {
      await FirebaseFirestore.instance.collection('mosalla/MSS/prayer_times').doc(widget.docId).set(data, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTimeRow(String label, TimeOfDay? time, ValueChanged<TimeOfDay?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.teal.withAlpha(25),
            borderRadius: BorderRadius.circular(20)
          ),
          child: InkWell(
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: time ?? const TimeOfDay(hour: 12, minute: 0));
              if (t != null) onChanged(t);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time?.format(context) ?? 'Not Set',
                  style: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.bold)
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 16, color: Colors.teal[800]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Edit Prayer Times', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildTimeRow('Fajr', fajr, (t) => setState(() => fajr = t)),
          _buildTimeRow('Duhr', duhr, (t) => setState(() => duhr = t)),
          _buildTimeRow('Asr', asr, (t) => setState(() => asr = t)),
          _buildTimeRow('Maghrib', maghrib, (t) => setState(() => maghrib = t)),
          _buildTimeRow('Isha', isha, (t) => setState(() => isha = t)),
          _buildTimeRow('Jumu‘ah', jumma, (t) => setState(() => jumma = t)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.cloud_upload),
            label: Text(_isSaving ? 'Saving...' : 'Save Prayer Times', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }
}
