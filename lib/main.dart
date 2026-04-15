// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tbmate_kmipn/app_router.dart';
import 'package:tbmate_kmipn/services/alarm_service.dart';
import 'firebase_options.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:tbmate_kmipn/services/notification_controller.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  // await AlarmService.init();

  // // 🔹 Listener TETAP di sini
  // AwesomeNotifications().setListeners(
  //   onActionReceivedMethod: NotificationController.onActionReceived,
  //   onNotificationDisplayedMethod:
  //       NotificationController.onNotificationDisplayedMethod,
  //   onNotificationCreatedMethod:
  //       NotificationController.onNotificationCreatedMethod,
  //   onDismissActionReceivedMethod:
  //       NotificationController.onDismissActionReceivedMethod,
  // );

  await initializeDateFormatting('id_ID', null);

  // 🔴 BARIS REQUEST PERMISSION SUDAH DIHAPUS DARI SINI

  runApp(const TBMateApp());
}

class TBMateApp extends StatelessWidget {
  const TBMateApp({super.key});

  @override
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
