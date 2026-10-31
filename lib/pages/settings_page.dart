import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/providers/locale_provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_background.dart';
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
    final isTealTheme = themeProvider.isTealTheme;
    final cardColor = isTealTheme
        ? Colors.white.withValues(alpha: 0.12)
        : Theme.of(context).cardColor;
    final cardElevation = isTealTheme ? 0.0 : null;
    final cardShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));
    final textColor = isTealTheme ? Colors.white : null;
    final subtitleColor = isTealTheme ? Colors.white70 : Colors.grey[600];
    final iconColor = isTealTheme
        ? Colors.white.withValues(alpha: 0.85)
        : Theme.of(context).primaryColor;
    final chevronColor = isTealTheme ? Colors.white54 : Colors.grey;
    final dividerColor =
        isTealTheme ? Colors.white.withValues(alpha: 0.12) : null;

    return AppBackground(
      child: Scaffold(
        backgroundColor: isTealTheme ? Colors.transparent : null,
        appBar: AppBar(
          title: Text(l10n.settings),
        ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionHeader(context, l10n.appearance),
          const SizedBox(height: 8),
          Card(
            color: cardColor,
            elevation: cardElevation,
            shape: cardShape,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette_outlined, color: iconColor),
                  title: Text(
                    l10n.theme,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    themeProvider.appTheme == AppTheme.system
                        ? l10n.systemDefault
                        : themeProvider.appTheme == AppTheme.dark
                            ? l10n.dark
                            : themeProvider.appTheme == AppTheme.teal
                                ? l10n.teal
                                : l10n.light,
                    style: TextStyle(color: subtitleColor),
                  ),
                  trailing: Icon(Icons.chevron_right, color: chevronColor),
                  onTap: () =>
                      _showThemeBottomSheet(context, themeProvider, l10n),
                ),
                Divider(height: 1, color: dividerColor),
                ListTile(
                  leading: Icon(Icons.language, color: iconColor),
                  title: Text(
                    l10n.language,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    localeProvider.locale == null
                        ? l10n.systemDefault
                        : localeProvider.locale!.languageCode == 'en'
                            ? l10n.english
                            : l10n.japanese,
                    style: TextStyle(color: subtitleColor),
                  ),
                  trailing: Icon(Icons.chevron_right, color: chevronColor),
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
            color: cardColor,
            elevation: cardElevation,
            shape: cardShape,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_none_outlined,
                      color: iconColor),
                  title: Text(
                    l10n.notifications,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.chevron_right, color: chevronColor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationSettingsPage(),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: dividerColor),
                ListTile(
                  leading: Icon(Icons.location_on_outlined, color: iconColor),
                  title: Text(
                    l10n.location,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.chevron_right, color: chevronColor),
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
            color: cardColor,
            elevation: cardElevation,
            shape: cardShape,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.handshake_outlined, color: iconColor),
                  title: Text(
                    l10n.addYourMosque,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.chevron_right, color: chevronColor),
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
                Divider(height: 1, color: dividerColor),
                ListTile(
                  leading: Icon(Icons.feedback_outlined, color: iconColor),
                  title: Text(
                    l10n.feedbackTitle,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.chevron_right, color: chevronColor),
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
    ),
  );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final themeProvider = Provider.of<ThemeProvider?>(context);
    final isTealTheme = themeProvider?.isTealTheme ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isTealTheme
                  ? Colors.white.withValues(alpha: 0.8)
                  : Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context, ThemeProvider themeProvider,
      AppLocalizations l10n) {
    final isTealTheme = themeProvider.isTealTheme;
    final cardColor = isTealTheme
        ? Colors.white.withValues(alpha: 0.12)
        : Theme.of(context).cardColor;
    final cardElevation = isTealTheme ? 0.0 : null;
    final cardShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));
    final textColor = isTealTheme ? Colors.white : null;
    final dividerColor =
        isTealTheme ? Colors.white.withValues(alpha: 0.12) : null;

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
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isTealTheme ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.theme,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: cardColor,
                elevation: cardElevation,
                shape: cardShape,
                margin: EdgeInsets.zero,
                child: RadioGroup<AppTheme>(
                  groupValue: themeProvider.appTheme,
                  onChanged: (value) {
                    if (value != null) themeProvider.setAppTheme(value);
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<AppTheme>(
                        title: Text(
                          l10n.systemDefault,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: AppTheme.system,
                      ),
                      Divider(height: 1, color: dividerColor),
                      RadioListTile<AppTheme>(
                        title: Text(
                          l10n.light,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: AppTheme.light,
                      ),
                      Divider(height: 1, color: dividerColor),
                      RadioListTile<AppTheme>(
                        title: Text(
                          l10n.dark,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: AppTheme.dark,
                      ),
                      Divider(height: 1, color: dividerColor),
                      RadioListTile<AppTheme>(
                        title: Text(
                          l10n.teal,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: AppTheme.teal,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context,
      LocaleProvider localeProvider, AppLocalizations l10n) {
    final themeProvider = Provider.of<ThemeProvider?>(context, listen: false);
    final isTealTheme = themeProvider?.isTealTheme ?? false;
    final cardColor = isTealTheme
        ? Colors.white.withValues(alpha: 0.12)
        : Theme.of(context).cardColor;
    final cardElevation = isTealTheme ? 0.0 : null;
    final cardShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));
    final textColor = isTealTheme ? Colors.white : null;
    final dividerColor =
        isTealTheme ? Colors.white.withValues(alpha: 0.12) : null;

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
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isTealTheme ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: cardColor,
                elevation: cardElevation,
                shape: cardShape,
                margin: EdgeInsets.zero,
                child: RadioGroup<String?>(
                  groupValue: localeProvider.locale?.languageCode,
                  onChanged: (value) {
                    localeProvider
                        .setLocale(value != null ? Locale(value) : null);
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String?>(
                        title: Text(
                          l10n.systemDefault,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: null,
                      ),
                      Divider(height: 1, color: dividerColor),
                      RadioListTile<String?>(
                        title: Text(
                          l10n.english,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: 'en',
                      ),
                      Divider(height: 1, color: dividerColor),
                      RadioListTile<String?>(
                        title: Text(
                          l10n.japanese,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: 'ja',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
