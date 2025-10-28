import 'package:Users_app/chat/services/chat_service.dart';
import 'package:Users_app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:Users_app/screens/OnboardingScreen%20.dart'; 
import 'Chatbot/screens/ChatbotPage.dart';
import 'screens/HomePage.dart'; 
import 'screens/EventServicesPage.dart';

import 'screens/LearnMore.dart'; 
import 'theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.subscribeToTopic('clients');
  runApp( MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
       Provider(create: (context) => ChatService()), // ✅ استخدام Provider عادي لـ ChatService
      ],
      child: MyApp(),
    ),
    );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('ar'); // اللغة الافتراضية


  @override
  Widget build(BuildContext context) {
     final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale, // تحديد اللغة الحالية
     localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'AE'),
          ],
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      home: OnboardingScreen(), // الصفحة الأولى
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginScreen(), 
        '/services': (context) => EventServicesPage(),
        '/chatbot': (context) => ChatbotScreen(),
        '/Learnmore': (context) => LearnMore(),
      },
    );
  }
}