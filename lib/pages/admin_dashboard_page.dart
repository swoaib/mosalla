import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mosalla_repository.dart';

import '../model/mosalla_data.dart';
import '../providers/prayer_time_provider.dart';
import '../widgets/admin_events_tab.dart';
import 'monthly_prayer_time_editor.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  DateTime _selectedDate = DateTime.now();

  void _goToPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();
    final user = context.read<AuthRepository>().currentUser;
    final String uid = user?.uid ?? 'unknown';

    // Find the mosalla for this admin
    final mosallaList = provider.mosallas.where((m) => m.id == uid).toList();
    final MosallaData? mosalla = mosallaList.isNotEmpty ? mosallaList.first : null;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.teal[800],
          foregroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Admin Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (mosalla != null)
                Text(mosalla.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () async {
                await context.read<AuthRepository>().signOut();
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.access_time), text: 'Prayer Times'),
              Tab(icon: Icon(Icons.event), text: 'Events'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Prayer Times
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                final leftContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (mosalla != null) MosallaInfoEditor(mosalla: mosalla),
                  ],
                );

                final rightContent = MonthlyPrayerTimeEditor(
                  monthYear: _selectedDate,
                  mosallaId: uid,
                  onPreviousMonth: _goToPreviousMonth,
                  onNextMonth: _goToNextMonth,
                );

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
            // Tab 2: Events
            AdminEventsTab(mosallaId: uid),
          ],
        ),
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
  late TextEditingController _latController;
  late TextEditingController _lngController;
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
    _latController = TextEditingController(text: widget.mosalla.latitude?.toString() ?? '');
    _lngController = TextEditingController(text: widget.mosalla.longitude?.toString() ?? '');
    _descController = TextEditingController(text: widget.mosalla.description);
    _yearController = TextEditingController(text: widget.mosalla.yearFounded);
    _logoController = TextEditingController(text: widget.mosalla.logo ?? '');
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    final data = <String, dynamic>{
      'name': _nameController.text,
      'location': _locationController.text,
      'description': _descController.text,
      'yearFounded': _yearController.text,
      'logo': _logoController.text.isNotEmpty ? _logoController.text : null,
      if (lat != null) 'latitude': lat,
      if (lng != null) 'longitude': lng,
    };
    try {
      await context.read<MosallaRepository>().saveMosallaProfile(widget.mosalla.id, data);
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

  Future<void> _searchLocation() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _LocationSearchDialog(),
    );
    if (result != null) {
      setState(() {
        _locationController.text = result['address'] as String;
        _latController.text = result['lat'].toString();
        _lngController.text = result['lng'].toString();
      });
    }
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
            const SizedBox(height: 4),
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_locationController.text.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.place, color: Colors.teal, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _locationController.text,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    if (_latController.text.isNotEmpty && _lngController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 28),
                        child: Text(
                          '${_latController.text}, ${_lngController.text}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('No location set', style: TextStyle(color: Colors.grey)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _searchLocation,
                      icon: const Icon(Icons.search),
                      label: Text(_locationController.text.isEmpty ? 'Search Location' : 'Change Location'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildField('Description', _descController),
            _buildField('Year Founded', _yearController),
            _buildField('Logo URL', _logoController),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _logoController,
              builder: (context, value, _) {
                final url = value.text.trim();
                if (url.isEmpty) {
                  return Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_outlined, size: 36, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('No logo URL', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image, size: 36, color: Colors.red),
                              SizedBox(height: 4),
                              Text('Invalid image URL', style: TextStyle(color: Colors.red, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
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


class _LocationSearchDialog extends StatefulWidget {
  const _LocationSearchDialog({Key? key}) : super(key: key);

  @override
  State<_LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<_LocationSearchDialog> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  String? _error;

  Future<void> _search(String query) async {
    if (query.trim().length < 3) return;

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query.trim())}'
        '&format=json'
        '&addressdetails=1'
        '&limit=8',
      );

      final response = await http.get(uri, headers: {
        'User-Agent': 'MosallaApp/1.0',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _results = data.map((item) {
            return {
              'address': item['display_name'] as String,
              'lat': double.parse(item['lat'] as String),
              'lng': double.parse(item['lon'] as String),
              'type': item['type'] as String? ?? '',
            };
          }).toList();
        });
      } else {
        setState(() => _error = 'Search failed. Please try again.');
      }
    } catch (e) {
      setState(() => _error = 'Network error. Please check your connection.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Search Location',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search for an address or place...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: _search,
                textInputAction: TextInputAction.search,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _search(_searchController.text),
                child: const Text('Search'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 8),
              Flexible(
                child: _results.isEmpty
                    ? Center(
                        child: Text(
                          _isSearching ? 'Searching...' : 'Enter an address and press Search',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final r = _results[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.place, color: Colors.teal),
                            title: Text(
                              r['address'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              '${(r['lat'] as double).toStringAsFixed(5)}, ${(r['lng'] as double).toStringAsFixed(5)}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                            onTap: () => Navigator.of(context).pop(r),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
