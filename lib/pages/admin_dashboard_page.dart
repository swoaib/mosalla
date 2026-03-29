import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../model/prayer_data.dart';
import '../model/mosalla_data.dart';
import '../providers/prayer_time_provider.dart';
import 'monthly_prayer_time_editor.dart';

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
    final provider = context.watch<PrayerTimeProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? 'unknown';

    // Find the mosalla for this admin
    final mosallaList = provider.mosallas.where((m) => m.id == uid).toList();
    final MosallaData? mosalla = mosallaList.isNotEmpty ? mosallaList.first : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          final leftContent = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Month: \n${DateFormat('MMMM yyyy').format(_selectedDate)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Change Month'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (mosalla != null) MosallaInfoEditor(mosalla: mosalla),
            ],
          );

          final rightContent = MonthlyPrayerTimeEditor(monthYear: _selectedDate, mosallaId: uid);

          if (isWide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 380,
                    child: leftContent,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: rightContent,
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      leftContent,
                      const SizedBox(height: 24),
                      rightContent,
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class MosallaInfoEditor extends StatefulWidget {
  final MosallaData mosalla;
  const MosallaInfoEditor({Key? key, required this.mosalla}) : super(key: key);

  @override
  State<MosallaInfoEditor> createState() => _MosallaInfoEditorState();
}

class _MosallaInfoEditorState extends State<MosallaInfoEditor> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descController;
  late TextEditingController _yearController;
  late TextEditingController _logoController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(MosallaInfoEditor oldWidget) {
    if (oldWidget.mosalla.id != widget.mosalla.id) {
      _initControllers();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.mosalla.name);
    _locationController = TextEditingController(text: widget.mosalla.location);
    _descController = TextEditingController(text: widget.mosalla.description);
    _yearController = TextEditingController(text: widget.mosalla.yearFounded);
    _logoController = TextEditingController(text: widget.mosalla.logo ?? '');
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final data = {
      'name': _nameController.text,
      'location': _locationController.text,
      'description': _descController.text,
      'yearFounded': _yearController.text,
      'logo': _logoController.text.isNotEmpty ? _logoController.text : null,
    };
    try {
      await FirebaseFirestore.instance.collection('mosalla').doc(widget.mosalla.id).set(data, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mosalla details saved!')));
        context.read<PrayerTimeProvider>().fetchMosallas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Mosalla Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildField('Name', _nameController),
            _buildField('Location', _locationController),
            _buildField('Description', _descController),
            _buildField('Year Founded', _yearController),
            _buildField('Logo URL', _logoController),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Profile', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PrayerTimeEditor extends StatefulWidget {
  final DateTime date;
  final String docId;
  final String mosallaId;
  const PrayerTimeEditor({Key? key, required this.date, required this.docId, required this.mosallaId}) : super(key: key);

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
    if (oldWidget.docId != widget.docId || oldWidget.mosallaId != widget.mosallaId) {
      _loadData();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('mosalla/${widget.mosallaId}/prayer_times').doc(widget.docId).get();
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
      await FirebaseFirestore.instance.collection('mosalla/${widget.mosallaId}/prayer_times').doc(widget.docId).set(data, SetOptions(merge: true));
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor)
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
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.tealAccent : Colors.teal[800], fontWeight: FontWeight.bold)
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.tealAccent : Colors.teal[800]),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
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
      ),
    );
  }
}
