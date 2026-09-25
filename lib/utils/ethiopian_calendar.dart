/// Gregorian <-> Ethiopian calendar conversion (Amete Mihret era), using
/// Julian Day Numbers.
///
/// The Ethiopian year has 12 months of 30 days followed by Pagume, which has
/// 5 days, or 6 in a leap year (year % 4 == 3).
library;

/// JDN of Meskerem 1, year 1 (Amete Mihret).
const int _ethiopianEpochJdn = 1724221;

/// JDN of 1970-01-01 (Gregorian).
const int _unixEpochJdn = 2440588;

/// A date in the Ethiopian calendar. [month] is 1..13 (13 = Pagume).
class EthiopianDate {
  final int year, month, day;
  const EthiopianDate(this.year, this.month, this.day);

  @override
  bool operator ==(Object other) =>
      other is EthiopianDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'EthiopianDate($year-$month-$day)';
}

const List<String> ethiopianMonthsAm = [
  'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሣሥ', 'ጥር', 'የካቲት', 'መጋቢት', //
  'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜ',
];

const List<String> ethiopianMonthsLatin = [
  'Meskerem', 'Tikimt', 'Hidar', 'Tahsas', 'Tir', 'Yekatit', 'Megabit', //
  'Miyazya', 'Ginbot', 'Sene', 'Hamle', 'Nehase', 'Pagume',
];

/// Whether Ethiopian [year] is a leap year (Pagume has 6 days).
bool isEthiopianLeapYear(int year) => year % 4 == 3;

/// Number of days in the given Ethiopian month.
int ethiopianDaysInMonth(int year, int month) {
  if (month < 1 || month > 13) {
    throw ArgumentError.value(month, 'month', 'must be 1..13');
  }
  if (month < 13) return 30;
  return isEthiopianLeapYear(year) ? 6 : 5;
}

int _gregorianToJdn(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay +
    _unixEpochJdn;

int _ethiopianToJdn(int year, int month, int day) =>
    _ethiopianEpochJdn +
    365 * (year - 1) +
    year ~/ 4 +
    30 * (month - 1) +
    day -
    1;

/// Converts the calendar date of [gregorian] (its year/month/day fields; the
/// time of day is ignored) to the Ethiopian calendar.
EthiopianDate toEthiopian(DateTime gregorian) {
  final jdn = _gregorianToJdn(gregorian);
  // Offset from the day before year 1 begins, 365 days earlier, so that the
  // 4-year cycle starts with a common year and ends with the leap year.
  final offset = jdn - (_ethiopianEpochJdn - 365);
  final r = offset % 1461;
  final n = r % 365 + 365 * (r ~/ 1460);
  final year = 4 * (offset ~/ 1461) + r ~/ 365 - r ~/ 1460;
  final month = n ~/ 30 + 1;
  final day = n % 30 + 1;
  return EthiopianDate(year, month, day);
}

/// Converts an Ethiopian date to a local [DateTime] at midnight.
///
/// Throws [ArgumentError] if [month] or [day] is out of range.
DateTime fromEthiopian(int year, int month, int day) {
  final dim = ethiopianDaysInMonth(year, month);
  if (day < 1 || day > dim) {
    throw ArgumentError.value(day, 'day', 'must be 1..$dim');
  }
  final jdn = _ethiopianToJdn(year, month, day);
  final utc = DateTime.utc(1970, 1, 1).add(Duration(days: jdn - _unixEpochJdn));
  return DateTime(utc.year, utc.month, utc.day);
}

/// e.g. "Meskerem 15" or, with [withYear], "Meskerem 15, 2019".
/// With [amharic], Amharic month names are used ("መስከረም 15").
String formatEthiopian(
  DateTime d, {
  bool withYear = false,
  bool amharic = false,
}) {
  final e = toEthiopian(d);
  final names = amharic ? ethiopianMonthsAm : ethiopianMonthsLatin;
  final base = '${names[e.month - 1]} ${e.day}';
  return withYear ? '$base, ${e.year}' : base;
}
