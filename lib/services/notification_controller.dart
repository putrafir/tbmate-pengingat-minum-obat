// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'alarm_service.dart';

// @pragma("vm:entry-point")
// class NotificationController {
//   // static Future<void> onActionReceived(ReceivedAction action) async {
//   //   if (action.buttonKeyPressed == 'MINUM') {
//   //     await AwesomeNotifications().cancel(action.id!);
//   //   }

//   //   if (action.buttonKeyPressed == 'SKIP') {
//   //     await AlarmService.repeat5Minutes(action.id!);
//   //   }
//   // }
//   @pragma("vm:entry-point")
//   static Future<void> onNotificationCreatedMethod(
//     ReceivedNotification receivedNotification) async {

//     }

//   @pragma("vm:entry-point")
//   static Future<void> onNotificationDisplayedMethod(
//       ReceivedNotification receivedNotification) async {

//       }

//   @pragma("vm:entry-point")
//   static Future<void> onDismissActionReceivedMethod(
//     ReceivedAction action) async {

//     }

//   @pragma("vm:entry-point")
//   static Future<void> onActionReceived(ReceivedAction action) async {
//     print("DEBUG: Tombol ditekan -> ${action.buttonKeyPressed}");

//     if (action.buttonKeyPressed == 'MINUM') {
//       await AwesomeNotifications().cancel(action.id!);
//     }
//     if (action.buttonKeyPressed == 'SKIP') {
//       await AlarmService.repeatSnooze(action.id!, const Duration(minutes: 5));
//     }
//     if (action.buttonKeyPressed.isEmpty) {
//       print("DEBUG: user mengklik nody notifikasi.");
//     }
//   }
// }
