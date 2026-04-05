import 'package:flutter/material.dart';

import '../../models/task_item.dart';
import '../../widgets/section_header.dart';
import '../../widgets/task_card.dart';

class UpcomingTasksSection extends StatelessWidget {
  const UpcomingTasksSection({
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
          title: 'Upcoming Tasks',
          subtitle: 'Future work lined up so you can see what is next.',
          icon: Icons.upcoming_rounded,
        ),
        const SizedBox(height: 18),
        if (tasks.isEmpty)
          const _UpcomingEmptyState(),
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

class _UpcomingEmptyState extends StatelessWidget {
  const _UpcomingEmptyState();

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
      child: Text(
        'No upcoming tasks yet. Add something for tomorrow or later to see it here.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
