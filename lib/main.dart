import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // REQUIRED for zonedSchedule()
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC')); 
  // If you want device timezone instead:
  // tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();

  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await notificationsPlugin.initialize(initSettings);

  runApp(MyApp(notificationsPlugin: notificationsPlugin));
}
