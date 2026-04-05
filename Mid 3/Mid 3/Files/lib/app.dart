import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'data/task_repository.dart';
import 'models/app_settings.dart';
import 'screens/home_screen.dart';
import 'services/export_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

class TaskSprintApp extends StatefulWidget {
  const TaskSprintApp({
    super.key,
    required this.repository,
    required this.notificationService,
    required this.exportService,
  });

  final TaskRepository repository;
  final NotificationService notificationService;
  final ExportService exportService;

  static Future<void> bootstrap() async {
    WidgetsFlutterBinding.ensureInitialized();

    final database = AppDatabase();
    await database.initialize();

    final repository = TaskRepository(database);
    final notificationService = NotificationService();
    await notificationService.initialize();
    final exportService = ExportService();

    runApp(
      TaskSprintApp(
        repository: repository,
        notificationService: notificationService,
        exportService: exportService,
      ),
    );
  }

  @override
  State<TaskSprintApp> createState() => _TaskSprintAppState();
}

class _TaskSprintAppState extends State<TaskSprintApp> {
  late Future<AppSettings> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = widget.repository.loadSettings();
  }

  Future<void> _reloadSettings() async {
    setState(() {
      _settingsFuture = widget.repository.loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSettings>(
      future: _settingsFuture,
      builder: (context, snapshot) {
        final settings = snapshot.data ?? AppSettings.defaults();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Task Sprint Pro',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: HomeScreen(
            repository: widget.repository,
            notificationService: widget.notificationService,
            exportService: widget.exportService,
            settings: settings,
            onSettingsChanged: _reloadSettings,
          ),
        );
      },
    );
  }
}
