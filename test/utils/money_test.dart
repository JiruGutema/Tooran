import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/utils/money.dart';

void main() {
  group('parseAmountMinor', () {
    test('plain integers', () {
      expect(parseAmountMinor('500'), 50000);
      expect(parseAmountMinor('1'), 100);
      expect(parseAmountMinor('  42  '), 4200);
    });

    test('decimals', () {
      expect(parseAmountMinor('1200.50'), 120050);
      expect(parseAmountMinor('1200.5'), 120050);
      expect(parseAmountMinor('0.05'), 5);
      expect(parseAmountMinor('.5'), 50);
      expect(parseAmountMinor('12.'), 1200);
    });

    test('grouping separators', () {
      expect(parseAmountMinor('1,200.50'), 120050);
      expect(parseAmountMinor('1,200'), 120000);
      expect(parseAmountMinor('1 200'), 120000);
      expect(parseAmountMinor('1 200'), 120000);
      expect(parseAmountMinor('1,000,000'), 100000000);
    });

    test('currency words', () {
      expect(parseAmountMinor('ETB 300'), 30000);
      expect(parseAmountMinor('etb300'), 30000);
      expect(parseAmountMinor('300 ETB'), 30000);
      expect(parseAmountMinor('300 birr'), 30000);
      expect(parseAmountMinor('300 Birr'), 30000);
      expect(parseAmountMinor('300 br'), 30000);
      expect(parseAmountMinor('300 ብር'), 30000);
    });

    test('explicit plus is accepted', () {
      expect(parseAmountMinor('+50'), 5000);
    });

    test('negative returns null', () {
      expect(parseAmountMinor('-50'), isNull);
      expect(parseAmountMinor('−50'), isNull);
      expect(parseAmountMinor('ETB -50'), isNull);
    });

    test('zero returns null', () {
      expect(parseAmountMinor('0'), isNull);
      expect(parseAmountMinor('0.00'), isNull);
    });

    test('garbage returns null', () {
      expect(parseAmountMinor(''), isNull);
      expect(parseAmountMinor('   '), isNull);
      expect(parseAmountMinor('abc'), isNull);
      expect(parseAmountMinor('ETB'), isNull);
      expect(parseAmountMinor('12abc'), isNull);
      expect(parseAmountMinor('1.2.3'), isNull);
      expect(parseAmountMinor('.'), isNull);
    });

    test('more than two decimals returns null', () {
      expect(parseAmountMinor('1.005'), isNull);
    });

    test('absurdly large returns null', () {
      expect(parseAmountMinor('99999999999999999999'), isNull);
    });
  });

  group('formatMinor', () {
    test('whole amounts drop .00', () {
      expect(formatMinor(320000), '3,200');
      expect(formatMinor(50000), '500');
      expect(formatMinor(100), '1');
      expect(formatMinor(0), '0');
    });

    test('fractional amounts keep two decimals', () {
      expect(formatMinor(120050), '1,200.50');
      expect(formatMinor(5), '0.05');
      expect(formatMinor(123456789), '1,234,567.89');
    });

    test('grouping boundaries', () {
      expect(formatMinor(99900), '999');
      expect(formatMinor(100000), '1,000');
      expect(formatMinor(100000000), '1,000,000');
    });

    test('signs', () {
      expect(formatMinor(320000, showPlus: true), '+3,200');
      expect(formatMinor(-115000), '−1,150');
      expect(formatMinor(-115000, showPlus: true), '−1,150');
      expect(formatMinor(0, showPlus: true), '0');
    });
  });

  group('formatMoney', () {
    test('appends currency', () {
      expect(formatMoney(320000, 'ETB'), '3,200 ETB');
      expect(formatMoney(120050, 'USD'), '1,200.50 USD');
    });

    test('signs', () {
      expect(formatMoney(205000, 'ETB', showPlus: true), '+2,050 ETB');
      expect(formatMoney(-115000, 'ETB'), '−1,150 ETB');
    });

    test('empty currency', () {
      expect(formatMoney(50000, ''), '500');
    });

    test('round trip with parse', () {
      for (final v in [1, 99, 100, 12345, 120050, 320000, 987654321]) {
        expect(parseAmountMinor(formatMoney(v, 'ETB')), v);
      }
    });
  });
}
