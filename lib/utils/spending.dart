import '../models/task.dart';
import 'date_labels.dart';

/// Built-in expense tags, in picker order. Stored by id on each expense.
const List<String> spendingTags = [
  'food', 'transport', 'home', 'bills', 'shopping',
  'health', 'fun', 'family', 'education', 'other',
];

const Map<String, String> spendingTagEmoji = {
  'food': '🍲',
  'transport': '🚕',
  'home': '🏠',
  'bills': '🧾',
  'shopping': '🛍️',
  'health': '💊',
  'fun': '🎉',
  'family': '👪',
  'education': '📚',
  'other': '•',
};

/// Totals for a spending list at a point in time.
class SpendingStats {
  final int todayMinor;
  final int weekMinor;
  final int monthMinor;
  final int lastMonthMinor;

  /// This month's total per tag, largest first.
  final List<MapEntry<String, int>> byTag;

  const SpendingStats({
    required this.todayMinor,
    required this.weekMinor,
    required this.monthMinor,
    required this.lastMonthMinor,
    required this.byTag,
  });

  /// Change against last month, e.g. 0.12 = 12% more. Null without history.
  double? get vsLastMonth =>
      lastMonthMinor <= 0 ? null : (monthMinor - lastMonthMinor) / lastMonthMinor;
}

SpendingStats spendingStats(List<Task> entries, DateTime now) {
  final today = startOfDay(now);
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  final monthStart = DateTime(now.year, now.month);
  final lastMonthStart = DateTime(now.year, now.month - 1);
  var t = 0, w = 0, m = 0, lm = 0;
  final tags = <String, int>{};
  for (final e in entries) {
    final a = e.amountMinor ?? 0;
    final d = e.createdAt;
    if (!d.isBefore(today) && d.isBefore(today.add(const Duration(days: 1)))) t += a;
    if (!d.isBefore(weekStart) && !d.isAfter(now.add(const Duration(days: 1)))) w += a;
    if (!d.isBefore(monthStart) && d.isBefore(DateTime(now.year, now.month + 1))) {
      m += a;
      final tag = e.tag ?? 'other';
      tags[tag] = (tags[tag] ?? 0) + a;
    }
    if (!d.isBefore(lastMonthStart) && d.isBefore(monthStart)) lm += a;
  }
  final byTag = tags.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return SpendingStats(todayMinor: t, weekMinor: w, monthMinor: m, lastMonthMinor: lm, byTag: byTag);
}

/// Expenses grouped by calendar day, newest day first; newest first inside.
List<(DateTime day, List<Task> entries, int totalMinor)> spendingByDay(List<Task> entries) {
  final map = <DateTime, List<Task>>{};
  for (final e in entries) {
    map.putIfAbsent(startOfDay(e.createdAt), () => []).add(e);
  }
  final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final d in days)
      (
        d,
        map[d]!..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        map[d]!.fold(0, (s, e) => s + (e.amountMinor ?? 0)),
      )
  ];
}

/// True if anything was logged on [day] in any of [lists].
bool loggedOn(Iterable<List<Task>> lists, DateTime day) =>
    lists.any((l) => l.any((e) => isSameDay(e.createdAt, day)));

/// Plain CSV (date, amount, tag, what, note) for spreadsheets.
String spendingCsv(List<Task> entries, String currency) {
  String q(String s) => '"${s.replaceAll('"', '""')}"';
  final rows = [
    'date,amount,currency,tag,what,note',
    for (final e in [...entries]..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
      [
        e.createdAt.toIso8601String().substring(0, 10),
        ((e.amountMinor ?? 0) / 100).toStringAsFixed(2),
        currency,
        e.tag ?? 'other',
        q(e.name),
        q(e.description.replaceAll('\n', ' ')),
      ].join(','),
  ];
  return rows.join('\n');
}

/// When the daily "log today's spending" reminders should fire over the next
/// [days] days: at [minutes] past midnight, skipping times already passed and
/// skipping today when something was logged today.
List<DateTime> spendingReminderTimes(DateTime now, int minutes, {required bool loggedToday, int days = 7}) {
  final today = DateTime(now.year, now.month, now.day);
  return [
    for (var d = 0; d < days; d++)
      if (!(d == 0 && loggedToday))
        DateTime(today.year, today.month, today.day + d, minutes ~/ 60, minutes % 60),
  ].where((t) => t.isAfter(now)).toList();
}

// ─── Overview: periods, filters, chart buckets ────────────────────────

enum SpendPeriod { week, month, year, custom }

/// A date range [start, end) at day precision.
class SpendRange {
  final DateTime start;
  final DateTime end;
  const SpendRange(this.start, this.end);

  /// Calendar days covered (DST-safe).
  int get days => DateTime.utc(end.year, end.month, end.day)
      .difference(DateTime.utc(start.year, start.month, start.day))
      .inDays;
  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);

  @override
  bool operator ==(Object other) => other is SpendRange && other.start == start && other.end == end;
  @override
  int get hashCode => Object.hash(start, end);
  @override
  String toString() => 'SpendRange($start – $end)';
}

/// The week (Monday first), month or year containing [anchor].
SpendRange periodRange(SpendPeriod p, DateTime anchor) {
  final d = startOfDay(anchor);
  return switch (p) {
    SpendPeriod.week => SpendRange(
        DateTime(d.year, d.month, d.day - (d.weekday - 1)),
        DateTime(d.year, d.month, d.day - (d.weekday - 1) + 7)),
    SpendPeriod.month || SpendPeriod.custom =>
      SpendRange(DateTime(d.year, d.month), DateTime(d.year, d.month + 1)),
    SpendPeriod.year => SpendRange(DateTime(d.year), DateTime(d.year + 1)),
  };
}

/// The period [delta] steps before/after [r]. Custom ranges shift by their length.
SpendRange shiftPeriod(SpendPeriod p, SpendRange r, int delta) {
  final s = r.start;
  return switch (p) {
    SpendPeriod.week => SpendRange(
        DateTime(s.year, s.month, s.day + 7 * delta), DateTime(s.year, s.month, s.day + 7 * delta + 7)),
    SpendPeriod.month => SpendRange(DateTime(s.year, s.month + delta), DateTime(s.year, s.month + delta + 1)),
    SpendPeriod.year => SpendRange(DateTime(s.year + delta), DateTime(s.year + delta + 1)),
    SpendPeriod.custom => SpendRange(
        DateTime(s.year, s.month, s.day + r.days * delta),
        DateTime(r.end.year, r.end.month, r.end.day + r.days * delta)),
  };
}

/// Expenses inside [range] (if given), with one of [tags] (if non-empty),
/// whose what-for or note contains [query] (case-insensitive).
List<Task> filterExpenses(List<Task> all, {SpendRange? range, Set<String> tags = const {}, String query = ''}) {
  final q = query.trim().toLowerCase();
  return [
    for (final e in all)
      if ((range == null || range.contains(e.createdAt)) &&
          (tags.isEmpty || tags.contains(e.tag ?? 'other')) &&
          (q.isEmpty || e.name.toLowerCase().contains(q) || e.description.toLowerCase().contains(q)))
        e
  ];
}

int totalMinor(Iterable<Task> entries) => entries.fold(0, (s, e) => s + (e.amountMinor ?? 0));

/// Chart buckets over [range]: one per day for ranges up to ~2 months,
/// otherwise one per month. Empty buckets are included (value 0).
List<(DateTime start, int totalMinor)> spendingBuckets(List<Task> entries, SpendRange range) {
  final daily = range.days <= 62;
  final buckets = <DateTime, int>{};
  var cursor = daily ? range.start : DateTime(range.start.year, range.start.month);
  while (cursor.isBefore(range.end)) {
    buckets[cursor] = 0;
    cursor = daily
        ? DateTime(cursor.year, cursor.month, cursor.day + 1)
        : DateTime(cursor.year, cursor.month + 1);
  }
  for (final e in entries) {
    if (!range.contains(e.createdAt)) continue;
    final d = e.createdAt;
    final key = daily ? DateTime(d.year, d.month, d.day) : DateTime(d.year, d.month);
    if (buckets.containsKey(key)) buckets[key] = buckets[key]! + (e.amountMinor ?? 0);
  }
  return [for (final e in buckets.entries) (e.key, e.value)];
}

/// Per-day totals (for the calendar heat map).
Map<DateTime, int> dailyTotals(Iterable<Task> entries) {
  final m = <DateTime, int>{};
  for (final e in entries) {
    final k = startOfDay(e.createdAt);
    m[k] = (m[k] ?? 0) + (e.amountMinor ?? 0);
  }
  return m;
}

/// Days of [range] that count toward a daily average: up to today for the
/// current period, the whole range for past ones; at least 1.
int elapsedDays(SpendRange range, DateTime now) {
  final end = range.end.isAfter(now) ? startOfDay(now).add(const Duration(days: 1)) : range.end;
  if (!end.isAfter(range.start)) return 1;
  final d = SpendRange(range.start, end).days;
  return d < 1 ? 1 : d;
}
