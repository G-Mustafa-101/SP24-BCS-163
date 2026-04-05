import 'package:flutter/material.dart';

import '../models/app_settings.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    required this.settings,
  });

  final AppSettings settings;

  static Future<AppSettings?> show(
    BuildContext context, {
    required AppSettings settings,
  }) {
    return showModalBottomSheet<AppSettings>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsSheet(settings: settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ThemeMode selectedTheme = settings.themeMode;
    NotificationSound selectedSound = settings.notificationSound;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customize your workspace',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Theme mode',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ],
                selected: {selectedTheme},
                onSelectionChanged: (selection) {
                  setModalState(() {
                    selectedTheme = selection.first;
                  });
                },
              ),
              const SizedBox(height: 18),
              Text(
                'Notification sound profile',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<NotificationSound>(
                initialValue: selectedSound,
                items: const [
                  DropdownMenuItem(
                    value: NotificationSound.defaultTone,
                    child: Text('Default'),
                  ),
                  DropdownMenuItem(
                    value: NotificationSound.gentle,
                    child: Text('Gentle'),
                  ),
                  DropdownMenuItem(
                    value: NotificationSound.urgent,
                    child: Text('Urgent'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setModalState(() {
                    selectedSound = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      settings.copyWith(
                        themeMode: selectedTheme,
                        notificationSound: selectedSound,
                      ),
                    );
                  },
                  child: const Text('Save preferences'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
