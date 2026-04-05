import 'package:flutter/material.dart';

import '../models/task_item.dart';
import 'task_progress_bar.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleSubtask,
  });

  final TaskItem task;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<int> onToggleSubtask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.cardColor,
              theme.colorScheme.surface.withValues(alpha: 0.85),
            ],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.description.isEmpty
                            ? 'Focused task entry with no extra notes.'
                            : task.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'complete':
                        onComplete();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit Task')),
                    PopupMenuItem(value: 'complete', child: Text('Mark Completed')),
                    PopupMenuItem(value: 'delete', child: Text('Delete Task')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.schedule_rounded,
                  label: _formatDueDate(task.dueDateTime),
                ),
                _InfoChip(
                  icon: task.isRepeating ? Icons.repeat_rounded : Icons.event_note_rounded,
                  label: task.repeatSummary,
                ),
                _InfoChip(
                  icon: task.isCompleted
                      ? Icons.verified_rounded
                      : Icons.pending_actions_rounded,
                  label: task.isCompleted ? 'Completed' : 'Active',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TaskProgressBar(progress: task.progress),
            if (task.subtasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...List.generate(task.subtasks.length, (index) {
                final subtask = task.subtasks[index];
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: subtask.isCompleted,
                  title: Text(subtask.title),
                  onChanged: task.isCompleted ? null : (_) => onToggleSubtask(index),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDueDate(DateTime dateTime) {
    final month = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][dateTime.month];

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day} $month, ${hour == 0 ? 12 : hour}:$minute $suffix';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
