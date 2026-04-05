import 'package:flutter/material.dart' hide RepeatMode;

import '../models/subtask_item.dart';
import '../models/task_item.dart';

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({
    super.key,
    this.task,
  });

  final TaskItem? task;

  static Future<TaskItem?> show(BuildContext context, {TaskItem? task}) {
    return showModalBottomSheet<TaskItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskEditorSheet(task: task),
    );
  }

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final List<TextEditingController> _subtaskControllers;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late RepeatMode _repeatMode;
  late Set<int> _repeatDays;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    final initialDueDateTime =
        task?.dueDateTime ?? DateTime.now().add(const Duration(hours: 2));
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _subtaskControllers = (task?.subtasks ?? const [])
        .map((item) => TextEditingController(text: item.title))
        .toList();
    _dueDate = initialDueDateTime;
    _dueTime = TimeOfDay.fromDateTime(initialDueDateTime);
    _repeatMode = task?.repeatMode ?? RepeatMode.none;
    _repeatDays = {...?task?.repeatDays};
    if (_subtaskControllers.isEmpty) {
      _subtaskControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                widget.task == null ? 'Create a new task' : 'Update your task',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task title'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(
                        '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule_rounded),
                      label: Text(_dueTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Repeat settings',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              SegmentedButton<RepeatMode>(
                segments: const [
                  ButtonSegment(value: RepeatMode.none, label: Text('None')),
                  ButtonSegment(value: RepeatMode.daily, label: Text('Daily')),
                  ButtonSegment(value: RepeatMode.weekly, label: Text('Weekly')),
                ],
                selected: {_repeatMode},
                onSelectionChanged: (value) {
                  setState(() {
                    _repeatMode = value.first;
                  });
                },
              ),
              if (_repeatMode == RepeatMode.weekly) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final weekday = index + 1;
                    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final isSelected = _repeatDays.contains(weekday);
                    return FilterChip(
                      label: Text(labels[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _repeatDays.add(weekday);
                          } else {
                            _repeatDays.remove(weekday);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Subtasks for progress tracking',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...List.generate(_subtaskControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _subtaskControllers[index],
                          decoration: InputDecoration(labelText: 'Subtask ${index + 1}'),
                        ),
                      ),
                      IconButton(
                        onPressed: _subtaskControllers.length == 1
                            ? null
                            : () => setState(() {
                                  final controller = _subtaskControllers.removeAt(index);
                                  controller.dispose();
                                }),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () => setState(() {
                  _subtaskControllers.add(TextEditingController());
                }),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add subtask'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(widget.task == null ? 'Save task' : 'Update task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selected != null) {
      setState(() {
        _dueDate = selected;
      });
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (selected != null) {
      setState(() {
        _dueTime = selected;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existing = widget.task;
    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    final subtasks = <SubtaskItem>[];
    for (var index = 0; index < _subtaskControllers.length; index++) {
      final title = _subtaskControllers[index].text.trim();
      if (title.isEmpty) {
        continue;
      }

      final previous = index < (existing?.subtasks.length ?? 0)
          ? existing!.subtasks[index]
          : null;

      subtasks.add(
        SubtaskItem(
          id: previous?.id,
          taskId: existing?.id ?? 0,
          title: title,
          isCompleted: previous?.isCompleted ?? false,
        ),
      );
    }

    Navigator.of(context).pop(
      TaskItem(
        id: existing?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDateTime: dueDateTime,
        repeatMode: _repeatMode,
        repeatDays: _repeatMode == RepeatMode.weekly
            ? (_repeatDays.toList()..sort())
            : const [],
        isCompleted: existing?.isCompleted ?? false,
        completedAt: existing?.completedAt,
        subtasks: subtasks,
      ),
    );
  }
}
