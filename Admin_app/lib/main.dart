import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Admin_app/dashboard_screen.dart';
import 'package:Admin_app/screens/cloud_messaging.dart';
import 'package:Admin_app/providers/stats_provider.dart';
//import 'package:gam/screens/RegisterAdmin.dart';
import 'package:Admin_app/screens/bookings_management_screen.dart';

import 'package:Admin_app/screens/services_approval_screen.dart';
import 'package:Admin_app/screens/services_screen.dart';
import 'package:Admin_app/screens/users_management_screen.dart';
import 'package:provider/provider.dart';
import 'package:Admin_app/providers/admin_provider.dart';
import 'package:Admin_app/screens/login_admin_screen.dart';
import 'package:Admin_app/screens/ContactUs_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // تهيئة FCM
  FirebaseMessaging.instance.subscribeToTopic('providers');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        //  ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        //'/login': (context) => const LoginAdminScreen(),
        '/login': (context) => const AdminLoginByUsername(),
        //'/signup': (context) => const RegisterAdmin(),
        '/dashboard': (context) => const DashboardScreen(),
        '/users': (context) => const UsersManagementScreen(),
        //'/services': (context) => AdminServicesScreen(),
        '/services': (context) => ServiceManagementScreen(),
        '/bookings': (context) => const BookingsManagementScreen(),
        '/NotificationPage': (context) => const NotificationPage(),

        '/ContactUs': (context) => MessagesScreen(),
      },
    );
  }
}
