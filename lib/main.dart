import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:mosalla/providers/prayer_time_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:flutter/foundation.dart';
import 'package:mosalla/pages/main_navigation_page.dart';
import 'package:mosalla/pages/admin_login_page.dart';
import 'package:mosalla/pages/admin_dashboard_page.dart';
import 'package:mosalla/providers/locale_provider.dart';
import 'package:mosalla/providers/theme_provider.dart';
import 'package:mosalla/providers/admin_dashboard_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import 'repositories/auth_repository.dart';
import 'repositories/mosalla_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // for Android
        statusBarIconBrightness: Brightness.dark, // for Android
        statusBarBrightness: Brightness.light // for IOS
        ));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRepository()),
        Provider<MosallaRepository>(create: (_) => MosallaRepository()),
        ChangeNotifierProvider(
            create: (context) => PrayerTimeProvider(
                repository: context.read<MosallaRepository>())),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Mosalla Admin',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ja', ''),
            ],
            theme: ThemeData(
              primarySwatch: Colors.teal,
              primaryColor: Colors.teal,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                unselectedItemColor: Colors.grey,
                selectedItemColor: Colors.teal,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              snackBarTheme: const SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                width: kIsWeb ? 600 : null,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.teal,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF1E1E1E),
                unselectedItemColor: Colors.grey,
                selectedItemColor: Colors.teal,
              ),
              snackBarTheme: const SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                width: kIsWeb ? 400 : null,
              ),
            ),
            initialRoute: kIsWeb ? '/admin' : '/',
            routes: {
              '/': (context) => const MainNavigationPage(),
              '/admin': (context) {
                final auth = context.watch<AuthRepository>();
                if (auth.currentUser != null) {
                  return const AdminDashboardPage();
                }
                return const AdminLoginPage();
              },
            },
          );
        },
      ),
    );
  }
}
