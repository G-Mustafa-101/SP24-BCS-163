import 'package:sqflite/sqflite.dart';

import '../models/app_settings.dart';
import '../models/subtask_item.dart';
import '../models/task_item.dart';
import 'app_database.dart';

class TaskRepository {
  TaskRepository(this._database);

  final AppDatabase _database;

  Future<List<TaskItem>> loadTasks() async {
    final db = _database.instance;
    await _resetOverdueRepeatingTasks(db);

    final taskRows = await db.query('tasks', orderBy: 'due_date_time ASC');
    final subtaskRows = await db.query('subtasks');

    final subtasksByTaskId = <int, List<SubtaskItem>>{};
    for (final row in subtaskRows) {
      final subtask = SubtaskItem.fromMap(row);
      subtasksByTaskId.putIfAbsent(subtask.taskId, () => []).add(subtask);
    }

    return taskRows
        .map(
          (row) => TaskItem.fromMap(
            row,
            subtasksByTaskId[row['id'] as int? ?? -1] ?? const [],
          ),
        )
        .toList();
  }

  Future<TaskItem> saveTask(TaskItem task) async {
    final db = _database.instance;
    final id = task.id == null
        ? await db.insert('tasks', task.toMap()..remove('id'))
        : await _updateTaskCore(db, task);

    await db.delete('subtasks', where: 'task_id = ?', whereArgs: [id]);
    for (final subtask in task.subtasks) {
      await db.insert(
        'subtasks',
        subtask.copyWith(taskId: id).toMap()..remove('id'),
      );
    }

    return task.copyWith(id: id);
  }

  Future<int> _updateTaskCore(Database db, TaskItem task) async {
    await db.update(
      'tasks',
      task.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task.id!;
  }

  Future<void> deleteTask(int id) async {
    await _database.instance.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markTaskCompleted(TaskItem task) async {
    await _database.instance.update(
      'tasks',
      {
        'is_completed': 1,
        'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> toggleSubtask(SubtaskItem subtask, bool isCompleted) async {
    await _database.instance.update(
      'subtasks',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  Future<AppSettings> loadSettings() async {
    final rows = await _database.instance.query('settings', where: 'id = 1');
    if (rows.isEmpty) {
      final defaults = AppSettings.defaults();
      await _database.instance.insert('settings', defaults.toMap());
      return defaults;
    }
    return AppSettings.fromMap(rows.first);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _database.instance.insert(
      'settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _resetOverdueRepeatingTasks(Database db) async {
    final rows = await db.query(
      'tasks',
      where: 'repeat_mode != ?',
      whereArgs: [RepeatMode.none.name],
    );

    for (final row in rows) {
      final task = TaskItem.fromMap(row, const []);
      if (!_shouldResetTask(task)) {
        continue;
      }

      await db.update(
        'tasks',
        {
          'due_date_time': _nextDueDateFor(task).toIso8601String(),
          'is_completed': 0,
          'completed_at': null,
        },
        where: 'id = ?',
        whereArgs: [task.id],
      );

      await db.update(
        'subtasks',
        {'is_completed': 0},
        where: 'task_id = ?',
        whereArgs: [task.id],
      );
    }
  }

  bool _shouldResetTask(TaskItem task) {
    if (!task.isCompleted) {
      return false;
    }
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final limit = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    return _nextDueDateFor(task).isBefore(limit);
  }

  DateTime _nextDueDateFor(TaskItem task) {
    final due = task.dueDateTime;
    final now = DateTime.now();

    if (task.repeatMode == RepeatMode.daily) {
      var candidate = DateTime(
        due.year,
        due.month,
        due.day,
        due.hour,
        due.minute,
      ).add(const Duration(days: 1));

      while (candidate.isBefore(now) && !_isSameDay(candidate, now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return candidate;
    }

    if (task.repeatMode == RepeatMode.weekly) {
      final days = task.repeatDays.isEmpty ? [due.weekday] : task.repeatDays;
      for (var offset = 1; offset <= 7; offset++) {
        final candidate = due.add(Duration(days: offset));
        if (days.contains(candidate.weekday)) {
          return candidate;
        }
      }
    }

    return due;
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
