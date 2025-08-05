import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class DueDateDisplay extends StatelessWidget {
  final Task task;
  final bool showTime;
  final bool compact;

  const DueDateDisplay({
    super.key,
    required this.task,
    this.showTime = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final dueDateTime = task.dueDateTime;
    if (dueDateTime == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverdue = task.isOverdue;
    final now = DateTime.now();

    // Determine colors based on overdue status
    Color textColor;
    Color backgroundColor;
    IconData icon;

    if (isOverdue) {
      textColor = colorScheme.error;
      backgroundColor = colorScheme.errorContainer;
      icon = Icons.warning;
    } else {
      final timeUntilDue = dueDateTime.difference(now);
      if (timeUntilDue.inHours <= 1) {
        // Due within 1 hour - urgent
        textColor = colorScheme.error;
        backgroundColor = colorScheme.errorContainer.withOpacity(0.5);
        icon = Icons.schedule;
      } else if (timeUntilDue.inDays == 0) {
        // Due today - warning
        textColor = Colors.orange.shade700;
        backgroundColor = Colors.orange.shade50;
        icon = Icons.today;
      } else {
        // Due later - normal
        textColor = colorScheme.onSurfaceVariant;
        backgroundColor = colorScheme.surfaceVariant.withOpacity(0.3);
        icon = Icons.schedule;
      }
    }

    if (compact) {
      return _buildCompactDisplay(
        context,
        dueDateTime,
        textColor,
        backgroundColor,
        icon,
        isOverdue,
      );
    } else {
      return _buildFullDisplay(
        context,
        dueDateTime,
        textColor,
        backgroundColor,
        icon,
        isOverdue,
      );
    }
  }

  Widget _buildCompactDisplay(
    BuildContext context,
    DateTime dueDateTime,
    Color textColor,
    Color backgroundColor,
    IconData icon,
    bool isOverdue,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _getRelativeTimeText(dueDateTime, isOverdue),
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullDisplay(
    BuildContext context,
    DateTime dueDateTime,
    Color textColor,
    Color backgroundColor,
    IconData icon,
    bool isOverdue,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and status
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: textColor,
              ),
              const SizedBox(width: 6),
              Text(
                isOverdue ? 'Overdue' : 'Due',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                _getRelativeTimeText(dueDateTime, isOverdue),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Date and time information
          Row(
            children: [
              // Date
              Text(
                _getDateText(dueDateTime),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showTime && task.dueTime != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 12,
                  color: textColor.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 8),
                Text(
                  task.dueTime!.format(context),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getRelativeTimeText(DateTime dueDateTime, bool isOverdue) {
    final now = DateTime.now();
    final difference = isOverdue 
        ? now.difference(dueDateTime)
        : dueDateTime.difference(now);

    if (isOverdue) {
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } else {
      if (difference.inDays > 7) {
        final weeks = (difference.inDays / 7).floor();
        return 'in ${weeks}w';
      } else if (difference.inDays > 0) {
        return 'in ${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return 'in ${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return 'in ${difference.inMinutes}m';
      } else {
        return 'now';
      }
    }
  }

  String _getDateText(DateTime dueDateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDate = DateTime(dueDateTime.year, dueDateTime.month, dueDateTime.day);

    if (dueDate == today) {
      return 'Today';
    } else if (dueDate == tomorrow) {
      return 'Tomorrow';
    } else if (dueDate.year == now.year) {
      return DateFormat('MMM dd').format(dueDateTime);
    } else {
      return DateFormat('MMM dd, yyyy').format(dueDateTime);
    }
  }
}

/// A specialized widget for showing due date in task lists
class TaskListDueDateDisplay extends StatelessWidget {
  final Task task;

  const TaskListDueDateDisplay({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return DueDateDisplay(
      task: task,
      showTime: true,
      compact: true,
    );
  }
}

/// A specialized widget for showing due date in task details
class TaskDetailDueDateDisplay extends StatelessWidget {
  final Task task;

  const TaskDetailDueDateDisplay({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return DueDateDisplay(
      task: task,
      showTime: true,
      compact: false,
    );
  }
}