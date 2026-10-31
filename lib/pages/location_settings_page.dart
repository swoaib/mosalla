import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_background.dart';

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
    final themeProvider = Provider.of<ThemeProvider?>(context);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final isTealTheme = (themeProvider?.isTealTheme ?? false) ||
        scaffoldBg == Colors.teal ||
        scaffoldBg == const Color(0xFF00695C);

    final cardColor = isTealTheme
        ? Colors.white.withValues(alpha: 0.12)
        : Theme.of(context).cardColor;
    final cardElevation = isTealTheme ? 0.0 : null;
    final cardShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));
    final textColor = isTealTheme ? Colors.white : null;

    return AppBackground(
      child: Scaffold(
        backgroundColor: isTealTheme ? Colors.transparent : null,
        appBar: AppBar(
          title: Text(l10n.locationSettings),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  Card(
                    color: cardColor,
                    elevation: cardElevation,
                    shape: cardShape,
                    child: ListTile(
                      leading: Icon(
                        isGranted
                            ? Icons.location_on_outlined
                            : Icons.location_off_outlined,
                        color: isGranted
                            ? (isTealTheme
                                ? const Color(0xFF00BFA5)
                                : Theme.of(context).colorScheme.primary)
                            : Colors.orange,
                      ),
                      title: Text(
                        l10n.locationStatus,
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        isGranted
                            ? l10n.permissionGranted
                            : l10n.permissionDenied,
                        style: TextStyle(
                          color: isGranted
                              ? (isTealTheme
                                  ? const Color(0xFF69F0AE)
                                  : Colors.green)
                              : Colors.orange,
                        ),
                      ),
                      trailing: !isGranted
                          ? TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    isTealTheme ? Colors.white : null,
                              ),
                              onPressed: () => Geolocator.openAppSettings(),
                              child: Text(l10n.openSettings),
                            )
                          : Icon(
                              Icons.check_circle,
                              color: isTealTheme
                                  ? const Color(0xFF69F0AE)
                                  : Colors.green,
                            ),
                    ),
                  ),
                  if (!isGranted) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        l10n.locationAccessRequired,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isTealTheme
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
