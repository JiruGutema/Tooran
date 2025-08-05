import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('Due Date Validation Tests', () {
    test('should validate due date is not in the past', () {
      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 1));
      final futureDate = now.add(const Duration(days: 1));

      // Past date should be invalid
      expect(_isValidDueDate(pastDate, null), isFalse);
      
      // Future date should be valid
      expect(_isValidDueDate(futureDate, null), isTrue);
      
      // Today should be valid
      final today = DateTime(now.year, now.month, now.day);
      expect(_isValidDueDate(today, null), isTrue);
    });

    test('should validate due time is not in the past for today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Past time today should be invalid
      final pastTime = TimeOfDay(
        hour: now.hour > 0 ? now.hour - 1 : 23,
        minute: now.minute,
      );
      expect(_isValidDueDateTime(today, pastTime), isFalse);
      
      // Future time today should be valid
      final futureTime = TimeOfDay(
        hour: now.hour < 23 ? now.hour + 1 : 0,
        minute: now.minute,
      );
      expect(_isValidDueDateTime(today, futureTime), isTrue);
    });

    test('should handle edge cases for time validation', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Midnight should be valid for future dates
      const midnight = TimeOfDay(hour: 0, minute: 0);
      final tomorrow = today.add(const Duration(days: 1));
      expect(_isValidDueDateTime(tomorrow, midnight), isTrue);
      
      // 23:59 should be valid for future dates
      const lateNight = TimeOfDay(hour: 23, minute: 59);
      expect(_isValidDueDateTime(tomorrow, lateNight), isTrue);
    });

    test('should handle null values correctly', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      
      // Null date and time should be valid (no due date)
      expect(_isValidDueDateTime(null, null), isTrue);
      
      // Date without time should be valid
      expect(_isValidDueDateTime(futureDate, null), isTrue);
      
      // Time without date should default to today
      const time = TimeOfDay(hour: 23, minute: 59);
      expect(_isValidDueDateTime(null, time), isTrue);
    });

    test('should validate task creation with various due date combinations', () {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 1));
      final pastDate = now.subtract(const Duration(days: 1));
      
      // Valid combinations
      expect(() => Task(
        name: 'Valid Task 1',
        dueDate: futureDate,
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      ), returnsNormally);
      
      expect(() => Task(
        name: 'Valid Task 2',
        dueDate: futureDate,
      ), returnsNormally);
      
      expect(() => Task(
        name: 'Valid Task 3',
      ), returnsNormally);
      
      // Tasks with past dates can be created (validation happens at UI level)
      expect(() => Task(
        name: 'Past Task',
        dueDate: pastDate,
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      ), returnsNormally);
    });

    test('should handle timezone edge cases', () {
      // Test around daylight saving time transitions
      final dstStart = DateTime(2025, 3, 9, 2, 0); // Example DST start
      final dstEnd = DateTime(2025, 11, 2, 2, 0); // Example DST end
      
      expect(() => Task(
        name: 'DST Start Task',
        dueDate: dstStart,
        dueTime: const TimeOfDay(hour: 3, minute: 0),
      ), returnsNormally);
      
      expect(() => Task(
        name: 'DST End Task',
        dueDate: dstEnd,
        dueTime: const TimeOfDay(hour: 1, minute: 0),
      ), returnsNormally);
    });

    test('should handle leap year dates', () {
      final leapYearDate = DateTime(2024, 2, 29); // 2024 is a leap year
      final nonLeapYearDate = DateTime(2025, 2, 28); // 2025 is not a leap year
      
      expect(() => Task(
        name: 'Leap Year Task',
        dueDate: leapYearDate,
        dueTime: const TimeOfDay(hour: 12, minute: 0),
      ), returnsNormally);
      
      expect(() => Task(
        name: 'Non-Leap Year Task',
        dueDate: nonLeapYearDate,
        dueTime: const TimeOfDay(hour: 12, minute: 0),
      ), returnsNormally);
    });

    test('should handle year boundaries', () {
      final newYearEve = DateTime(2024, 12, 31, 23, 59);
      final newYearDay = DateTime(2025, 1, 1, 0, 1);
      
      expect(() => Task(
        name: 'New Year Eve Task',
        dueDate: newYearEve,
        dueTime: const TimeOfDay(hour: 23, minute: 59),
      ), returnsNormally);
      
      expect(() => Task(
        name: 'New Year Day Task',
        dueDate: newYearDay,
        dueTime: const TimeOfDay(hour: 0, minute: 1),
      ), returnsNormally);
    });

    test('should validate error messages for invalid dates', () {
      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 1));
      final today = DateTime(now.year, now.month, now.day);
      
      // Test validation error messages
      expect(_getValidationError(pastDate, null), contains('past'));
      expect(_getValidationError(today, TimeOfDay(hour: now.hour - 1, minute: 0)), contains('past'));
      expect(_getValidationError(now.add(const Duration(days: 1)), null), isNull);
    });

    test('should handle concurrent date validations', () async {
      final futures = List.generate(100, (index) async {
        final date = DateTime.now().add(Duration(days: index + 1)); // Always future dates
        final time = TimeOfDay(hour: index % 24, minute: index % 60);
        return _isValidDueDateTime(date, time);
      });
      
      final results = await Future.wait(futures);
      
      // All future dates should be valid
      expect(results.every((result) => result), isTrue);
    });
  });
}

// Helper functions that simulate the validation logic from the app
bool _isValidDueDate(DateTime? date, TimeOfDay? time) {
  if (date == null) return true;
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  return !date.isBefore(today);
}

bool _isValidDueDateTime(DateTime? date, TimeOfDay? time) {
  if (date == null && time == null) return true;
  
  final now = DateTime.now();
  final effectiveDate = date ?? DateTime(now.year, now.month, now.day);
  
  if (_isSameDay(effectiveDate, now) && time != null) {
    final dueDateTime = DateTime(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
      time.hour,
      time.minute,
    );
    return !dueDateTime.isBefore(now);
  }
  
  return _isValidDueDate(effectiveDate, time);
}

bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
         date1.month == date2.month &&
         date1.day == date2.day;
}

String? _getValidationError(DateTime? dueDate, TimeOfDay? dueTime) {
  if (dueDate == null && dueTime == null) {
    return null; // Both null is valid (no due date)
  }

  final now = DateTime.now();
  
  // If only time is set, assume today's date
  final effectiveDate = dueDate ?? now;
  
  // Check if date is in the past
  if (_isSameDay(effectiveDate, now)) {
    // If it's today, check the time
    if (dueTime != null) {
      final dueDateTime = DateTime(
        effectiveDate.year,
        effectiveDate.month,
        effectiveDate.day,
        dueTime.hour,
        dueTime.minute,
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