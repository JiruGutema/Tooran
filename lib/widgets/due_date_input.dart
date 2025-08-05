import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DueDateInput extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final Function(DateTime?, TimeOfDay?) onChanged;
  final bool enabled;

  const DueDateInput({
    super.key,
    this.initialDate,
    this.initialTime,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<DueDateInput> createState() => _DueDateInputState();
}

class _DueDateInputState extends State<DueDateInput> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with clear button
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Due Date & Time',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (_selectedDate != null || _selectedTime != null)
              TextButton.icon(
                onPressed: widget.enabled ? _clearDateTime : null,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 12),

        // Date and Time selection row
        Row(
          children: [
            // Date picker button
            Expanded(
              flex: 3,
              child: _buildDateButton(context),
            ),
            const SizedBox(width: 12),
            // Time picker button
            Expanded(
              flex: 2,
              child: _buildTimeButton(context),
            ),
          ],
        ),

        // Validation error message
        if (_validationError != null) ...[
          const SizedBox(height: 8),
          Text(
            _validationError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],

        // Helper text
        if (_validationError == null) ...[
          const SizedBox(height: 8),
          Text(
            _getHelperText(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OutlinedButton.icon(
      onPressed: widget.enabled ? () => _selectDate(context) : null,
      icon: Icon(
        Icons.calendar_today,
        size: 18,
        color: _selectedDate != null 
            ? colorScheme.primary 
            : colorScheme.onSurfaceVariant,
      ),
      label: Text(
        _selectedDate != null 
            ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
            : 'Select Date',
        style: TextStyle(
          color: _selectedDate != null 
              ? colorScheme.onSurface 
              : colorScheme.onSurfaceVariant,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        side: BorderSide(
          color: _selectedDate != null 
              ? colorScheme.primary 
              : colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildTimeButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OutlinedButton.icon(
      onPressed: widget.enabled ? () => _selectTime(context) : null,
      icon: Icon(
        Icons.access_time,
        size: 18,
        color: _selectedTime != null 
            ? colorScheme.primary 
            : colorScheme.onSurfaceVariant,
      ),
      label: Text(
        _selectedTime != null 
            ? _selectedTime!.format(context)
            : 'Time',
        style: TextStyle(
          color: _selectedTime != null 
              ? colorScheme.onSurface 
              : colorScheme.onSurfaceVariant,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        side: BorderSide(
          color: _selectedTime != null 
              ? colorScheme.primary 
              : colorScheme.outline,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedDate ?? now;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      helpText: 'Select Due Date',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _validationError = null;
      });
      
      // If no time is set and date is today, default to current time + 1 hour
      if (_selectedTime == null && _isSameDay(picked, now)) {
        final suggestedTime = TimeOfDay.fromDateTime(
          now.add(const Duration(hours: 1))
        );
        setState(() {
          _selectedTime = suggestedTime;
        });
      }
      
      _validateAndNotify();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = _selectedTime ?? TimeOfDay.now();
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Select Due Time',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _validationError = null;
      });
      
      // If no date is set, default to today
      if (_selectedDate == null) {
        setState(() {
          _selectedDate = DateTime.now();
        });
      }
      
      _validateAndNotify();
    }
  }

  void _clearDateTime() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _validationError = null;
    });
    widget.onChanged(null, null);
  }

  void _validateAndNotify() {
    final error = _validateDateTime();
    setState(() {
      _validationError = error;
    });
    
    if (error == null) {
      widget.onChanged(_selectedDate, _selectedTime);
    }
  }

  String? _validateDateTime() {
    if (_selectedDate == null && _selectedTime == null) {
      return null; // Both null is valid (no due date)
    }

    final now = DateTime.now();
    
    // If only time is set, assume today's date
    final effectiveDate = _selectedDate ?? now;
    
    // Check if date is in the past
    if (_isSameDay(effectiveDate, now)) {
      // If it's today, check the time
      if (_selectedTime != null) {
        final dueDateTime = DateTime(
          effectiveDate.year,
          effectiveDate.month,
          effectiveDate.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
        
        if (dueDateTime.isBefore(now)) {
          return 'Due time cannot be in the past';
        }
      }
    } else if (effectiveDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'Due date cannot be in the past';
    }

    return null;
  }

  String _getHelperText() {
    if (_selectedDate == null && _selectedTime == null) {
      return 'Optional: Set a due date to receive reminders';
    }
    
    if (_selectedDate != null && _selectedTime == null) {
      return 'Add a time to receive precise reminders';
    }
    
    if (_selectedDate != null && _selectedTime != null) {
      final dueDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      
      final now = DateTime.now();
      final difference = dueDateTime.difference(now);
      
      if (difference.inDays > 0) {
        return 'Due in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
      } else if (difference.inHours > 0) {
        return 'Due in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
      } else if (difference.inMinutes > 0) {
        return 'Due in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'Due now';
      }
    }
    
    return 'Set both date and time for reminders';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}