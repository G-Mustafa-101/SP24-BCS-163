import 'package:flutter/material.dart';

class TaskProgressBar extends StatelessWidget {
  const TaskProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
  });

  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: height,
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(
                    theme.colorScheme.secondary,
                    theme.colorScheme.primary,
                    progress,
                  ) ??
                  theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).round()}% complete',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
