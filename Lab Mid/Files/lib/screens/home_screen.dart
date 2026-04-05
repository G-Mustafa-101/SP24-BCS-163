import 'package:flutter/material.dart';

import '../data/task_repository.dart';
import '../models/app_settings.dart';
import '../models/task_item.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/task_editor_sheet.dart';
import 'sections/completed_tasks_section.dart';
import 'sections/repeated_tasks_section.dart';
import 'sections/today_tasks_section.dart';
import 'sections/upcoming_tasks_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.notificationService,
    required this.exportService,
    required this.settings,
    required this.onSettingsChanged,
  });

  final TaskRepository repository;
  final NotificationService notificationService;
  final ExportService exportService;
  final AppSettings settings;
  final Future<void> Function() onSettingsChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  List<TaskItem> _tasks = const [];

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    final tasks = await widget.repository.loadTasks();
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final todayTasks = _tasks.where((task) => task.isDueToday(now)).toList();
    final upcomingTasks = _tasks.where((task) => task.isUpcoming(now)).toList();
    final completedTasks = _tasks.where((task) => task.isCompleted).toList();
    final repeatedTasks = _tasks.where((task) => task.isRepeating).toList();
    final completionRate =
        _tasks.isEmpty ? 0.0 : completedTasks.length / _tasks.length;

    final sections = [
      TodayTasksSection(
        tasks: todayTasks,
        onComplete: _completeTask,
        onEdit: _editTask,
        onDelete: _deleteTask,
        onToggleSubtask: _toggleSubtask,
      ),
      UpcomingTasksSection(
        tasks: upcomingTasks,
        onComplete: _completeTask,
        onEdit: _editTask,
        onDelete: _deleteTask,
        onToggleSubtask: _toggleSubtask,
      ),
      CompletedTasksSection(
        tasks: completedTasks,
        onEdit: _editTask,
        onDelete: _deleteTask,
      ),
      RepeatedTasksSection(
        tasks: repeatedTasks,
        onComplete: _completeTask,
        onEdit: _editTask,
        onDelete: _deleteTask,
        onToggleSubtask: _toggleSubtask,
      ),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Task Sprint Pro'),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.tune_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: _handleExport,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'csv', child: Text('Export CSV')),
              PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
              PopupMenuItem(value: 'email', child: Text('Export Email')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTask,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('New Task'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_rounded), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.upcoming_rounded), label: 'Upcoming'),
          NavigationDestination(icon: Icon(Icons.done_all_rounded), label: 'Completed'),
          NavigationDestination(icon: Icon(Icons.repeat_rounded), label: 'Repeated'),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.16),
              theme.scaffoldBackgroundColor,
              theme.colorScheme.secondary.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshTasks,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    children: [
                      _OverviewCard(
                        totalTasks: _tasks.length,
                        completedTasks: completedTasks.length,
                        repeatedTasks: repeatedTasks.length,
                        completionRate: completionRate,
                      ),
                      const SizedBox(height: 20),
                      sections[_currentIndex],
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    final task = await TaskEditorSheet.show(context);
    if (task == null) {
      return;
    }
    final saved = await widget.repository.saveTask(task);
    await widget.notificationService.scheduleTaskReminder(saved, widget.settings);
    await _refreshTasks();
  }

  Future<void> _editTask(TaskItem existing) async {
    final task = await TaskEditorSheet.show(context, task: existing);
    if (task == null) {
      return;
    }
    final saved = await widget.repository.saveTask(task);
    if (saved.id != null) {
      await widget.notificationService.cancelTaskReminder(saved.id!);
      await widget.notificationService.scheduleTaskReminder(saved, widget.settings);
    }
    await _refreshTasks();
  }

  Future<void> _deleteTask(TaskItem task) async {
    if (task.id == null) {
      return;
    }
    await widget.repository.deleteTask(task.id!);
    await widget.notificationService.cancelTaskReminder(task.id!);
    await _refreshTasks();
  }

  Future<void> _completeTask(TaskItem task) async {
    await widget.repository.markTaskCompleted(task);
    if (task.id != null) {
      await widget.notificationService.cancelTaskReminder(task.id!);
    }
    await _refreshTasks();
  }

  Future<void> _toggleSubtask(TaskItem task, int index) async {
    final target = task.subtasks[index];
    await widget.repository.toggleSubtask(target, !target.isCompleted);

    final updatedSubtasks = [...task.subtasks];
    updatedSubtasks[index] = target.copyWith(isCompleted: !target.isCompleted);
    final shouldComplete =
        updatedSubtasks.isNotEmpty && updatedSubtasks.every((item) => item.isCompleted);

    if (shouldComplete && !task.isCompleted) {
      await widget.repository.markTaskCompleted(task);
    }
    await _refreshTasks();
  }

  Future<void> _openSettings() async {
    final updated = await SettingsSheet.show(context, settings: widget.settings);
    if (updated == null) {
      return;
    }
    await widget.repository.saveSettings(updated);
    await widget.onSettingsChanged();
    await _refreshTasks();
  }

  Future<void> _handleExport(String type) async {
    switch (type) {
      case 'csv':
        await widget.exportService.exportCsv(_tasks);
        break;
      case 'pdf':
        await widget.exportService.exportPdf(_tasks);
        break;
      case 'email':
        await widget.exportService.exportEmail(_tasks);
        break;
    }
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.totalTasks,
    required this.completedTasks,
    required this.repeatedTasks,
    required this.completionRate,
  });

  final int totalTasks;
  final int completedTasks;
  final int repeatedTasks;
  final double completionRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            Color.alphaBlend(
              theme.colorScheme.secondary.withValues(alpha: 0.28),
              theme.colorScheme.primary,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.26),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall progress',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A clean snapshot of your workload, completions, and repeating routines.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 14,
              value: completionRate,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF9D57C)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(completionRate * 100).round()}% of tasks completed',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _StatPill(label: 'Total', value: '$totalTasks')),
              const SizedBox(width: 10),
              Expanded(child: _StatPill(label: 'Done', value: '$completedTasks')),
              const SizedBox(width: 10),
              Expanded(child: _StatPill(label: 'Repeat', value: '$repeatedTasks')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
