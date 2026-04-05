import 'package:flutter/material.dart';

import '../../models/task_item.dart';
import '../../widgets/section_header.dart';
import '../../widgets/task_card.dart';

class TodayTasksSection extends StatelessWidget {
  const TodayTasksSection({
    super.key,
    required this.tasks,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleSubtask,
  });

  final List<TaskItem> tasks;
  final ValueChanged<TaskItem> onComplete;
  final ValueChanged<TaskItem> onEdit;
  final ValueChanged<TaskItem> onDelete;
  final void Function(TaskItem task, int index) onToggleSubtask;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Today Task',
          subtitle: 'Priority work due today with quick progress visibility.',
          icon: Icons.wb_sunny_rounded,
        ),
        const SizedBox(height: 18),
        if (tasks.isEmpty)
          const _EmptyState(
            title: 'No tasks due today',
            message: 'Your schedule is clear. Add a task to start building momentum.',
          ),
        ...tasks.map(
          (task) => TaskCard(
            task: task,
            onComplete: () => onComplete(task),
            onEdit: () => onEdit(task),
            onDelete: () => onDelete(task),
            onToggleSubtask: (index) => onToggleSubtask(task, index),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 36, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
