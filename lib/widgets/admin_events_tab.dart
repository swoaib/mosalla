import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/event.dart';
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();
    final events = provider.events;

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
      body: events.isEmpty
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
                            Text(DateFormat.yMMMMd().format(event.date), style: const TextStyle(fontSize: 12)),
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
  late TextEditingController _imageController;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descController = TextEditingController(text: widget.event?.description ?? '');
    _imageController = TextEditingController(text: widget.event?.imageUrl ?? '');
    _selectedDate = widget.event?.date ?? DateTime.now();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final event = Event(
      id: widget.event?.id ?? '',
      title: _titleController.text,
      description: _descController.text,
      imageUrl: _imageController.text,
      date: _selectedDate,
    );

    try {
      await context.read<MosallaRepository>().saveEvent(widget.mosallaId, event);
      if (mounted) Navigator.pop(context);
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
        width: 500, // Desired max width
        constraints: const BoxConstraints(
          maxWidth: 500,
          minWidth: 300,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.teal),
                    title: const Text('Event Date', style: TextStyle(fontSize: 14)),
                    subtitle: Text(DateFormat.yMMMMd().format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    trailing: const Icon(Icons.edit, size: 18),
                    onTap: _pickDate,
                  ),
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
