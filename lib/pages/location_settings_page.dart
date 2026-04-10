import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';

class LocationSettingsPage extends StatefulWidget {
  const LocationSettingsPage({Key? key}) : super(key: key);

  @override
  State<LocationSettingsPage> createState() => _LocationSettingsPageState();
}

class _LocationSettingsPageState extends State<LocationSettingsPage>
    with WidgetsBindingObserver {
  LocationPermission? _locationPermission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    setState(() => _isLoading = true);
    final permission = await Geolocator.checkPermission();
    if (mounted) {
      setState(() {
        _locationPermission = permission;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGranted = _locationPermission == LocationPermission.always ||
        _locationPermission == LocationPermission.whileInUse;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.locationSettings),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isGranted
                          ? Icons.location_on_outlined
                          : Icons.location_off_outlined,
                      color: isGranted
                          ? Theme.of(context).colorScheme.primary
                          : Colors.orange,
                    ),
                    title: Text(l10n.locationStatus),
                    subtitle: Text(
                      isGranted
                          ? l10n.permissionGranted
                          : l10n.permissionDenied,
                      style: TextStyle(
                        color: isGranted ? Colors.green : Colors.orange,
                      ),
                    ),
                    trailing: !isGranted
                        ? TextButton(
                            onPressed: () => Geolocator.openAppSettings(),
                            child: Text(l10n.openSettings),
                          )
                        : const Icon(Icons.check_circle, color: Colors.green),
                  ),
                ),
                if (!isGranted) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n.locationAccessRequired,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
