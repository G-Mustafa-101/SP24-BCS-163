import 'subtask_item.dart';

enum RepeatMode { none, daily, weekly }

class TaskItem {
  const TaskItem({
    this.id,
    required this.title,
    required this.description,
    required this.dueDateTime,
    required this.repeatMode,
    required this.repeatDays,
    required this.isCompleted,
    required this.subtasks,
    this.completedAt,
  });

  final int? id;
  final String title;
  final String description;
  final DateTime dueDateTime;
  final RepeatMode repeatMode;
  final List<int> repeatDays;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<SubtaskItem> subtasks;

  double get progress {
    if (subtasks.isEmpty) {
      return isCompleted ? 1 : 0;
    }
    final completed = subtasks.where((item) => item.isCompleted).length;
    return completed / subtasks.length;
  }

  bool get isRepeating => repeatMode != RepeatMode.none;

  bool isDueToday(DateTime now) {
    return !isCompleted &&
        dueDateTime.year == now.year &&
        dueDateTime.month == now.month &&
        dueDateTime.day == now.day;
  }

  bool isUpcoming(DateTime now) {
    final startOfTomorrow = DateTime(now.year, now.month, now.day + 1);
    return !isCompleted && dueDateTime.isAfter(startOfTomorrow.subtract(const Duration(microseconds: 1)));
  }

  String get repeatSummary {
    switch (repeatMode) {
      case RepeatMode.none:
        return 'No repeat';
      case RepeatMode.daily:
        return 'Repeats daily';
      case RepeatMode.weekly:
        if (repeatDays.isEmpty) {
          return 'Repeats weekly';
        }
        const labels = {
          1: 'Mon',
          2: 'Tue',
          3: 'Wed',
          4: 'Thu',
          5: 'Fri',
          6: 'Sat',
          7: 'Sun',
        };
        return repeatDays.map((day) => labels[day] ?? '$day').join(', ');
    }
  }

  TaskItem copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDateTime,
    RepeatMode? repeatMode,
    List<int>? repeatDays,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    List<SubtaskItem>? subtasks,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      repeatMode: repeatMode ?? this.repeatMode,
      repeatDays: repeatDays ?? this.repeatDays,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date_time': dueDateTime.toIso8601String(),
      'repeat_mode': repeatMode.name,
      'repeat_days': repeatDays.join(','),
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, Object?> map, List<SubtaskItem> subtasks) {
    final repeatDaysText = (map['repeat_days'] as String? ?? '').trim();
    return TaskItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      dueDateTime: DateTime.parse(map['due_date_time'] as String),
      repeatMode: RepeatMode.values.firstWhere(
        (mode) => mode.name == map['repeat_mode'],
        orElse: () => RepeatMode.none,
      ),
      repeatDays: repeatDaysText.isEmpty
          ? const []
          : repeatDaysText.split(',').map(int.parse).toList(),
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.parse(map['completed_at'] as String),
      subtasks: subtasks,
    );
  }
}
