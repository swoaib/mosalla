import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mosalla_repository.dart';

import '../model/mosalla_data.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/prayer_time_provider.dart';
import '../widgets/admin_events_tab.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_settings_tab.dart';
import 'monthly_prayer_time_editor.dart';
import 'prayer_time_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // All state moved to AdminDashboardProvider for persistence across rebuilds (theme/locale changes)

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();
    final adminProvider = context.watch<AdminDashboardProvider>();
    final user = context.read<AuthRepository>().currentUser;
    final String uid = user?.uid ?? 'unknown';
    final repo = context.read<MosallaRepository>();

    // Wait for provider initialization (loading from storage)
    if (!adminProvider.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Ensure data is loaded once for the current tab.
    // ensureMonthLoaded / ensureEventsLoaded are idempotent (they check the cache).
    if (adminProvider.selectedIndex == 1 && user != null) {
      adminProvider.ensureMonthLoaded(repo, uid, adminProvider.selectedDate);
    } else if (adminProvider.selectedIndex == 2 && user != null) {
      adminProvider.ensureEventsLoaded(repo, uid);
    }

    // Find the mosalla for this admin
    final mosallaList = provider.mosallas.where((m) => m.id == uid).toList();
    final MosallaData? mosalla =
        mosallaList.isNotEmpty ? mosallaList.first : null;

    return PopScope(
      canPop: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          return Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: isWide
                  ? null
                  : Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
              title: null,
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
              actions: [
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isWide) ...[
                          OutlinedButton.icon(
                            onPressed: () => adminProvider.setShowAppPreview(
                                !adminProvider.showAppPreview),
                            icon: Icon(
                                adminProvider.showAppPreview
                                    ? Icons.phonelink_off
                                    : Icons.phonelink,
                                size: 18),
                            label: Text(adminProvider.showAppPreview
                                ? 'Hide App Preview'
                                : 'Show App Preview'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.5)),
                            ),
                          ),
                          const SizedBox(width: 32),
                          Text(
                            mosalla?.name ?? user.email ?? '',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.teal.withValues(alpha: 0.1),
                          backgroundImage: (mosalla?.logo != null &&
                                  mosalla!.logo!.isNotEmpty)
                              ? NetworkImage(mosalla.logo!)
                              : null,
                          child:
                              (mosalla?.logo == null || mosalla!.logo!.isEmpty)
                                  ? const Icon(Icons.person,
                                      color: Colors.teal, size: 20)
                                  : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            drawer: isWide
                ? null
                : Drawer(
                    child: AdminSidebar(
                      selectedIndex: adminProvider.selectedIndex,
                      mosallaName: mosalla?.name,
                      mosallaLogo: mosalla?.logo,
                      onDestinationSelected: (index) {
                        adminProvider.setSelectedIndex(index);
                        Navigator.pop(context);
                      },
                      onLogout: () async {
                        await context.read<AuthRepository>().signOut();
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                  ),
            body: Row(
              children: [
                if (isWide)
                  AdminSidebar(
                    selectedIndex: adminProvider.selectedIndex,
                    mosallaName: mosalla?.name,
                    mosallaLogo: mosalla?.logo,
                    onDestinationSelected: (index) {
                      adminProvider.setSelectedIndex(index);
                    },
                    onLogout: () async {
                      await context.read<AuthRepository>().signOut();
                    },
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 56),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: KeyedSubtree(
                              key: ValueKey(adminProvider.selectedIndex),
                              child: _buildContent(uid, mosalla, adminProvider),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isWide)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    width: adminProvider.showAppPreview ? 450 : 0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.1),
                          width: adminProvider.showAppPreview ? 1 : 0,
                        ),
                      ),
                      boxShadow: adminProvider.showAppPreview
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(-2, 0),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRect(
                      child: OverflowBox(
                        minWidth: 450,
                        maxWidth: 450,
                        alignment: Alignment.topRight,
                        child: adminProvider.showAppPreview
                            ? const Column(
                                children: [
                                  Expanded(
                                    child: Navigator(
                                      onGenerateRoute: _generatePreviewRoute,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Route<dynamic> _generatePreviewRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const PrayerTimePage(),
      settings: settings,
    );
  }

  Widget _buildContent(
      String uid, MosallaData? mosalla, AdminDashboardProvider adminProvider) {
    switch (adminProvider.selectedIndex) {
      case 0:
        return _buildBioPage(mosalla);
      case 1:
        return _buildPrayersPage(uid, adminProvider);
      case 2:
        return AdminEventsTab(mosallaId: uid);
      case 3:
        return const AdminSettingsTab();
      default:
        return const Center(child: Text('Under Construction'));
    }
  }

  Widget _buildBioPage(MosallaData? mosalla) {
    if (mosalla == null)
      return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: MosallaInfoEditor(mosalla: mosalla),
        ),
      ),
    );
  }

  Widget _buildPrayersPage(String uid, AdminDashboardProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: MonthlyPrayerTimeEditor(
            monthYear: adminProvider.selectedDate,
            mosallaId: uid,
            onPreviousMonth: () => adminProvider.setSelectedDate(DateTime(
                adminProvider.selectedDate.year,
                adminProvider.selectedDate.month - 1)),
            onNextMonth: () => adminProvider.setSelectedDate(DateTime(
                adminProvider.selectedDate.year,
                adminProvider.selectedDate.month + 1)),
          ),
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
  late TextEditingController _nameJaController;
  late TextEditingController _locationController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _descController;
  late TextEditingController _descJaController;
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
    _nameJaController = TextEditingController(text: widget.mosalla.nameJa ?? '');
    _locationController = TextEditingController(text: widget.mosalla.location);
    _latController =
        TextEditingController(text: widget.mosalla.latitude?.toString() ?? '');
    _lngController =
        TextEditingController(text: widget.mosalla.longitude?.toString() ?? '');
    _descController = TextEditingController(text: widget.mosalla.description);
    _descJaController =
        TextEditingController(text: widget.mosalla.descriptionJa ?? '');
    _yearController = TextEditingController(text: widget.mosalla.yearFounded);
    _logoController = TextEditingController(text: widget.mosalla.logo ?? '');
  }

  bool get _hasAnyChange {
    final m = widget.mosalla;
    return _nameController.text != m.name ||
        _nameJaController.text != (m.nameJa ?? '') ||
        _locationController.text != m.location ||
        _latController.text != (m.latitude?.toString() ?? '') ||
        _lngController.text != (m.longitude?.toString() ?? '') ||
        _descController.text != m.description ||
        _descJaController.text != (m.descriptionJa ?? '') ||
        _yearController.text != m.yearFounded ||
        _logoController.text != (m.logo ?? '');
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    final data = <String, dynamic>{
      'name': _nameController.text,
      'nameJa': _nameJaController.text.isNotEmpty ? _nameJaController.text : null,
      'location': _locationController.text,
      'description': _descController.text,
      'descriptionJa':
          _descJaController.text.isNotEmpty ? _descJaController.text : null,
      'yearFounded': _yearController.text,
      'logo': _logoController.text.isNotEmpty ? _logoController.text : null,
      if (lat != null) 'latitude': lat,
      if (lng != null) 'longitude': lng,
    };
    try {
      await context
          .read<MosallaRepository>()
          .saveMosallaProfile(widget.mosalla.id, data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mosalla details saved!')));
        context.read<PrayerTimeProvider>().fetchMosallas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              onTap != null ? const Icon(Icons.calendar_today, size: 20) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _selectYear() async {
    final int? currentYear = int.tryParse(_yearController.text);
    final DateTime initialDate = currentYear != null
        ? DateTime(currentYear)
        : DateTime(DateTime.now().year);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(1800),
              lastDate: DateTime.now(),
              initialDate: initialDate,
              selectedDate: initialDate,
              onChanged: (DateTime dateTime) {
                setState(() {
                  _yearController.text = dateTime.year.toString();
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Mosalla Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildField('Name', _nameController),
            _buildField(l10n.nameJapanese, _nameJaController),
            const SizedBox(height: 4),
            const Text('Location',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                    if (_latController.text.isNotEmpty &&
                        _lngController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 28),
                        child: Text(
                          '${_latController.text}, ${_lngController.text}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('No location set',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _searchLocation,
                      icon: const Icon(Icons.search),
                      label: Text(_locationController.text.isEmpty
                          ? 'Search Location'
                          : 'Change Location'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildField('Description', _descController),
            _buildField(l10n.descriptionJapanese, _descJaController),
            _buildField('Year Founded', _yearController,
                readOnly: true, onTap: _selectYear),
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
                          Icon(Icons.image_outlined,
                              size: 36, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('No logo URL',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
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
                              Icon(Icons.broken_image,
                                  size: 36, color: Colors.red),
                              SizedBox(height: 4),
                              Text('Invalid image URL',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12)),
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
              onPressed: (_isSaving || !_hasAnyChange) ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Profile',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 8),
              Flexible(
                child: _results.isEmpty
                    ? Center(
                        child: Text(
                          _isSearching
                              ? 'Searching...'
                              : 'Enter an address and press Search',
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
                            leading:
                                const Icon(Icons.place, color: Colors.teal),
                            title: Text(
                              r['address'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              '${(r['lat'] as double).toStringAsFixed(5)}, ${(r['lng'] as double).toStringAsFixed(5)}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600]),
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
