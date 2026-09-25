import '../models/category.dart';
import '../models/task.dart';
import '../providers/categories_provider.dart' show ledgerGroups;
import 'money.dart';
import 'rich_text.dart';

/// Plain-text rendering of a task for sharing (checklists become ☐ / ☑).
String taskToShareText(Task t, {Category? category}) {
  final b = StringBuffer();
  final done = t.isCompleted ? '☑' : '☐';
  if (category != null && category.isLedger && t.isLedgerEntry) {
    b.writeln('$done ${t.person ?? t.name} — ${formatMoney(t.remainingMinor, category.currency)}');
  } else if (category != null && category.tracksMoney && t.amountMinor != null) {
    b.writeln('$done ${t.name} — ${formatMoney(t.amountMinor!, category.currency)}');
  } else {
    b.writeln('$done ${t.name}');
  }
  final body = describeForShare(t.description);
  if (body.isNotEmpty) {
    b.writeln();
    b.writeln(body);
  }
  return b.toString().trimRight();
}

/// A whole category as a list, open items first.
String categoryToShareText(Category c) {
  final b = StringBuffer();
  b.writeln(c.emoji == null ? c.name : '${c.emoji} ${c.name}');
  if (c.isLedger && c.outstandingMinor > 0) {
    b.writeln(formatMoney(c.outstandingMinor, c.currency));
  } else if (c.kind == CategoryKind.savings) {
    b.writeln(c.targetMinor == null
        ? formatMoney(c.savedMinor, c.currency)
        : '${formatMoney(c.savedMinor, c.currency)} / ${formatMoney(c.targetMinor!, c.currency)}');
  } else if (c.tracksMoney && c.openAmountMinor > 0) {
    b.writeln(formatMoney(c.openAmountMinor, c.currency));
  }
  b.writeln();
  if (c.isLedger) {
    for (final g in ledgerGroups(c)) {
      b.writeln('${g.person}: ${formatMoney(g.netMinor, c.currency, showPlus: true)}');
      for (final t in g.entries) {
        final note = flattenForPreview(t.description);
        final mark = t.isCompleted ? '☑' : '☐';
        b.writeln('    $mark ${formatMoney(t.amountMinor ?? 0, c.currency, showPlus: true)}'
            '${note.isEmpty ? '' : ' — $note'}');
      }
    }
    return b.toString().trimRight();
  }
  final ordered = [
    ...c.tasks.where((t) => !t.isCompleted),
    ...c.tasks.where((t) => t.isCompleted),
  ];
  for (final t in ordered) {
    final mark = c.hasCheckboxes ? (t.isCompleted ? '☑' : '☐') : '•';
    if (c.isLedger && t.isLedgerEntry) {
      b.writeln('$mark ${t.person ?? t.name} — ${formatMoney(t.remainingMinor, c.currency)}');
    } else if (c.tracksMoney && t.amountMinor != null) {
      b.writeln('$mark ${t.name} — ${formatMoney(t.amountMinor!, c.currency)}');
    } else {
      b.writeln('$mark ${t.name}');
    }
    for (final l in parseRich(t.description)) {
      if (l.type == RichLineType.check) {
        b.writeln('    ${l.checked ? '☑' : '☐'} ${l.content}');
      }
    }
  }
  return b.toString().trimRight();
}

/// Description with checkbox markup turned into ☐ / ☑ glyphs.
String describeForShare(String description) {
  final lines = parseRich(description);
  final markers = displayMarkers(lines);
  final out = <String>[];
  for (final l in lines) {
    final pad = '  ' * l.indent;
    switch (l.type) {
      case RichLineType.blank:
        out.add('');
      case RichLineType.check:
        out.add('$pad${l.checked ? '☑' : '☐'} ${l.content}');
      case RichLineType.bullet:
        out.add('$pad• ${l.content}');
      case RichLineType.numbered:
      case RichLineType.lettered:
        out.add('$pad${markers[l.sourceIndex] ?? ''} ${l.content}');
      case RichLineType.heading:
        out.add(l.content.toUpperCase());
      case RichLineType.quote:
        out.add('“${l.content}”');
      case RichLineType.divider:
        out.add('———');
      case RichLineType.text:
        out.add('$pad${l.content}');
      default:
        // Code, tables and other Markdown blocks are shared as written.
        out.add('$pad${l.content}');
    }
  }
  return out.join('\n').trim();
}
