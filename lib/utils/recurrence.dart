/// Recurring task scheduling.
library;

enum Recurrence { none, daily, weekly, monthly, yearly }

/// Parses a stored value; null or unknown values map to [Recurrence.none].
Recurrence recurrenceFromString(String? s) {
  if (s == null) return Recurrence.none;
  final key = s.trim().toLowerCase();
  for (final r in Recurrence.values) {
    if (r.name == key) return r;
  }
  return Recurrence.none;
}

/// 'daily', 'weekly', 'monthly', 'yearly', or 'none'.
String recurrenceToString(Recurrence r) => r.name;

int _daysInMonth(int year, int month) =>
    DateTime.utc(year, month + 1, 0).day; // day 0 = last day of prev month

DateTime _build(DateTime like, int year, int month, int day) => like.isUtc
    ? DateTime.utc(year, month, day, like.hour, like.minute, like.second,
        like.millisecond, like.microsecond)
    : DateTime(year, month, day, like.hour, like.minute, like.second,
        like.millisecond, like.microsecond);

/// Next occurrence strictly after [from], preserving the time of day (wall
/// clock, so DST changes don't shift it).
///
/// Monthly keeps the day of month, clamped to the month's length. Pass
/// [anchorDay] (the ORIGINAL day of month) so clamping doesn't drift:
/// Jan 31 -> Feb 28/29 -> Mar 31. Without it, `from.day` is used.
/// Yearly Feb 29 -> Feb 28 in non-leap years (and back to Feb 29 in leap
/// years when [anchorDay] is 29).
///
/// For [Recurrence.none], [from] is returned unchanged.
DateTime nextOccurrence(DateTime from, Recurrence r, {int? anchorDay}) {
  switch (r) {
    case Recurrence.none:
      return from;
    case Recurrence.daily:
      return _build(from, from.year, from.month, from.day + 1);
    case Recurrence.weekly:
      return _build(from, from.year, from.month, from.day + 7);
    case Recurrence.monthly:
      final total = from.month; // next month, 1-based -> +1
      final year = from.year + total ~/ 12;
      final month = total % 12 + 1;
      final wanted = anchorDay ?? from.day;
      final day = wanted.clamp(1, _daysInMonth(year, month));
      return _build(from, year, month, day);
    case Recurrence.yearly:
      final year = from.year + 1;
      final wanted = anchorDay ?? from.day;
      final day = wanted.clamp(1, _daysInMonth(year, from.month));
      return _build(from, year, from.month, day);
  }
}

/// Like [nextOccurrence], but if the result is not after [now] (an overdue
/// recurring task completed late), keeps advancing until it is.
///
/// [anchorDay] defaults to `due.day` so monthly/yearly clamping never drifts
/// while advancing. For [Recurrence.none], [due] is returned unchanged.
DateTime nextOccurrenceAfterNow(
  DateTime due,
  Recurrence r,
  DateTime now, {
  int? anchorDay,
}) {
  if (r == Recurrence.none) return due;
  final anchor = anchorDay ?? due.day;
  var next = nextOccurrence(due, r, anchorDay: anchor);
  while (!next.isAfter(now)) {
    next = nextOccurrence(next, r, anchorDay: anchor);
  }
  return next;
}
