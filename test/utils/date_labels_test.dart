import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/utils/date_labels.dart';

void main() {
  final now = DateTime(2026, 9, 25, 14, 0); // Friday afternoon

  group('dueInfo', () {
    test('overdue earlier today', () {
      expect(dueInfo(DateTime(2026, 9, 25, 9), now),
          const DueInfo(DueKind.overdue, 0));
    });

    test('overdue yesterday and last week', () {
      expect(dueInfo(DateTime(2026, 9, 24, 23, 59), now),
          const DueInfo(DueKind.overdue, -1));
      expect(dueInfo(DateTime(2026, 9, 18), now),
          const DueInfo(DueKind.overdue, -7));
    });

    test('later today', () {
      expect(dueInfo(DateTime(2026, 9, 25, 18), now),
          const DueInfo(DueKind.today, 0));
    });

    test('exactly now is today, not overdue', () {
      expect(dueInfo(now, now), const DueInfo(DueKind.today, 0));
    });

    test('all-day today (end of day)', () {
      expect(dueInfo(DateTime(2026, 9, 25, 23, 59, 59), now),
          const DueInfo(DueKind.today, 0));
    });

    test('tomorrow, even early morning', () {
      expect(dueInfo(DateTime(2026, 9, 26, 0, 1), now),
          const DueInfo(DueKind.tomorrow, 1));
      expect(dueInfo(DateTime(2026, 9, 26, 23), now),
          const DueInfo(DueKind.tomorrow, 1));
    });

    test('this week: 2..6 days', () {
      expect(dueInfo(DateTime(2026, 9, 27), now),
          const DueInfo(DueKind.thisWeek, 2));
      expect(dueInfo(DateTime(2026, 10, 1, 23), now),
          const DueInfo(DueKind.thisWeek, 6));
    });

    test('later: 7+ days', () {
      expect(
          dueInfo(DateTime(2026, 10, 2), now), const DueInfo(DueKind.later, 7));
      expect(dueInfo(DateTime(2027, 9, 25), now),
          const DueInfo(DueKind.later, 365));
    });

    test('crosses month and year boundaries', () {
      final nye = DateTime(2026, 12, 31, 20);
      expect(dueInfo(DateTime(2027, 1, 1, 8), nye),
          const DueInfo(DueKind.tomorrow, 1));
      expect(dueInfo(DateTime(2026, 12, 30, 8), nye),
          const DueInfo(DueKind.overdue, -1));
    });

    test('counts calendar days across DST-like gaps', () {
      // Calendar-day arithmetic must not depend on elapsed hours.
      final a = DateTime(2026, 3, 28, 23);
      expect(dueInfo(DateTime(2026, 3, 30, 0, 30), a).days, 2);
    });
  });

  group('isSameDay', () {
    test('same date different times', () {
      expect(isSameDay(DateTime(2026, 9, 25, 0), DateTime(2026, 9, 25, 23, 59)),
          isTrue);
    });
    test('different dates', () {
      expect(isSameDay(DateTime(2026, 9, 25), DateTime(2026, 9, 26)), isFalse);
      expect(isSameDay(DateTime(2026, 9, 25), DateTime(2025, 9, 25)), isFalse);
      expect(isSameDay(DateTime(2026, 9, 25), DateTime(2026, 8, 25)), isFalse);
    });
  });

  group('startOfDay', () {
    test('local', () {
      final s = startOfDay(DateTime(2026, 9, 25, 14, 30, 5, 7));
      expect(s, DateTime(2026, 9, 25));
      expect(s.isUtc, isFalse);
    });
    test('utc', () {
      final s = startOfDay(DateTime.utc(2026, 9, 25, 14, 30));
      expect(s, DateTime.utc(2026, 9, 25));
      expect(s.isUtc, isTrue);
    });
  });
}
