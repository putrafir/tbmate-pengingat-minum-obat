import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AlarmService {
  // Base key untuk identitas dasar channel
  static const String _baseChannelKey = 'tbmate_alarm_channel';

  static Future<String> getUserAlarmSound() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'classic_alarm';

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['alarmSound'] != null) {
          return data['alarmSound'];
        }
      }
      return 'classic_alarm';
    } catch (e) {
      debugPrint("Error ambil sound alarm: $e");
      return 'classic_alarm';
    }
  }

  // Inisialisasi awal saat aplikasi terbuka (membuat channel default)
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: '${_baseChannelKey}_classic_alarm',
          channelName: 'TBMate Alarm (Classic)',
          channelDescription: 'Alarm minum obat versi standar',
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/classic_alarm', // Default awal
          enableVibration: true,
          criticalAlerts: true,
          defaultColor: const Color(0xFF2E7D32),
          ledColor: const Color(0xFF2E7D32),
        )
      ],
      debug: true,
    );
    await requestPermissions();
  }

  // Membuat channel baru secara instan jika user memilih suara berbeda di Firestore
  static Future<String> _getOrInitializeDynamicChannel(String soundName) async {
    final dynamicChannelKey = '${_baseChannelKey}_$soundName';

    await AwesomeNotifications().setChannel(
      NotificationChannel(
        channelKey: dynamicChannelKey,
        channelName: 'TBMate Alarm ($soundName)',
        channelDescription: 'Alarm aktif menggunakan suara $soundName',
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: 'resource://raw/$soundName', // Mengunci suara spesifik ke channel ini
        enableVibration: true,
        criticalAlerts: true,
        defaultColor: const Color(0xFF2E7D32),
        ledColor: const Color(0xFF2E7D32),
      ),
    );

    return dynamicChannelKey;
  }

  static Future<void> requestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    if (!isAllowed) {
      await AwesomeNotifications().showAlarmPage();
    }
    
    // Check permission untuk basic channel
    await AwesomeNotifications().checkPermissionList(
      channelKey: '${_baseChannelKey}_classic_alarm',
      permissions: [
        NotificationPermission.PreciseAlarms,
        NotificationPermission.FullScreenIntent,
        NotificationPermission.CriticalAlert,
      ],
    );
  }

  static Future<void> scheduleAlarm({
    required int id,
    required DateTime date,
    required String docId,
  }) async {
    debugPrint("🔥 CREATE NOTIF → docId: $docId");
    if (date.isBefore(DateTime.now())) {
      debugPrint("DEBUG: Gagal menjadwalkan, waktu sudah lewat.");
      return;
    }

    // 1. Ambil nama suara dari Firestore
    final selectedSound = await getUserAlarmSound();
    debugPrint("SOUND FIREBASE: $selectedSound");

    // 2. Dapatkan Channel Key Dinamis berdasarkan jenis suara
    final activeChannelKey = await _getOrInitializeDynamicChannel(selectedSound);
    debugPrint("ACTIVE CHANNEL KEY: $activeChannelKey");

    String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: activeChannelKey, // 👈 Pakai channel baru di sini
        title: '💊 saatnya minum obat ya',
        body: '4 KDT RHZE, 3 tablet pukul 08.00 😊',
        notificationLayout: NotificationLayout.Default,
        largeIcon: 'resource://drawable/happy',
        color: const Color(0xFF2E7D32),
        backgroundColor: const Color(0xFFF0F2F5),
        icon: 'resource://drawable/tb_icon',
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        locked: true,
        autoDismissible: false,
        customSound: 'resource://raw/$selectedSound',
        payload: {"docId": docId},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'MINUM',
          label: ' Minum Sekarang 💊',
          actionType: ActionType.Default,
          color: const Color(0xFF2E7D32),
        ),
        NotificationActionButton(
            key: 'SKIP',
            label: 'Tunda Dulu',
            actionType: ActionType.Default,
            color: const Color(0xFF2E7D32))
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

  static Future<void> repeatSnooze(
      int id, Duration duration, String docId) async {
    debugPrint("🔥 SNOOZE → docId: $docId");
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('jadwal_obat')
        .doc(docId)
        .get();

    if (!doc.exists) {
      debugPrint("DEBUG: Document tidak ditemukan");
      return;
    }

    final tanggal = doc['tanggal'];
    final waktu = doc['waktu_minum'];
    final DateFormat format = DateFormat("yyyy-MM-dd hh:mm a");
    final DateTime jadwalAsli = format.parse("$tanggal $waktu");

    final DateTime jadwalBerikutnya = jadwalAsli.add(const Duration(days: 1));

    if (DateTime.now().isAfter(jadwalBerikutnya)) {
      await doc.reference.update({"status": "Terlewati"});
      return;
    }

    await AwesomeNotifications().cancel(id);
    String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();

    // 1. Ambil nama suara dari Firestore
    final selectedSound = await getUserAlarmSound();
    
    // 2. Dapatkan Channel Key Dinamis untuk Snooze
    final activeChannelKey = await _getOrInitializeDynamicChannel(selectedSound);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: activeChannelKey, // 👈 Pakai channel baru di sini
        title: '⏰ Pengingat Minum Obat',
        body: 'Obat belum diminum',
        category: NotificationCategory.Alarm,
        notificationLayout: NotificationLayout.Default,
        largeIcon: 'resource://drawable/happy',
        color: const Color(0xFF2E7D32),
        backgroundColor: Colors.white,
        icon: 'resource://drawable/tb_icon',
        wakeUpScreen: true,
        fullScreenIntent: true,
        locked: true,
        autoDismissible: false,
        criticalAlert: true,
        customSound: 'resource://raw/$selectedSound',
        payload: {"docId": docId},
      ),
      schedule: NotificationCalendar(
        year: DateTime.now().add(duration).year,
        month: DateTime.now().add(duration).month,
        day: DateTime.now().add(duration).day,
        hour: DateTime.now().add(duration).hour,
        minute: DateTime.now().add(duration).minute,
        second: 0,
        millisecond: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
        repeats: false,
        timeZone: localTimeZone,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'MINUM',
          label: 'SUDAH MINUM 💊',
          actionType: ActionType.Default,
          color: const Color(0xFF2E7D32),
        ),
        NotificationActionButton(
          key: 'SKIP',
          label: 'TUNDA LAGI',
          actionType: ActionType.Default,
          color: const Color(0xFF2E7D32),
        )
      ],
    );
  }
}