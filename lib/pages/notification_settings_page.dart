import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import '../providers/notification_settings_provider.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
      ),
      body: Consumer<NotificationSettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // Master Switch Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: Text(l10n.allNotifications),
                  value: provider.allNotificationsEnabled,
                  onChanged: (value) => provider.setAllNotificationsEnabled(value),
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
                        color: Theme.of(context).colorScheme.primary,
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
                      title: Text(l10n.prayerTimeNotifications),
                      subtitle: Text(l10n.prayerTimeNotificationsDesc),
                      value: provider.prayersEnabled,
                      onChanged: (value) => provider.setPrayersEnabled(value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.event_note),
                      title: Text(l10n.eventNotifications),
                      subtitle: Text(l10n.eventNotificationsDesc),
                      value: provider.eventsEnabled,
                      onChanged: (value) => provider.setEventsEnabled(value),
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
