import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifPlugin = FlutterLocalNotificationsPlugin();

  // Konfigurasi OneSignal
  static const String oneSignalAppId = '';
  static const String oneSignalRestApiKey = '';

  Future<void> init() async {
    // 1. Inisialisasi OneSignal
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(oneSignalAppId);
      OneSignal.Notifications.requestPermission(true);
      
      // Sinkronkan tag OneSignal dengan preferensi lokal pengguna
      final sp = await SharedPreferences.getInstance();
      final bool beasiswaBaru = sp.getBool('notif_beasiswa_baru') ?? true;
      if (beasiswaBaru) {
        OneSignal.User.addTagWithKey('new_scholarship', '1');
      } else {
        OneSignal.User.removeTag('new_scholarship');
      }

      debugPrint('OneSignal berhasil diinisialisasi');
    } catch (e) {
      debugPrint('Gagal inisialisasi OneSignal: $e');
    }

    // 2. Inisialisasi Local Notifications
    try {
      tz.initializeTimeZones();
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );
      
      await _localNotifPlugin.initialize(initializationSettings);
      
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _localNotifPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          await androidPlugin.requestNotificationsPermission();
        }
      }
      debugPrint('Local Notifications berhasil diinisialisasi');
    } catch (e) {
      debugPrint('Gagal inisialisasi Local Notifications: $e');
    }
  }

  /// Menjadwalkan Pengingat Deadline
  Future<void> jadwalkanPengingatDeadline({
    required int idBeasiswa,
    required String namaBeasiswa,
    required DateTime waktuPenutupan,
    required int hMinus,
  }) async {
    try {
      DateTime jadwalLokal = waktuPenutupan.subtract(Duration(days: hMinus));
      jadwalLokal = DateTime(jadwalLokal.year, jadwalLokal.month, jadwalLokal.day, 9, 0, 0);

      if (jadwalLokal.isBefore(DateTime.now())) {
        debugPrint('Waktu pengingat sudah terlewat, membatalkan alarm lokal.');
        return;
      }

      final tz.TZDateTime jadwalTZ = tz.TZDateTime.from(jadwalLokal, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'deadline_channel',
        'Pengingat Deadline',
        channelDescription: 'Notifikasi untuk mengingatkan deadline beasiswa',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails notifDetails = NotificationDetails(android: androidDetails);

      await _localNotifPlugin.zonedSchedule(
        idBeasiswa,
        'Deadline Semakin Dekat! ⏳',
        'Pendaftaran $namaBeasiswa akan ditutup dalam $hMinus hari. Segera daftar!',
        jadwalTZ,
        notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Berhasil menjadwalkan alarm lokal id $idBeasiswa pada $jadwalLokal');
    } catch (e) {
      debugPrint('Gagal menjadwalkan notifikasi lokal: $e');
    }
  }

  /// Membatalkan pengingat
  Future<void> batalkanPengingat(int idBeasiswa) async {
    try {
      await _localNotifPlugin.cancel(idBeasiswa);
      debugPrint('Berhasil membatalkan alarm lokal id: $idBeasiswa');
    } catch (e) {
      debugPrint('Gagal membatalkan notifikasi lokal: $e');
    }
  }

  /// Menembakkan Push Notification OneSignal via REST API
  Future<void> kirimNotifikasiBeasiswaBaru(String judulBeasiswa, String deskripsi) async {
    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $oneSignalRestApiKey',
        },
        body: jsonEncode({
          'app_id': oneSignalAppId,
          'included_segments': ['Subscribed Users'],
          'headings': {'en': '🎓 Beasiswa Baru Tersedia!'},
          'contents': {'en': '$judulBeasiswa - $deskripsi'},
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Push Notification Beasiswa Baru berhasil ditembakkan!');
        debugPrint('Detail Server: ${response.body}');
      } else {
        debugPrint('Gagal mengirim Push Notification: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error saat memanggil API OneSignal: $e');
    }
  }
}
