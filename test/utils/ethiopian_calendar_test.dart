import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/utils/ethiopian_calendar.dart';

void main() {
  group('toEthiopian anchors', () {
    test('Enkutatash dates', () {
      expect(
          toEthiopian(DateTime(2023, 9, 12)), const EthiopianDate(2016, 1, 1));
      expect(
          toEthiopian(DateTime(2024, 9, 11)), const EthiopianDate(2017, 1, 1));
      expect(
          toEthiopian(DateTime(2025, 9, 11)), const EthiopianDate(2018, 1, 1));
      expect(
          toEthiopian(DateTime(2026, 9, 11)), const EthiopianDate(2019, 1, 1));
      // 2019 E.C. is a leap year, so 2020 E.C. starts on Sept 12.
      expect(
          toEthiopian(DateTime(2027, 9, 12)), const EthiopianDate(2020, 1, 1));
      expect(
          toEthiopian(DateTime(2028, 9, 11)), const EthiopianDate(2021, 1, 1));
    });

    test('Genna (Ethiopian Christmas)', () {
      // Year after the leap year 2015 E.C.: Tahsas 28.
      expect(
          toEthiopian(DateTime(2024, 1, 7)), const EthiopianDate(2016, 4, 28));
      // Other years: Tahsas 29.
      expect(
          toEthiopian(DateTime(2025, 1, 7)), const EthiopianDate(2017, 4, 29));
      expect(
          toEthiopian(DateTime(2026, 1, 7)), const EthiopianDate(2018, 4, 29));
    });

    test('time of day is ignored', () {
      expect(toEthiopian(DateTime(2025, 9, 11, 23, 59)),
          const EthiopianDate(2018, 1, 1));
      expect(toEthiopian(DateTime.utc(2025, 9, 11, 0, 0)),
          const EthiopianDate(2018, 1, 1));
    });

    test('today-ish', () {
      // 2026-09-25 = Meskerem 15, 2019.
      expect(
          toEthiopian(DateTime(2026, 9, 25)), const EthiopianDate(2019, 1, 15));
    });
  });

  group('Pagume', () {
    test('2015 E.C. is a leap year with 6 Pagume days ending 2023-09-11', () {
      expect(isEthiopianLeapYear(2015), isTrue);
      expect(ethiopianDaysInMonth(2015, 13), 6);
      expect(
          toEthiopian(DateTime(2023, 9, 6)), const EthiopianDate(2015, 13, 1));
      expect(
          toEthiopian(DateTime(2023, 9, 11)), const EthiopianDate(2015, 13, 6));
      expect(fromEthiopian(2015, 13, 6), DateTime(2023, 9, 11));
    });

    test('non-leap years have 5 Pagume days', () {
      expect(isEthiopianLeapYear(2016), isFalse);
      expect(ethiopianDaysInMonth(2016, 13), 5);
      expect(
          toEthiopian(DateTime(2024, 9, 10)), const EthiopianDate(2016, 13, 5));
      expect(() => fromEthiopian(2016, 13, 6), throwsArgumentError);
    });

    test('2019 E.C. is a leap year', () {
      expect(isEthiopianLeapYear(2019), isTrue);
      expect(
          toEthiopian(DateTime(2027, 9, 11)), const EthiopianDate(2019, 13, 6));
      expect(
          toEthiopian(DateTime(2027, 9, 12)), const EthiopianDate(2020, 1, 1));
    });
  });

  group('fromEthiopian', () {
    test('anchors', () {
      expect(fromEthiopian(2016, 1, 1), DateTime(2023, 9, 12));
      expect(fromEthiopian(2019, 1, 1), DateTime(2026, 9, 11));
      expect(fromEthiopian(2016, 4, 28), DateTime(2024, 1, 7));
    });

    test('invalid input throws', () {
      expect(() => fromEthiopian(2018, 0, 1), throwsArgumentError);
      expect(() => fromEthiopian(2018, 14, 1), throwsArgumentError);
      expect(() => fromEthiopian(2018, 1, 31), throwsArgumentError);
      expect(() => fromEthiopian(2018, 1, 0), throwsArgumentError);
    });

    test('returns local midnight', () {
      final d = fromEthiopian(2018, 5, 10);
      expect(d.isUtc, isFalse);
      expect([d.hour, d.minute, d.second], [0, 0, 0]);
    });
  });

  test('round trip every day 2020-2030', () {
    var d = DateTime(2020, 1, 1);
    EthiopianDate? prev;
    var count = 0;
    while (d.year <= 2030) {
      final e = toEthiopian(d);
      expect(fromEthiopian(e.year, e.month, e.day), d, reason: '$d -> $e');
      expect(e.day, inInclusiveRange(1, ethiopianDaysInMonth(e.year, e.month)));
      // Consecutive days advance by exactly one Ethiopian day.
      if (prev != null) {
        final expected = prev.day < ethiopianDaysInMonth(prev.year, prev.month)
            ? EthiopianDate(prev.year, prev.month, prev.day + 1)
            : prev.month < 13
                ? EthiopianDate(prev.year, prev.month + 1, 1)
                : EthiopianDate(prev.year + 1, 1, 1);
        expect(e, expected, reason: 'after $prev on $d');
      }
      prev = e;
      d = DateTime(d.year, d.month, d.day + 1);
      count++;
    }
    expect(count, 4018);
  });

  group('formatEthiopian', () {
    final d = DateTime(2026, 9, 25);
    test('latin', () {
      expect(formatEthiopian(d), 'Meskerem 15');
      expect(formatEthiopian(d, withYear: true), 'Meskerem 15, 2019');
    });
    test('amharic', () {
      expect(formatEthiopian(d, amharic: true), 'መስከረም 15');
      expect(
          formatEthiopian(d, amharic: true, withYear: true), 'መስከረም 15, 2019');
    });
    test('Pagume', () {
      expect(formatEthiopian(DateTime(2023, 9, 11)), 'Pagume 6');
      expect(formatEthiopian(DateTime(2023, 9, 11), amharic: true), 'ጳጉሜ 6');
    });
    test('month name lists', () {
      expect(ethiopianMonthsAm, hasLength(13));
      expect(ethiopianMonthsLatin, hasLength(13));
    });
  });
}
