import 'dart:io';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings.dart';
import '../models/task_item.dart';

class NotificationService {
  NotificationService({
    NotificationsPlugin? plugin,
    DateTime Function()? now,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPluginAdapter(),
        _now = now ?? DateTime.now;

  final NotificationsPlugin _plugin;
  final DateTime Function() _now;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    await _configureLocalTimeZone();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings);
    await _requestPermissions();
  }

  Future<void> scheduleTaskReminder(
    TaskItem task,
    AppSettings settings,
  ) async {
    final taskId = task.id;
    if (taskId == null || task.isCompleted) {
      return;
    }

    final reminderTime = task.dueDateTime;
    if (!reminderTime.isAfter(_now())) {
      return;
    }

    await _requestPermissions();

    await _plugin.zonedSchedule(
      taskId,
      'Upcoming task reminder',
      '${task.title} is due at ${_formatTime(task.dueDateTime)}',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelIdFor(settings.notificationSound),
          'Task reminders',
          channelDescription: 'Upcoming task alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskReminder(int taskId) async {
    await _plugin.cancel(taskId);
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _requestPermissions() async {
    await _plugin.requestPermissions(
      requestAndroidPermissions: Platform.isAndroid,
      requestApplePermissions: Platform.isIOS,
    );
  }

  String _channelIdFor(NotificationSound sound) {
    switch (sound) {
      case NotificationSound.defaultTone:
        return 'task_reminders_default';
      case NotificationSound.gentle:
        return 'task_reminders_gentle';
      case NotificationSound.urgent:
        return 'task_reminders_urgent';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:$minute $suffix';
  }
}

abstract class NotificationsPlugin {
  Future<bool?> initialize(InitializationSettings settings);

  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  });

  Future<void> cancel(int id);

  Future<void> requestPermissions({
    required bool requestAndroidPermissions,
    required bool requestApplePermissions,
  });
}

class FlutterLocalNotificationsPluginAdapter implements NotificationsPlugin {
  FlutterLocalNotificationsPluginAdapter({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<bool?> initialize(InitializationSettings settings) {
    return _plugin.initialize(settings);
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: androidScheduleMode,
      payload: payload,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  @override
  Future<void> cancel(int id) {
    return _plugin.cancel(id);
  }

  @override
  Future<void> requestPermissions({
    required bool requestAndroidPermissions,
    required bool requestApplePermissions,
  }) async {
    if (requestAndroidPermissions) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    if (requestApplePermissions) {
      final iosPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}
