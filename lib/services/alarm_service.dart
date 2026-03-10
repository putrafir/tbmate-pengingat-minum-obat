import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class AlarmService {
  // Gunakan channelKey baru untuk mereset cache Android
  static const String _channelKey = 'tbmate_alarm_v2';

  // ==========================================
  // 1. FUNGSI UTAMA (CORE FEATURES)
  // ==========================================

  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: 'TBMate Alarm',
          channelDescription: 'Alarm minum obat',
          importance: NotificationImportance.Max,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          playSound: true,
          enableVibration: true,
          criticalAlerts: true,
        )
      ],
      debug: true,
    );

    await requestPermissions();
  }

  static Future<void> requestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Khusus Android 12+ minta izin Exact Alarm secara eksplisit
    await AwesomeNotifications().checkPermissionList(
      channelKey: _channelKey,
      permissions: [
        NotificationPermission.PreciseAlarms,
        NotificationPermission.FullScreenIntent,
      ],
    );
  }

  static Future<void> scheduleAlarm({
    required int id,
    required DateTime date,
  }) async {
    if (date.isBefore(DateTime.now())) {
      debugPrint("DEBUG: Gagal menjadwalkan, waktu sudah lewat.");
      return;
    }

    String localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: 'Waktu Minum Obat',
        body: 'Saatnya minum obat TB',
        category: NotificationCategory.Alarm,
        criticalAlert: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        locked: true,
        autoDismissible: false,
        customSound: 'resource://raw/amba',
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'MINUM',
          label: 'Sudah Minum',
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'SKIP',
          label: 'Skip',
          actionType: ActionType.SilentAction,
        )
      ],
      schedule: NotificationCalendar(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: date.hour,
        minute: date.minute,
        second: 0,
        millisecond: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
        timeZone: localTimeZone,
      ),
    );
  }

  static Future<void> repeat5Minutes(int id) async {
    String localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: 'Pengingat Minum Obat',
        body: 'Obat belum diminum',
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        locked: true,
        autoDismissible: false,
        customSound: 'resource://raw/alarm_tbmate',
      ),
      schedule: NotificationInterval(
        interval: const Duration(minutes: 5),
        preciseAlarm: true,
        allowWhileIdle: true,
        repeats: true,
        timeZone: localTimeZone,
      ),
    );
  }

  static Future<void> cancelAlarm(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }

  // ==========================================
  // 2. FUNGSI DEBUGGING (UNTUK TESTING DI UI)
  // ==========================================

  /// Panggil ini di tombol untuk mengecek status izin Android
  static Future<void> debugCheckStatus() async {
    debugPrint("=== DEBUG MULAI ===");
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    debugPrint("1. Status Izin Dasar: $isAllowed");

    List<NotificationPermission> exactAlarmPerms =
        await AwesomeNotifications().checkPermissionList(
      channelKey: _channelKey,
      permissions: [NotificationPermission.PreciseAlarms],
    );
    debugPrint(
        "2. Izin Exact Alarm (Android 12+): ${exactAlarmPerms.isEmpty ? 'AMAN/DIIZINKAN' : 'DIBLOKIR'}");

    String tz = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    debugPrint("3. Timezone terdeteksi: $tz");
    debugPrint("===================");
  }

  /// Panggil ini untuk tes apakah notifikasi dasar bisa muncul (tanpa custom sound)
  static Future<void> debugTestInstant() async {
    debugPrint("DEBUG: Mencoba memunculkan notifikasi instan...");
    bool success = await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 888,
        channelKey: _channelKey,
        title: 'DEBUG INSTAN',
        body: 'Jika ini muncul, berarti channel dan init AMAN.',
        category: NotificationCategory.Alarm,
        // Sengaja tidak pakai custom sound untuk mengisolasi masalah file audio
      ),
    );
    debugPrint("DEBUG: Status Notifikasi Instan eksekusi: $success");
  }

  /// Panggil ini, lalu kunci layar HP. Tunggu 10 detik.
  static Future<void> debugTest10Seconds() async {
    DateTime waktuTes = DateTime.now().add(const Duration(seconds: 10));
    String localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();

    debugPrint("DEBUG: Menjadwalkan alarm untuk: $waktuTes");

    bool success = await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: _channelKey,
        title: 'DEBUG ALARM 10 DETIK',
        body: 'Berhasil! Alarm berjalan dari latar belakang.',
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        // Sengaja tidak pakai custom sound dulu
      ),
      schedule: NotificationCalendar(
        year: waktuTes.year,
        month: waktuTes.month,
        day: waktuTes.day,
        hour: waktuTes.hour,
        minute: waktuTes.minute,
        second: waktuTes.second,
        millisecond: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
        timeZone: localTimeZone,
      ),
    );
    debugPrint("DEBUG: Status Penjadwalan 10 detik: $success");
  }
}
