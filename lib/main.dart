import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:mosalla/providers/prayer_time_provider.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import 'firebase_options.dart';

import 'package:flutter/foundation.dart';
import 'package:mosalla/pages/main_navigation_page.dart';
import 'package:mosalla/pages/admin_login_page.dart';
import 'package:mosalla/pages/admin_dashboard_page.dart';
import 'package:mosalla/providers/locale_provider.dart';
import 'package:mosalla/providers/theme_provider.dart';
import 'package:mosalla/providers/admin_dashboard_provider.dart';
import 'package:mosalla/providers/notification_settings_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import 'repositories/auth_repository.dart';
import 'repositories/mosalla_repository.dart';
import 'package:mosalla/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  if (!kIsWeb) {
    HomeWidget.setAppGroupId('group.com.mosalla.app');
    await PushNotificationService.initialize();
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
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            themeMode:
                themeProvider.isTealTheme ? ThemeMode.light : themeProvider.themeMode,
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
            theme: themeProvider.isTealTheme
                ? _buildTealTheme()
                : _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
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

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.teal,
      primaryColor: Colors.teal,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.grey.withValues(alpha: 0.1),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.teal,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
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
    );
  }

  ThemeData _buildTealTheme() {
    const primaryTeal = Color(0xFF00695C); // Deep rich jewel teal
    const cardBg = Colors.white; // Crisp, luminous white card
    const textOnCard = Color(0xFF1E3A34); // Deep charcoal teal for highest legibility

    return ThemeData(
      primarySwatch: Colors.teal,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: primaryTeal,
      cardColor: cardBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.light,
        primary: primaryTeal,
        onPrimary: Colors.white,
        surface: cardBg,
        onSurface: textOnCard,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        unselectedItemColor: Color(0xFF78909C),
        selectedItemColor: Color(0xFF00695C),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: textOnCard,
        iconColor: Color(0xFF00695C),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.withValues(alpha: 0.15),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: textOnCard,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: textOnCard,
          fontSize: 16,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(primaryTeal),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textOnCard),
        bodyLarge: TextStyle(color: textOnCard),
        bodyMedium: TextStyle(color: textOnCard),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        width: kIsWeb ? 600 : null,
      ),
    );
  }
}
