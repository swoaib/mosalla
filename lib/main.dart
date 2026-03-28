import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:mosalla/providers/prayer_time_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:flutter/foundation.dart';
import 'pages/prayer_time_page.dart';
import 'pages/admin_login_page.dart';
import 'pages/admin_dashboard_page.dart';

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
    return ChangeNotifierProvider(
      create: (_) => PrayerTimeProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          //textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const PrayerTimePage(),
          '/admin': (context) => const AdminLoginPage(),
          '/admin/dashboard': (context) => const AdminDashboardPage(),
        },
      ),
    );
  }
}
