/// Relative due-date classification for task rows. Pure Dart: the UI maps
/// [DueInfo] to localized strings.
library;

enum DueKind { overdue, today, tomorrow, thisWeek, later }

class DueInfo {
  final DueKind kind;

  /// Calendar days until due (negative if due on an earlier date; 0 for an
  /// item that is overdue earlier today).
  final int days;

  const DueInfo(this.kind, this.days);

  @override
  bool operator ==(Object other) =>
      other is DueInfo && other.kind == kind && other.days == days;

  @override
  int get hashCode => Object.hash(kind, days);

  @override
  String toString() => 'DueInfo($kind, $days)';
}

/// Classifies [due] relative to [now].
///
/// Overdue when [due] is before [now] (for all-day items the caller passes
/// the end of that day). Otherwise, by calendar date: same day -> today,
/// next day -> tomorrow, 2..6 days -> thisWeek, further -> later.
DueInfo dueInfo(DateTime due, DateTime now) {
  final days = _calendarDaysBetween(now, due);
  if (due.isBefore(now)) return DueInfo(DueKind.overdue, days);
  if (days == 0) return DueInfo(DueKind.today, days);
  if (days == 1) return DueInfo(DueKind.tomorrow, days);
  if (days <= 6) return DueInfo(DueKind.thisWeek, days);
  return DueInfo(DueKind.later, days);
}

/// Whole calendar days from [a]'s date to [b]'s date, immune to DST.
int _calendarDaysBetween(DateTime a, DateTime b) {
  final ua = DateTime.utc(a.year, a.month, a.day);
  final ub = DateTime.utc(b.year, b.month, b.day);
  return ub.difference(ua).inDays;
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Midnight at the start of [d]'s day (keeps UTC/local-ness).
DateTime startOfDay(DateTime d) => d.isUtc
    ? DateTime.utc(d.year, d.month, d.day)
    : DateTime(d.year, d.month, d.day);
