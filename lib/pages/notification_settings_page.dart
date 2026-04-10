import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import 'package:geolocator/geolocator.dart'; // Used to open app settings
import '../providers/notification_settings_provider.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Ensure status is fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationSettingsProvider>().checkPermissionStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationSettingsProvider>().checkPermissionStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
      ),
      body: Consumer<NotificationSettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // Permission Status Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Icon(
                    provider.isPermissionGranted
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: provider.isPermissionGranted
                        ? Theme.of(context).colorScheme.primary
                        : Colors.orange,
                  ),
                  title: Text(l10n.allNotifications),
                  subtitle: Text(
                    provider.isPermissionGranted
                        ? l10n.permissionGranted
                        : l10n.permissionDenied,
                    style: TextStyle(
                      color: provider.isPermissionGranted
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  trailing: !provider.isPermissionGranted
                      ? TextButton(
                          onPressed: () => Geolocator.openAppSettings(),
                          child: Text(l10n.openSettings),
                        )
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
              const SizedBox(height: 24),
              // Subtitle/Label for Granular Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l10n.preferences,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: provider.isPermissionGranted
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              // Granular Settings Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.access_time),
                      title: Text(l10n.prayerTimes),
                      value: provider.prayersEnabled,
                      onChanged: provider.isPermissionGranted
                          ? (value) => provider.setPrayersEnabled(value)
                          : null,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.event_note),
                      title: Text(l10n.events),
                      value: provider.eventsEnabled,
                      onChanged: provider.isPermissionGranted
                          ? (value) => provider.setEventsEnabled(value)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
