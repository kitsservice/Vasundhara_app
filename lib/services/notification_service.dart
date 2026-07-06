import 'dart:io';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize Timezones
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // 2. Initialize the plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    _isInitialized = true;

    // 3. Request permissions immediately
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleDailyWateringReminders() async {
    // 7:00 AM Reminder
    await _scheduleDailyNotification(
      id: 101,
      title: 'Time to Water Your Trees! 🌳',
      body:
          'Your plants are thirsty. Give them some water to keep them healthy.',
      hour: 7,
      minute: 0,
    );

    // 7:00 PM Reminder
    await _scheduleDailyNotification(
      id: 102,
      title: 'Time to Water Your Trees! 🌳',
      body:
          'Your plants are thirsty. Give them some water to keep them healthy.',
      hour: 19,
      minute: 0,
    );
  }

  Future<void> showDemoNotification() async {
    await _flutterLocalNotificationsPlugin.show(
      999,
      'Time to Water Your Trees! 🌳 (Demo)',
      'Your plants are thirsty. Give them some water to keep them healthy.',
      _buildNotificationDetails(),
    );
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  NotificationDetails _buildNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'water_reminders_channel',
        'Water Reminders',
        channelDescription: 'Daily reminders to water your trees',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF10B981),
        largeIcon: DrawableResourceAndroidBitmap('cartoon_icon'),
        styleInformation: BigPictureStyleInformation(
          DrawableResourceAndroidBitmap('cartoon_bg'),
          largeIcon: DrawableResourceAndroidBitmap('cartoon_icon'),
          contentTitle: 'Time to Water Your Trees! 🌳',
          summaryText:
              'Your plants are thirsty. Give them some water to keep them healthy.',
          hideExpandedLargeIcon: false,
        ),
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'WATERED_ACTION',
            'Watered!',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'SNOOZE_ACTION',
            'Snooze',
            showsUserInterface: true,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
