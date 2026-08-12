import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/providers/locale_provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import '../providers/theme_provider.dart';
import 'notification_settings_page.dart';
import 'location_settings_page.dart';
import '../widgets/feedback_sentiment_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionHeader(context, l10n.appearance),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(l10n.theme),
                  subtitle: Text(
                    themeProvider.themeMode == ThemeMode.system
                        ? l10n.systemDefault
                        : themeProvider.themeMode == ThemeMode.dark
                            ? l10n.dark
                            : l10n.light,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showThemeBottomSheet(context, themeProvider, l10n),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  subtitle: Text(
                    localeProvider.locale == null
                        ? l10n.systemDefault
                        : localeProvider.locale!.languageCode == 'en'
                            ? l10n.english
                            : l10n.japanese,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showLanguageBottomSheet(context, localeProvider, l10n),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, l10n.preferences),
          const SizedBox(height: 8),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_none_outlined),
                  title: Text(l10n.notifications),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationSettingsPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(l10n.location),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationSettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, l10n.support),
          const SizedBox(height: 8),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.handshake_outlined),
                  title: Text(l10n.addYourMosque),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final String subject = Uri.encodeComponent('Add New Mosque to Mosalla App');
                    final String body = Uri.encodeComponent(
                      'Please include the following details about the mosque:\n\n'
                      '- Name of the mosque:\n'
                      '- Location of the mosque:\n'
                      '- Year founded:',
                    );
                    final Uri emailLaunchUri = Uri.parse(
                      'mailto:scalier.foe-7h@icloud.com?subject=$subject&body=$body',
                    );
                    if (!await launchUrl(emailLaunchUri) && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open email application')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: Text(l10n.feedbackTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) =>
                          const FeedbackSentimentBottomSheet(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context, ThemeProvider themeProvider,
      AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.theme,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            RadioGroup<ThemeMode>(
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) themeProvider.setThemeMode(value);
                Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.systemDefault),
                    value: ThemeMode.system,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.light),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.dark),
                    value: ThemeMode.dark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context,
      LocaleProvider localeProvider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            RadioGroup<String?>(
              groupValue: localeProvider.locale?.languageCode,
              onChanged: (value) {
                localeProvider.setLocale(value != null ? Locale(value) : null);
                Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String?>(
                    title: Text(l10n.systemDefault),
                    value: null,
                  ),
                  RadioListTile<String?>(
                    title: Text(l10n.english),
                    value: 'en',
                  ),
                  RadioListTile<String?>(
                    title: Text(l10n.japanese),
                    value: 'ja',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
