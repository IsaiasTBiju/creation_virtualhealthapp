import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/about_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/healthcare/healthcare_shell.dart';
import 'screens/dashboard/dashboard_shell.dart';

class MyApp extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const MyApp({
    super.key,
    required this.notificationsPlugin,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appPrefs = AppPreferences();

  @override
  void initState() {
    super.initState();
    appPrefs.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appPrefs,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Creation Virtual Health',
        theme: appPrefs.buildTheme(),
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(appPrefs.textScale)),
            child: child ?? const SizedBox.shrink(),
          );
        },
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/about': (context) => const AboutScreen(),
          '/contact': (context) => const ContactScreen(),
          '/signin': (context) => LoginScreen(appPrefs: appPrefs),
          '/admin-login': (context) => const AdminLoginScreen(),
          '/signup': (context) => const SignupFlowScreen(),
          '/dashboard': (context) => DashboardShell(
                notificationsPlugin: widget.notificationsPlugin,
                appPrefs: appPrefs,
              ),
          '/healthcare': (context) => const HealthcareShell(),
          '/admin': (context) => const AdminShell(),
        },
      ),
    );
  }
}
