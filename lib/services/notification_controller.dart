import 'package:awesome_notifications/awesome_notifications.dart';
import 'alarm_service.dart';

class NotificationController {
  static Future<void> onActionReceived(ReceivedAction action) async {
    if (action.buttonKeyPressed == 'MINUM') {
      await AwesomeNotifications().cancel(action.id!);
    }

    if (action.buttonKeyPressed == 'SKIP') {
      await AlarmService.repeat5Minutes(action.id!);
    }
  }
}
