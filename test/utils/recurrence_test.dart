import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/utils/recurrence.dart';

void main() {
  group('string conversion', () {
    test('round trip', () {
      for (final r in Recurrence.values) {
        expect(recurrenceFromString(recurrenceToString(r)), r);
      }
    });
    test('values', () {
      expect(recurrenceToString(Recurrence.none), 'none');
      expect(recurrenceToString(Recurrence.daily), 'daily');
      expect(recurrenceToString(Recurrence.weekly), 'weekly');
      expect(recurrenceToString(Recurrence.monthly), 'monthly');
      expect(recurrenceToString(Recurrence.yearly), 'yearly');
    });
    test('null / unknown -> none', () {
      expect(recurrenceFromString(null), Recurrence.none);
      expect(recurrenceFromString(''), Recurrence.none);
      expect(recurrenceFromString('fortnightly'), Recurrence.none);
    });
    test('lenient casing', () {
      expect(recurrenceFromString('Weekly'), Recurrence.weekly);
      expect(recurrenceFromString(' MONTHLY '), Recurrence.monthly);
    });
  });

  group('nextOccurrence', () {
    test('none returns input', () {
      final d = DateTime(2026, 3, 4, 9, 30);
      expect(nextOccurrence(d, Recurrence.none), d);
    });

    test('daily preserves time', () {
      expect(nextOccurrence(DateTime(2026, 3, 4, 9, 30), Recurrence.daily),
          DateTime(2026, 3, 5, 9, 30));
      expect(nextOccurrence(DateTime(2026, 12, 31, 23, 59), Recurrence.daily),
          DateTime(2027, 1, 1, 23, 59));
    });

    test('weekly', () {
      expect(nextOccurrence(DateTime(2026, 9, 28, 8), Recurrence.weekly),
          DateTime(2026, 10, 5, 8));
      expect(nextOccurrence(DateTime(2026, 12, 28), Recurrence.weekly),
          DateTime(2027, 1, 4));
    });

    test('monthly simple', () {
      expect(nextOccurrence(DateTime(2026, 1, 1, 10), Recurrence.monthly),
          DateTime(2026, 2, 1, 10));
      expect(nextOccurrence(DateTime(2026, 12, 15), Recurrence.monthly),
          DateTime(2027, 1, 15));
    });

    test('monthly clamps and restores via anchorDay', () {
      final jan31 = DateTime(2026, 1, 31, 7);
      final feb = nextOccurrence(jan31, Recurrence.monthly, anchorDay: 31);
      expect(feb, DateTime(2026, 2, 28, 7));
      final mar = nextOccurrence(feb, Recurrence.monthly, anchorDay: 31);
      expect(mar, DateTime(2026, 3, 31, 7));
      final apr = nextOccurrence(mar, Recurrence.monthly, anchorDay: 31);
      expect(apr, DateTime(2026, 4, 30, 7));
    });

    test('monthly leap-year February', () {
      expect(nextOccurrence(DateTime(2028, 1, 31), Recurrence.monthly),
          DateTime(2028, 2, 29));
    });

    test('monthly without anchor drifts from clamped day', () {
      expect(nextOccurrence(DateTime(2026, 2, 28), Recurrence.monthly),
          DateTime(2026, 3, 28));
    });

    test('yearly', () {
      expect(nextOccurrence(DateTime(2026, 5, 10, 12), Recurrence.yearly),
          DateTime(2027, 5, 10, 12));
    });

    test('yearly Feb 29', () {
      final leap = DateTime(2028, 2, 29);
      final y1 = nextOccurrence(leap, Recurrence.yearly);
      expect(y1, DateTime(2029, 2, 28));
      final y2 = nextOccurrence(DateTime(2031, 2, 28), Recurrence.yearly,
          anchorDay: 29);
      expect(y2, DateTime(2032, 2, 29));
    });

    test('result is strictly after from for all kinds', () {
      final from = DateTime(2026, 9, 25, 14, 5);
      for (final r in Recurrence.values.where((r) => r != Recurrence.none)) {
        expect(nextOccurrence(from, r).isAfter(from), isTrue, reason: '$r');
      }
    });

    test('preserves UTC-ness', () {
      final n = nextOccurrence(DateTime.utc(2026, 3, 28, 22), Recurrence.daily);
      expect(n.isUtc, isTrue);
      expect(n, DateTime.utc(2026, 3, 29, 22));
    });

    test('preserves seconds and milliseconds', () {
      expect(nextOccurrence(DateTime(2026, 1, 1, 1, 2, 3, 4), Recurrence.daily),
          DateTime(2026, 1, 2, 1, 2, 3, 4));
    });
  });

  group('nextOccurrenceAfterNow', () {
    test('future due behaves like nextOccurrence', () {
      final now = DateTime(2026, 9, 25, 12);
      final due = DateTime(2026, 9, 26, 9);
      expect(nextOccurrenceAfterNow(due, Recurrence.daily, now),
          DateTime(2026, 9, 27, 9));
    });

    test('overdue daily advances past now', () {
      final now = DateTime(2026, 9, 25, 12);
      final due = DateTime(2026, 9, 20, 9);
      expect(nextOccurrenceAfterNow(due, Recurrence.daily, now),
          DateTime(2026, 9, 26, 9));
    });

    test('overdue daily same day later time', () {
      final now = DateTime(2026, 9, 25, 8);
      final due = DateTime(2026, 9, 20, 9);
      expect(nextOccurrenceAfterNow(due, Recurrence.daily, now),
          DateTime(2026, 9, 25, 9));
    });

    test('equal to now is not after now', () {
      final now = DateTime(2026, 9, 25, 9);
      final due = DateTime(2026, 9, 24, 9);
      expect(nextOccurrenceAfterNow(due, Recurrence.daily, now),
          DateTime(2026, 9, 26, 9));
    });

    test('overdue weekly keeps weekday', () {
      final due = DateTime(2026, 9, 7, 18); // Monday
      final now = DateTime(2026, 9, 25, 12); // Friday
      final n = nextOccurrenceAfterNow(due, Recurrence.weekly, now);
      expect(n, DateTime(2026, 9, 28, 18));
      expect(n.weekday, DateTime.monday);
    });

    test('overdue monthly keeps anchor day through short months', () {
      final due = DateTime(2026, 1, 31);
      final now = DateTime(2026, 4, 2);
      expect(nextOccurrenceAfterNow(due, Recurrence.monthly, now),
          DateTime(2026, 4, 30));
      expect(
          nextOccurrenceAfterNow(
              due, Recurrence.monthly, DateTime(2026, 4, 30, 1)),
          DateTime(2026, 5, 31));
    });

    test('explicit anchorDay', () {
      final due = DateTime(2026, 2, 28);
      final now = DateTime(2026, 3, 1);
      expect(
          nextOccurrenceAfterNow(due, Recurrence.monthly, now, anchorDay: 31),
          DateTime(2026, 3, 31));
    });

    test('overdue yearly Feb 29 returns to Feb 29 in a leap year', () {
      final due = DateTime(2024, 2, 29);
      expect(
          nextOccurrenceAfterNow(due, Recurrence.yearly, DateTime(2026, 9, 25)),
          DateTime(2027, 2, 28));
      expect(
          nextOccurrenceAfterNow(due, Recurrence.yearly, DateTime(2027, 3, 1)),
          DateTime(2028, 2, 29));
    });

    test('none returns due', () {
      final due = DateTime(2020, 1, 1);
      expect(nextOccurrenceAfterNow(due, Recurrence.none, DateTime(2026)), due);
    });

    test('long-overdue daily terminates', () {
      final n = nextOccurrenceAfterNow(
          DateTime(2000, 1, 1, 6), Recurrence.daily, DateTime(2026, 9, 25, 7));
      expect(n, DateTime(2026, 9, 26, 6));
    });
  });
}
