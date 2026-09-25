/// Money helpers for the ledger. Amounts are stored as integer minor units
/// (cents / santim) so they can be added up without floating point error.
library;

/// Currency words that may surround a typed amount ("ETB 300", "300 birr").
final RegExp _currencyWords = RegExp(
  r'(etb|birr|br\.?|ብር)',
  caseSensitive: false,
);

/// Characters users type as thousands separators.
final RegExp _groupingChars = RegExp(r"[\s,'_   ]");

final RegExp _plainNumber = RegExp(r'^(\d*)(?:\.(\d{0,2}))?$');

/// Parse user input like "500", "1,200.50", "1 200", "ETB 300", "300 birr",
/// "-50" (negative -> null) into minor units (cents).
///
/// Returns null if the input is unparseable, negative, zero, has more than
/// two decimal places, or is absurdly large.
int? parseAmountMinor(String input) {
  var s = input.trim();
  if (s.isEmpty) return null;

  s = s.replaceAll(_currencyWords, '');
  // Any minus sign (hyphen, U+2212, en dash) means a negative amount.
  if (s.contains('-') || s.contains('−') || s.contains('–')) {
    return null;
  }
  s = s.replaceAll('+', '');
  s = s.replaceAll(_groupingChars, '');
  if (s.isEmpty) return null;

  final match = _plainNumber.firstMatch(s);
  if (match == null) return null;

  final whole = match.group(1) ?? '';
  final frac = match.group(2) ?? '';
  if (whole.isEmpty && frac.isEmpty) return null;
  // Keep well within 64-bit / JS-safe integer range.
  if (whole.length > 13) return null;

  final wholeValue = whole.isEmpty ? 0 : int.parse(whole);
  final fracValue = frac.isEmpty ? 0 : int.parse(frac.padRight(2, '0'));
  final minor = wholeValue * 100 + fracValue;
  return minor > 0 ? minor : null;
}

/// Format minor units: 320000 -> "3,200"; 120050 -> "1,200.50" (".00" is
/// dropped).
///
/// With [showPlus], positive values get a leading '+'. Negative values always
/// get a leading '−' (U+2212 MINUS SIGN). Zero never gets a sign.
String formatMinor(int minor, {bool showPlus = false}) {
  final negative = minor < 0;
  final abs = minor.abs();
  final whole = abs ~/ 100;
  final cents = abs % 100;

  final digits = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  if (cents != 0) {
    buf.write('.');
    buf.write(cents.toString().padLeft(2, '0'));
  }

  final sign = negative ? '−' : (showPlus && minor > 0 ? '+' : '');
  return '$sign$buf';
}

/// e.g. `formatMoney(320000, 'ETB')` -> "3,200 ETB".
///
/// An empty [currency] yields just the number.
String formatMoney(int minor, String currency, {bool showPlus = false}) {
  final number = formatMinor(minor, showPlus: showPlus);
  final code = currency.trim();
  return code.isEmpty ? number : '$number $code';
}
