import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/models/task.dart';
import 'package:tooran/utils/spending.dart';

Task e(int birr, DateTime at, [String tag = 'food', String name = 'x']) =>
    Task(name: name, amountMinor: birr * 100, createdAt: at, tag: tag);

void main() {
  // Friday 25 Sep 2026, 10:00 (the week started Monday 21 Sep).
  final now = DateTime(2026, 9, 25, 10);

  test('totals for today, this week, this month and last month', () {
    final entries = [
      e(100, DateTime(2026, 9, 25, 8)), // today
      e(50, DateTime(2026, 9, 21, 12), 'transport'), // Monday, same week
      e(30, DateTime(2026, 9, 20, 12), 'transport'), // Sunday, last week
      e(200, DateTime(2026, 9, 2), 'home'), // this month
      e(400, DateTime(2026, 8, 15), 'home'), // last month
      e(999, DateTime(2026, 7, 1)), // older
    ];
    final st = spendingStats(entries, now);
    expect(st.todayMinor, 10000);
    expect(st.weekMinor, 15000);
    expect(st.monthMinor, 38000);
    expect(st.lastMonthMinor, 40000);
    expect(st.vsLastMonth, closeTo(-0.05, 0.0001));
    expect(st.byTag.map((x) => x.key), ['home', 'food', 'transport']);
    expect(st.byTag.first.value, 20000);
  });

  test('no history means no comparison', () {
    expect(spendingStats([e(10, now)], now).vsLastMonth, isNull);
  });

  test('groups by day, newest day and newest entry first', () {
    final a = e(1, DateTime(2026, 9, 24, 9));
    final b = e(2, DateTime(2026, 9, 25, 7));
    final c = e(3, DateTime(2026, 9, 25, 9));
    final days = spendingByDay([a, b, c]);
    expect(days.map((d) => d.$1), [DateTime(2026, 9, 25), DateTime(2026, 9, 24)]);
    expect(days.first.$2, [c, b]);
    expect(days.first.$3, 500);
  });

  test('CSV has a header, one row per expense, quoted text', () {
    final csv = spendingCsv([e(12, DateTime(2026, 9, 1), 'fun', 'Movie "night"')], 'ETB').split('\n');
    expect(csv.first, 'date,amount,currency,tag,what,note');
    expect(csv[1], '2026-09-01,12.00,ETB,fun,"Movie ""night""",""');
  });

  group('daily reminder times', () {
    test('today at 18:00 plus the next six days', () {
      final t = spendingReminderTimes(now, 18 * 60, loggedToday: false);
      expect(t.length, 7);
      expect(t.first, DateTime(2026, 9, 25, 18));
      expect(t.last, DateTime(2026, 10, 1, 18));
    });

    test('skips today once something was logged', () {
      final t = spendingReminderTimes(now, 18 * 60, loggedToday: true);
      expect(t.first, DateTime(2026, 9, 26, 18));
      expect(t.length, 6);
    });

    test('skips today after the time has passed', () {
      final late = DateTime(2026, 9, 25, 19);
      expect(spendingReminderTimes(late, 18 * 60, loggedToday: false).first, DateTime(2026, 9, 26, 18));
    });

    test('loggedOn checks every list', () {
      expect(loggedOn([[], [e(1, DateTime(2026, 9, 25, 1))]], now), isTrue);
      expect(loggedOn([[e(1, DateTime(2026, 9, 24))]], now), isFalse);
    });
  });

  group('overview', () {
    test('periods: Monday-first week, month, year, and stepping', () {
      final w = periodRange(SpendPeriod.week, now);
      expect(w, SpendRange(DateTime(2026, 9, 21), DateTime(2026, 9, 28)));
      expect(w.days, 7);
      expect(shiftPeriod(SpendPeriod.week, w, -1).start, DateTime(2026, 9, 14));
      final m = periodRange(SpendPeriod.month, now);
      expect(m, SpendRange(DateTime(2026, 9), DateTime(2026, 10)));
      expect(shiftPeriod(SpendPeriod.month, m, 4), SpendRange(DateTime(2027, 1), DateTime(2027, 2)));
      expect(periodRange(SpendPeriod.year, now).days, 365);
      final custom = SpendRange(DateTime(2026, 9, 1), DateTime(2026, 9, 11));
      expect(shiftPeriod(SpendPeriod.custom, custom, 1), SpendRange(DateTime(2026, 9, 11), DateTime(2026, 9, 21)));
    });

    test('filter by range, tags and search text', () {
      final all = [
        e(10, DateTime(2026, 9, 3), 'food', 'Lunch'),
        e(20, DateTime(2026, 9, 5), 'transport', 'Taxi'),
        Task(name: 'Books', amountMinor: 3000, createdAt: DateTime(2026, 8, 30), tag: 'education', description: 'for school'),
      ];
      final sep = periodRange(SpendPeriod.month, now);
      expect(filterExpenses(all, range: sep).length, 2);
      expect(filterExpenses(all, tags: {'transport'}).single.name, 'Taxi');
      expect(filterExpenses(all, query: 'SCHOOL').single.name, 'Books');
      expect(filterExpenses(all, range: sep, query: 'books'), isEmpty);
      expect(totalMinor(all), 6000);
    });

    test('buckets are daily for a month and monthly for a year, zeros included', () {
      final all = [e(10, DateTime(2026, 9, 3, 9)), e(5, DateTime(2026, 9, 3, 20)), e(7, DateTime(2026, 2, 1))];
      final month = spendingBuckets(all, periodRange(SpendPeriod.month, now));
      expect(month.length, 30);
      expect(month[2], (DateTime(2026, 9, 3), 1500));
      expect(month[0].$2, 0);
      final year = spendingBuckets(all, periodRange(SpendPeriod.year, now));
      expect(year.length, 12);
      expect(year[1], (DateTime(2026, 2), 700));
      expect(year[8], (DateTime(2026, 9), 1500));
    });

    test('daily totals and elapsed days for averages', () {
      final t = dailyTotals([e(1, DateTime(2026, 9, 3, 1)), e(2, DateTime(2026, 9, 3, 23))]);
      expect(t[DateTime(2026, 9, 3)], 300);
      expect(elapsedDays(periodRange(SpendPeriod.month, now), now), 25);
      expect(elapsedDays(periodRange(SpendPeriod.month, DateTime(2026, 8, 1)), now), 31);
    });
  });
}
