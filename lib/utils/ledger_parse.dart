/// Parses legacy to-do names such as "Abebe – 500" into a person and an
/// amount, used when converting an existing category into a ledger.
library;

import 'money.dart';

/// Result of [parseLedgerName].
class ParsedLedgerName {
  /// The person's name, trimmed of separators. May be empty when the name is
  /// only an amount (e.g. "500").
  final String person;

  /// The amount in minor units, or null when no amount was found.
  final int? amountMinor;

  const ParsedLedgerName(this.person, this.amountMinor);

  @override
  bool operator ==(Object other) =>
      other is ParsedLedgerName &&
      other.person == person &&
      other.amountMinor == amountMinor;

  @override
  int get hashCode => Object.hash(person, amountMinor);

  @override
  String toString() => 'ParsedLedgerName($person, $amountMinor)';
}

// Number: comma-grouped ("1,200.50") or plain ("500", "12.5").
const String _number = r'(\d{1,3}(?:,\d{3})+(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)';
const String _currency = r'(?:etb|birr|br\.?|ብር)';
const String _sep = r'[\s–—\-:]';

/// `person sep [ETB] number [ETB|birr]` (person optional).
final RegExp _trailing = RegExp(
  '^(?:(.*?)$_sep+)?(?:$_currency\\s*)?$_number\\s*(?:$_currency)?\\s*\$',
  caseSensitive: false,
);

/// `[ETB] number [ETB|birr] sep person`
final RegExp _leading = RegExp(
  '^(?:$_currency\\s*)?$_number\\s*(?:$_currency)?$_sep+(.+)\$',
  caseSensitive: false,
);

final RegExp _edgeSeparators = RegExp(r'^[\s–—\-:,.]+|[\s–—\-:,]+$');

final RegExp _currencyOnly = RegExp('^$_currency\$', caseSensitive: false);

String _cleanPerson(String s) {
  final p = s.replaceAll(_edgeSeparators, '').trim();
  return _currencyOnly.hasMatch(p) ? '' : p;
}

/// Splits a task name into a person and an amount.
///
/// Handles "Abebe – 500", "Abebe - 500", "Abebe: 500", "500 Abebe",
/// "Abebe 1,200.50", "Abebe 500 birr", "Abebe ETB 500". En dash, em dash,
/// hyphen and colon are accepted as separators. A name without a trailing or
/// leading number (e.g. "Lunch with Abebe") yields the whole trimmed text as
/// the person and a null amount.
ParsedLedgerName parseLedgerName(String name) {
  final text = name.trim();

  final t = _trailing.firstMatch(text);
  if (t != null) {
    final amount = parseAmountMinor(t.group(2)!);
    if (amount != null) {
      return ParsedLedgerName(_cleanPerson(t.group(1) ?? ''), amount);
    }
  }

  final l = _leading.firstMatch(text);
  if (l != null) {
    final amount = parseAmountMinor(l.group(1)!);
    final person = _cleanPerson(l.group(2)!);
    if (amount != null && person.isNotEmpty) {
      return ParsedLedgerName(person, amount);
    }
  }

  return ParsedLedgerName(text, null);
}
