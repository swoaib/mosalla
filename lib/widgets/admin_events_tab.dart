import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/event.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/prayer_time_provider.dart';
import '../repositories/mosalla_repository.dart';

class AdminEventsTab extends StatefulWidget {
  final String mosallaId;
  const AdminEventsTab({Key? key, required this.mosallaId}) : super(key: key);

  @override
  State<AdminEventsTab> createState() => _AdminEventsTabState();
}

class _AdminEventsTabState extends State<AdminEventsTab> {
  void _editEvent(BuildContext context, Event? event, String? mosallaLogoUrl) {
    showDialog(
      context: context,
      builder: (context) => _EventEditDialog(
        mosallaId: widget.mosallaId,
        event: event,
        mosallaLogoUrl: mosallaLogoUrl,
      ),
    );
  }

  void _deleteEvent(BuildContext context, Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<MosallaRepository>().deleteEvent(widget.mosallaId, event.id);
      if (mounted) {
        context.read<AdminDashboardProvider>().invalidateCache();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();
    final adminProvider = context.watch<AdminDashboardProvider>();
    final List<Event>? events = adminProvider.eventsCache;
    final bool isLoading = adminProvider.isLoadingEvents;

    // Find the mosalla for this admin to get the logo fallback
    final mosallaList = provider.mosallas.where((m) => m.id == widget.mosallaId).toList();
    final String? mosallaLogoUrl = mosallaList.isNotEmpty ? mosallaList.first.logo : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editEvent(context, null, mosallaLogoUrl),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading || events == null
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : events.isEmpty
              ? const Center(
                  child: Text('No events scheduled. Click + to add one.', style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final String? displayImageUrl = event.imageUrl.isNotEmpty ? event.imageUrl : mosallaLogoUrl;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: Colors.teal.withValues(alpha: 0.05),
                        child: (displayImageUrl != null && displayImageUrl.isNotEmpty)
                            ? Image.network(
                                displayImageUrl, 
                                fit: BoxFit.cover, 
                                errorBuilder: (_, __, ___) => const Icon(Icons.mosque, color: Colors.teal, size: 30)
                              )
                            : const Icon(Icons.mosque, color: Colors.teal, size: 30),
                      ),
                    ),
                    title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.teal),
                            const SizedBox(width: 4),
                            Text(DateFormat.yMMMMd(Localizations.localeOf(context).languageCode).format(event.date),
                                style: const TextStyle(fontSize: 11)),
                            if (event.startTime != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.access_time, size: 14, color: Colors.teal),
                              const SizedBox(width: 4),
                              Text(
                                  event.endTime != null
                                      ? '${DateFormat.Hm(Localizations.localeOf(context).languageCode).format(event.startTime!)} - ${DateFormat.Hm(Localizations.localeOf(context).languageCode).format(event.endTime!)}'
                                      : DateFormat.Hm(Localizations.localeOf(context).languageCode).format(event.startTime!),
                                  style: const TextStyle(fontSize: 11)),
                            ],
                            if (event.japaneseTitle != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.translate, size: 14, color: Colors.blue, semanticLabel: 'Japanese translation available'),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue), 
                          onPressed: () => _editEvent(context, event, mosallaLogoUrl)
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red), 
                          onPressed: () => _deleteEvent(context, event)
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EventEditDialog extends StatefulWidget {
  final String mosallaId;
  final Event? event;
  final String? mosallaLogoUrl;
  const _EventEditDialog({Key? key, required this.mosallaId, this.event, this.mosallaLogoUrl}) : super(key: key);

  @override
  State<_EventEditDialog> createState() => _EventEditDialogState();
}

class _EventEditDialogState extends State<_EventEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _jaTitleController;
  late TextEditingController _jaDescController;
  late TextEditingController _imageController;
  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descController = TextEditingController(text: widget.event?.description ?? '');
    _jaTitleController = TextEditingController(text: widget.event?.japaneseTitle ?? '');
    _jaDescController = TextEditingController(text: widget.event?.japaneseDescription ?? '');
    _imageController = TextEditingController(text: widget.event?.imageUrl ?? '');
    _selectedDate = widget.event?.date ?? DateTime.now();
    
    if (widget.event?.startTime != null) {
      _startTime = TimeOfDay.fromDateTime(widget.event!.startTime!);
    }
    if (widget.event?.endTime != null) {
      _endTime = TimeOfDay.fromDateTime(widget.event!.endTime!);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initialTime = (isStart ? _startTime : _endTime) ?? const TimeOfDay(hour: 12, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    final startDateTime = _startTime != null 
        ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _startTime!.hour, _startTime!.minute)
        : null;
        
    final endDateTime = _endTime != null 
        ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _endTime!.hour, _endTime!.minute)
        : null;

    final event = Event(
      id: widget.event?.id ?? '',
      title: _titleController.text,
      description: _descController.text,
      japaneseTitle: _jaTitleController.text.isNotEmpty ? _jaTitleController.text : null,
      japaneseDescription: _jaDescController.text.isNotEmpty ? _jaDescController.text : null,
      imageUrl: _imageController.text,
      date: _selectedDate,
      startTime: startDateTime,
      endTime: endDateTime,
    );

    try {
      await context.read<MosallaRepository>().saveEvent(widget.mosallaId, event);
      if (mounted) {
        context.read<AdminDashboardProvider>().invalidateCache();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.event == null ? 'Add Event' : 'Edit Event',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Container(
        width: 600,
        constraints: const BoxConstraints(
          maxWidth: 600,
          minWidth: 300,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('English Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (English)',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (English)',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 24),
                const Text('Japanese Content (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _jaTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (Japanese)',
                    prefixIcon: Icon(Icons.translate),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _jaDescController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Japanese)',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 24),
                const Text('Logistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    prefixIcon: Icon(Icons.image_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'Leave empty to use mosque logo',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Date Picker
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.teal, size: 20),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Event Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(DateFormat.yMMMMd(Localizations.localeOf(context).languageCode).format(_selectedDate),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.edit, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.teal, size: 20),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Start Time', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  Text(_startTime?.format(context) ?? '--:--',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_filled, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('End Time', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  Text(_endTime?.format(context) ?? '--:--',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              if (_endTime != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 14),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => setState(() => _endTime = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save'),
        ),
      ],
    );
  }
}
