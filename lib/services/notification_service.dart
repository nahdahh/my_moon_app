import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _notificationHistoryKey = 'notification_history';
  static const String _notificationSettingsKey = 'notification_settings';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print("Initializing NotificationService...");
      
      // Request permissions
      await _requestPermissions();

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      // Initialize WorkManager
      try {
        await Workmanager().initialize(
          callbackDispatcher,
          isInDebugMode: false,
        );
      } catch (e) {
        print("WorkManager initialization error: $e");
      }

      _isInitialized = true;
      print("NotificationService initialized successfully");
    } catch (e) {
      print("Error initializing NotificationService: $e");
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        await Permission.notification.request();
      } else if (Platform.isIOS) {
        await Permission.notification.request();
      }
    } catch (e) {
      print("Error requesting permissions: $e");
    }
  }

  Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'period_tracker_channel',
        'Period Tracker Notifications',
        description: 'Notifications for period tracking reminders',
        importance: Importance.high,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
      }
    } catch (e) {
      print("Error creating notification channel: $e");
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print("Notification tapped: ${response.payload}");
  }

  Future<void> showTestNotification() async {
    try {
      if (!_isInitialized) await initialize();
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'period_tracker_channel',
        'Period Tracker Notifications',
        channelDescription: 'Notifications for period tracking reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Test Notification 🌸',
        'This is a test notification from My Moon app! Everything is working perfectly.',
        platformChannelSpecifics,
      );

      // Add to notification history
      await _addToNotificationHistory({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'test',
        'title': 'Test Notification 🌸',
        'body': 'This is a test notification from My Moon app! Everything is working perfectly.',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });

      print("Test notification sent successfully");
    } catch (e) {
      print("Error sending test notification: $e");
    }
  }

  Future<void> showPeriodReminder() async {
    try {
      if (!_isInitialized) await initialize();
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'period_tracker_channel',
        'Period Tracker Notifications',
        channelDescription: 'Notifications for period tracking reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        1,
        'Period Reminder 🩸',
        'Your period is expected to start tomorrow. Don\'t forget to prepare! 💕',
        platformChannelSpecifics,
      );

      // Add to notification history
      await _addToNotificationHistory({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'period_reminder',
        'title': 'Period Reminder 🩸',
        'body': 'Your period is expected to start tomorrow. Don\'t forget to prepare! 💕',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });

      print("Period reminder sent successfully");
    } catch (e) {
      print("Error sending period reminder: $e");
    }
  }

  Future<void> showDailyLogReminder() async {
    try {
      if (!_isInitialized) await initialize();
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'period_tracker_channel',
        'Period Tracker Notifications',
        channelDescription: 'Notifications for period tracking reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        2,
        'Daily Log Reminder 📝',
        'How are you feeling today? Don\'t forget to log your mood and symptoms! 💕',
        platformChannelSpecifics,
      );

      // Add to notification history
      await _addToNotificationHistory({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'daily_log',
        'title': 'Daily Log Reminder 📝',
        'body': 'How are you feeling today? Don\'t forget to log your mood and symptoms! 💕',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });

      print("Daily log reminder sent successfully");
    } catch (e) {
      print("Error sending daily log reminder: $e");
    }
  }

  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_notificationSettingsKey);
      
      if (settingsJson != null) {
        return Map<String, dynamic>.from(json.decode(settingsJson));
      }
      
      // Default settings
      return {
        'period_reminder_enabled': true,
        'late_period_alert_enabled': true,
        'daily_log_reminder_enabled': true,
        'daily_reminder_hour': 20,
        'daily_reminder_minute': 0,
      };
    } catch (e) {
      print("Error getting notification settings: $e");
      return {
        'period_reminder_enabled': true,
        'late_period_alert_enabled': true,
        'daily_log_reminder_enabled': true,
        'daily_reminder_hour': 20,
        'daily_reminder_minute': 0,
      };
    }
  }

  Future<void> updateNotificationSettings({
    required bool periodReminder,
    required bool latePeriodAlert,
    required bool dailyLogReminder,
    required int dailyReminderHour,
    required int dailyReminderMinute,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = {
        'period_reminder_enabled': periodReminder,
        'late_period_alert_enabled': latePeriodAlert,
        'daily_log_reminder_enabled': dailyLogReminder,
        'daily_reminder_hour': dailyReminderHour,
        'daily_reminder_minute': dailyReminderMinute,
      };
      
      await prefs.setString(_notificationSettingsKey, json.encode(settings));
      print("Notification settings updated");
    } catch (e) {
      print("Error updating notification settings: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_notificationHistoryKey);
      
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        return historyList.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print("Error getting notification history: $e");
      return [];
    }
  }

  Future<void> _addToNotificationHistory(Map<String, dynamic> notification) async {
    try {
      final history = await getNotificationHistory();
      history.insert(0, notification);
      
      // Keep only last 50 notifications
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationHistoryKey, json.encode(history));
    } catch (e) {
      print("Error adding to notification history: $e");
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final history = await getNotificationHistory();
      final index = history.indexWhere((n) => n['id'] == notificationId);
      
      if (index != -1) {
        history[index]['isRead'] = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_notificationHistoryKey, json.encode(history));
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationHistoryKey);
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      print("Error clearing all notifications: $e");
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print("Background task executed: $task");
      return Future.value(true);
    } catch (e) {
      print("Error in background task: $e");
      return Future.value(false);
    }
  });
}
