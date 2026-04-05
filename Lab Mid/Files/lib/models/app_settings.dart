import 'package:flutter/material.dart';

enum NotificationSound { defaultTone, gentle, urgent }

class AppSettings {
  const AppSettings({
    this.id = 1,
    required this.themeMode,
    required this.notificationSound,
  });

  final int id;
  final ThemeMode themeMode;
  final NotificationSound notificationSound;

  factory AppSettings.defaults() {
    return const AppSettings(
      themeMode: ThemeMode.system,
      notificationSound: NotificationSound.defaultTone,
    );
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    NotificationSound? notificationSound,
  }) {
    return AppSettings(
      id: id,
      themeMode: themeMode ?? this.themeMode,
      notificationSound: notificationSound ?? this.notificationSound,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'theme_mode': themeMode.name,
      'notification_sound': notificationSound.name,
    };
  }

  factory AppSettings.fromMap(Map<String, Object?> map) {
    return AppSettings(
      id: map['id'] as int? ?? 1,
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == map['theme_mode'],
        orElse: () => ThemeMode.system,
      ),
      notificationSound: NotificationSound.values.firstWhere(
        (mode) => mode.name == map['notification_sound'],
        orElse: () => NotificationSound.defaultTone,
      ),
    );
  }
}
