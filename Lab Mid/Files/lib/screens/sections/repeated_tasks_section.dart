import 'package:flutter/material.dart';

import '../../models/task_item.dart';
import '../../widgets/section_header.dart';
import '../../widgets/task_card.dart';

class RepeatedTasksSection extends StatelessWidget {
  const RepeatedTasksSection({
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
          title: 'Repeated Task',
          subtitle: 'Daily and weekly routines with automatic reset support.',
          icon: Icons.repeat_rounded,
        ),
        const SizedBox(height: 18),
        if (tasks.isEmpty) const _RepeatedEmptyState(),
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

class _RepeatedEmptyState extends StatelessWidget {
  const _RepeatedEmptyState();

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
        'Create daily or weekly tasks to keep your routines moving.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
