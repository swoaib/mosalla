import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import 'package:geolocator/geolocator.dart'; // Used to open app settings
import '../providers/notification_settings_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_background.dart';

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
                color: cardColor,
                elevation: cardElevation,
                shape: cardShape,
                child: ListTile(
                  leading: Icon(
                    provider.isPermissionGranted
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: provider.isPermissionGranted
                        ? (isTealTheme
                            ? const Color(0xFF00BFA5)
                            : Theme.of(context).colorScheme.primary)
                        : Colors.orange,
                  ),
                  title: Text(
                    l10n.allNotifications,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    provider.isPermissionGranted
                        ? l10n.permissionGranted
                        : l10n.permissionDenied,
                    style: TextStyle(
                      color: provider.isPermissionGranted
                          ? (isTealTheme
                              ? const Color(0xFF69F0AE)
                              : Colors.green)
                          : Colors.orange,
                    ),
                  ),
                  trailing: !provider.isPermissionGranted
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
              const SizedBox(height: 24),
              // Subtitle/Label for Granular Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l10n.preferences,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isTealTheme
                            ? (provider.isPermissionGranted
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.white38)
                            : (provider.isPermissionGranted
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey),
                      ),
                ),
              ),
              const SizedBox(height: 8),
              // Granular Settings Card
              Card(
                color: cardColor,
                elevation: cardElevation,
                shape: cardShape,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        Icons.access_time,
                        color: isTealTheme
                            ? Colors.white.withValues(alpha: 0.85)
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text(
                            l10n.prayerTimes,
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.w500),
                          ),
                          if (provider.isPrayersLoading) ...[
                            const SizedBox(width: 12),
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ],
                        ],
                      ),
                      value: provider.prayersEnabled,
                      activeThumbColor:
                          isTealTheme ? const Color(0xFF00BFA5) : null,
                      onChanged: provider.isPermissionGranted &&
                              !provider.isPrayersLoading
                          ? (value) async {
                              try {
                                await provider.setPrayersEnabled(value);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text(l10n.notificationUpdateError)),
                                  );
                                }
                              }
                            }
                          : null,
                    ),
                    Divider(
                      height: 1,
                      color: isTealTheme
                          ? Colors.white.withValues(alpha: 0.12)
                          : null,
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.event_note,
                        color: isTealTheme
                            ? Colors.white.withValues(alpha: 0.85)
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text(
                            l10n.events,
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.w500),
                          ),
                          if (provider.isEventsLoading) ...[
                            const SizedBox(width: 12),
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ],
                        ],
                      ),
                      value: provider.eventsEnabled,
                      activeThumbColor:
                          isTealTheme ? const Color(0xFF00BFA5) : null,
                      onChanged: provider.isPermissionGranted &&
                              !provider.isEventsLoading
                          ? (value) async {
                              try {
                                await provider.setEventsEnabled(value);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text(l10n.notificationUpdateError)),
                                  );
                                }
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
}
