import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/providers/locale_provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
          Text(
            l10n.settings,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.theme),
                        content: RadioGroup<ThemeMode>(
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setThemeMode(value);
                            }
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
                      ),
                    );
                  },
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.language),
                         content: RadioGroup<String?>(
                          groupValue: localeProvider.locale?.languageCode,
                          onChanged: (value) {
                            if (value == null) {
                              localeProvider.setLocale(null);
                            } else {
                              localeProvider.setLocale(Locale(value));
                            }
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
                      ),
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
}
