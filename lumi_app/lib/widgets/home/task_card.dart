import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onCheckTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onCheckTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: task.accentColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 45,
            child: Text(
              task.time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Checkbox
          GestureDetector(
            onTap: onCheckTap,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isCompleted ? task.accentColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: task.isCompleted
                      ? task.accentColor
                      : colors.borderMedium,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Center(
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class TasksList extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel)? onTaskCheckTap;

  const TasksList({
    super.key,
    required this.tasks,
    this.onTaskCheckTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: tasks
            .map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(
                    task: task,
                    onCheckTap: () => onTaskCheckTap?.call(task),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
