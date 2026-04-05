import 'package:flutter/material.dart';

import '../../models/task_item.dart';
import '../../widgets/section_header.dart';
import '../../widgets/task_card.dart';

class CompletedTasksSection extends StatelessWidget {
  const CompletedTasksSection({
    super.key,
    required this.tasks,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TaskItem> tasks;
  final ValueChanged<TaskItem> onEdit;
  final ValueChanged<TaskItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Completed Task',
          subtitle: 'Finished work stays organized here for review and export.',
          icon: Icons.verified_rounded,
        ),
        const SizedBox(height: 18),
        if (tasks.isEmpty) const _CompletedEmptyState(),
        ...tasks.map(
          (task) => TaskCard(
            task: task,
            onComplete: () {},
            onEdit: () => onEdit(task),
            onDelete: () => onDelete(task),
            onToggleSubtask: (_) {},
          ),
        ),
      ],
    );
  }
}

class _CompletedEmptyState extends StatelessWidget {
  const _CompletedEmptyState();

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
        'Completed tasks will appear here after you finish them.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
