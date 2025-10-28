import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:services_providers/screens/home_page.dart';
import 'package:services_providers/screens/login_screen.dart';
import 'package:services_providers/theme/theme_provider.dart';
import 'package:services_providers/theme/theme_manager.dart';
import 'package:provider/provider.dart';

import 'screens/WalletSetupScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. Initialize Firebase first
    await Firebase.initializeApp();
    
    // 2. Initialize App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
    
    // 3. Only then initialize Messaging
    await FirebaseMessaging.instance.subscribeToTopic('providers');
    
    // Optional: Configure messaging settings
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'AE'),
          ],
          title: 'تطبيق مقدمي الخدمات',
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          home: FutureBuilder(
            future: _checkLoginStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                if (snapshot.data == true) {
                  return  HomePage();
                } else {
                  return  LoginScreen();
                }
              }
            },
          ),
          routes: {
            '/home': (context) =>  HomePage(),
            '/wallet-setup': (context) => WalletSetupScreen(),
          },
        );
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
