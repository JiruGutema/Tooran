import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/utils/ledger_parse.dart';

void main() {
  void check(String input, String person, int? amount) {
    final r = parseLedgerName(input);
    expect(r.person, person, reason: 'person for "$input"');
    expect(r.amountMinor, amount, reason: 'amount for "$input"');
  }

  group('parseLedgerName trailing amount', () {
    test('en dash', () => check('Abebe – 500', 'Abebe', 50000));
    test('em dash', () => check('Abebe — 500', 'Abebe', 50000));
    test('hyphen', () => check('Abebe - 500', 'Abebe', 50000));
    test('hyphen no spaces', () => check('Abebe-500', 'Abebe', 50000));
    test('colon', () => check('Abebe: 500', 'Abebe', 50000));
    test('space only', () => check('Abebe 500', 'Abebe', 50000));
    test('grouped decimal', () => check('Abebe 1,200.50', 'Abebe', 120050));
    test('birr suffix', () => check('Abebe 500 birr', 'Abebe', 50000));
    test('ETB suffix', () => check('Abebe 500 ETB', 'Abebe', 50000));
    test('ETB prefix', () => check('Abebe ETB 500', 'Abebe', 50000));
    test('dash + ETB prefix', () => check('Abebe – ETB 500', 'Abebe', 50000));
    test('multi-word person',
        () => check('Kebede Alemu – 1,500', 'Kebede Alemu', 150000));
    test('Amharic person', () => check('አበበ – 300 ብር', 'አበበ', 30000));
    test('surrounding whitespace',
        () => check('  Abebe  –  500  ', 'Abebe', 50000));
    test('case-insensitive currency',
        () => check('Abebe 500 Birr', 'Abebe', 50000));
  });

  group('parseLedgerName leading amount', () {
    test('number then person', () => check('500 Abebe', 'Abebe', 50000));
    test('number, dash, person', () => check('500 – Abebe', 'Abebe', 50000));
    test('with currency', () => check('500 birr Abebe', 'Abebe', 50000));
    test('ETB prefix', () => check('ETB 500 Abebe', 'Abebe', 50000));
    test('grouped', () => check('1,200 Abebe', 'Abebe', 120000));
  });

  group('parseLedgerName no amount', () {
    test('plain text',
        () => check('Lunch with Abebe', 'Lunch with Abebe', null));
    test('trimmed', () => check('  Abebe  ', 'Abebe', null));
    test('number in middle',
        () => check('Abebe 500 lunch', 'Abebe 500 lunch', null));
    test('empty', () => check('', '', null));
    test('zero amount is not an amount',
        () => check('Abebe 0', 'Abebe 0', null));
    test('glued to word is not an amount',
        () => check('Room12', 'Room12', null));
  });

  group('parseLedgerName edge cases', () {
    test('amount only', () => check('500', '', 50000));
    test('amount only with currency', () => check('ETB 500', '', 50000));
    test('trailing number wins over leading',
        () => check('500 Abebe 200', '500 Abebe', 20000));
  });

  test('ParsedLedgerName equality', () {
    expect(
        parseLedgerName('Abebe – 500'), const ParsedLedgerName('Abebe', 50000));
  });
}
