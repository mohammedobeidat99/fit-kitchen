import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleWaterReminder(int intervalMinutes) async {
    // Cancel existing reminders first
    await _notificationsPlugin.cancel(100);

    if (intervalMinutes <= 0) return;

    await _notificationsPlugin.periodicallyShow(
      100,
      'Drink Water! 💧',
      'It\'s time for a glass of water to stay fit and hydrated.',
      RepeatInterval.values.firstWhere(
        (e) => e.index == _getRepeatIntervalIndex(intervalMinutes),
        orElse: () => RepeatInterval.everyMinute, // Fallback
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminders',
          'Water Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  int _getRepeatIntervalIndex(int minutes) {
    if (minutes <= 1) return RepeatInterval.everyMinute.index;
    if (minutes <= 60) return RepeatInterval.hourly.index;
    return RepeatInterval.daily.index;
  }

  Future<void> scheduleExpiryNotification(String itemName, DateTime expiryDate) async {
    final scheduledDate = expiryDate.subtract(const Duration(days: 1)); // Notify 1 day before
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      itemName.hashCode,
      'Ingredient Expiring Soon! 🍎',
      'Your $itemName will expire tomorrow. Use it soon!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_reminders',
          'Expiry Reminders',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
