import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/home_screen.dart';
import 'screens/about_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/healthcare/healthcare_shell.dart';
import 'screens/dashboard/dashboard_shell.dart';

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const MyApp({
    super.key,
    required this.notificationsPlugin,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Creation Virtual Health',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/about': (context) => const AboutScreen(),
        '/contact': (context) => const ContactScreen(),
        '/signin': (context) => const LoginScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/signup': (context) => const SignupFlowScreen(),

        // IMPORTANT: pass plugin into DashboardShell
        '/dashboard': (context) => DashboardShell(
              notificationsPlugin: notificationsPlugin,
            ),
        '/healthcare': (context) => const HealthcareShell(),
        '/admin': (context) => const AdminShell(),
      },
    );
  }
}
