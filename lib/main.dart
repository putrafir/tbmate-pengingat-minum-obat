import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tbmate_kmipn/app_router.dart';
import 'package:tbmate_kmipn/services/alarm_service.dart';
import 'firebase_options.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:tbmate_kmipn/services/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  await AlarmService.init();
  
  await AwesomeNotifications().requestPermissionToSendNotifications();
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceived,
  );
  await initializeDateFormatting('id_ID', null);
  runApp(const TBMateApp());
}

class TBMateApp extends StatelessWidget {
  const TBMateApp({super.key});

  @override

  /// Builds a [MaterialApp] widget with the given configuration.
  ///
  /// The [MaterialApp] is configured with the given [appRouter] as the router
  /// configuration, the given [String] as the title, and the debug checked mode
  /// banner is disabled. The theme is set to a [ThemeData] with the 'Poppins'

  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'TBMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
    );
  }
}