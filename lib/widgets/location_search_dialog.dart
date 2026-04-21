import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationSearchDialog extends StatefulWidget {
  const LocationSearchDialog({Key? key}) : super(key: key);

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
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
