/// Rich-list / Markdown parsing and editing helpers for task descriptions.
///
/// Descriptions are stored as plain, Markdown-like text (one item per line).
/// Everything in this file is pure and side-effect free so it is easy to test.
///
/// Supported line syntax:
/// * `[ ] x`, `[x] x`, `[X] x` (also `- [ ] x`, `* [ ] x`, `• [ ] x`) – checkbox
/// * `• x`, `- x`, `* x` – bullet
/// * `1. x`, `1) x` – numbered; `a. x` – lettered
/// * `# x` (level 1), `## x` (level 2), `###`…`###### x` (level 3) – heading
/// * `> x` – quote
/// * `---`, `***`, `___` (3+ of the same char, spaces allowed) – divider
/// * 2 spaces (or a tab) per indent level before a prefix, max 2 levels
///
/// Block syntax spanning several lines:
/// * Fenced code: a line of 3+ backticks (optionally followed by a language,
///   e.g. ```` ```dart ````) opens a block that runs until a line of at least
///   as many backticks (or the end of the text). Lines inside are
///   [RichLineType.code] and are never parsed for any other syntax.
/// * Pipe tables: a row `| a | b |` directly followed by a separator
///   `|---|:---:|` (same number of cells), then any number of `|…|` rows.
///   Rows must start *and* end with `|`; tables without leading/trailing pipes
///   are not recognised. Lines starting with `|` without a separator row stay
///   plain text.
///
/// Inline (see [parseInline]): `**bold**`, `*italic*` / `_italic_`,
/// `***bold italic***`, `~~strike~~`, `` `code` ``, `[label](url)`, bare
/// URLs (`http(s)://…`, `www.…`) and backslash escapes (`\*`, `\_`, …).
library;

import 'package:flutter/services.dart' show TextEditingValue, TextSelection, TextRange;

enum RichLineType {
  blank,
  text,
  bullet,
  numbered,
  lettered,
  check,
  heading,
  quote,
  divider,

  /// A ```` ``` ```` fence line (opening or closing). For the opening fence
  /// [RichLine.content] is the info string (language), e.g. `dart`; for the
  /// closing fence it is empty.
  codeFence,

  /// A line inside a fenced code block; [RichLine.content] is the raw line
  /// (indentation preserved, only a trailing `\r` removed).
  code,

  /// A pipe-table row (header or body); [RichLine.content] is the trimmed
  /// raw row, split it with [splitTableRow]. The header is the row directly
  /// followed by a [tableSeparator].
  tableRow,

  /// The `|---|:---:|` line below a table header; see [tableAlignments].
  tableSeparator,
}

/// Maximum nesting level for indented lines.
const int kMaxRichIndent = 2;

class RichLine {
  final RichLineType type;

  /// Nesting level, 0..[kMaxRichIndent].
  final int indent;

  /// Only meaningful for [RichLineType.check].
  final bool checked;

  /// The text after the prefix.
  final String content;

  /// Index of the line in `text.split('\n')`.
  final int sourceIndex;

  /// Heading level for [RichLineType.heading]: 1 (`#`), 2 (`##`) or 3
  /// (`###` to `######`). Always 0 for every other type.
  final int level;

  const RichLine({
    required this.type,
    this.indent = 0,
    this.checked = false,
    this.content = '',
    required this.sourceIndex,
    this.level = 0,
  });

  /// True for lines that belong to a fenced code block (fences included).
  bool get isCode =>
      type == RichLineType.code || type == RichLineType.codeFence;

  bool get isListItem =>
      type == RichLineType.bullet ||
      type == RichLineType.numbered ||
      type == RichLineType.lettered ||
      type == RichLineType.check;

  @override
  bool operator ==(Object other) =>
      other is RichLine &&
      other.type == type &&
      other.indent == indent &&
      other.checked == checked &&
      other.content == content &&
      other.sourceIndex == sourceIndex &&
      other.level == level;

  @override
  int get hashCode =>
      Object.hash(type, indent, checked, content, sourceIndex, level);

  @override
  String toString() =>
      'RichLine(${type.name}, indent: $indent, checked: $checked, '
      'content: "$content", sourceIndex: $sourceIndex'
      '${level == 0 ? '' : ', level: $level'})';
}

// ════════════════════════════════════════════════════════════════════
// Line parsing
// ════════════════════════════════════════════════════════════════════

final RegExp _leadRe = RegExp(r'^[ \t]*');
final RegExp _dividerRe =
    RegExp(r'^(?:(?:-[ \t]*){3,}|(?:\*[ \t]*){3,}|(?:_[ \t]*){3,})$');
final RegExp _checkRe = RegExp(r'^(?:([-*•])\s)?\[([ xX])\](?:\s(.*))?$');
final RegExp _headingRe = RegExp(r'^(#{1,6})\s(.*)$');
final RegExp _quoteRe = RegExp(r'^>(?:\s(.*))?$');
final RegExp _bulletRe = RegExp(r'^([-*•])\s(.*)$');
final RegExp _numberedRe = RegExp(r'^(\d{1,9})([.)])\s(.*)$');
final RegExp _letteredRe = RegExp(r'^([a-z])\.\s(.*)$');

/// Detailed parse of a single line (without its `\n`; a trailing `\r` is
/// ignored).
class _Parsed {
  final RichLineType type;
  final int indent;
  final bool checked;

  /// Raw leading whitespace.
  final String lead;

  /// Offset (within the line) where the content begins.
  final int contentStart;

  /// Content (without trailing `\r`).
  final String content;

  /// Offset of the character inside `[ ]` for checkboxes.
  final int checkPos;

  /// `-`, `*` or `•` for bullets and bullet-style checkboxes.
  final String? bulletChar;
  final int number;
  final String numDelim;
  final String letter;

  /// Heading level (1..3), 0 for non-headings.
  final int level;

  const _Parsed({
    required this.type,
    this.indent = 0,
    this.checked = false,
    this.lead = '',
    required this.contentStart,
    this.content = '',
    this.checkPos = -1,
    this.bulletChar,
    this.number = 0,
    this.numDelim = '.',
    this.letter = '',
    this.level = 0,
  });

  bool get isList =>
      type == RichLineType.bullet ||
      type == RichLineType.numbered ||
      type == RichLineType.lettered ||
      type == RichLineType.check;
}

String _stripCr(String line) =>
    line.endsWith('\r') ? line.substring(0, line.length - 1) : line;

int _indentOf(String lead) {
  var tabs = 0, spaces = 0;
  for (final c in lead.codeUnits) {
    if (c == 0x09) {
      tabs++;
    } else {
      spaces++;
    }
  }
  final level = tabs + spaces ~/ 2;
  return level > kMaxRichIndent ? kMaxRichIndent : level;
}

_Parsed _parseLine(String raw) {
  final line = _stripCr(raw);
  final lead = _leadRe.firstMatch(line)!.group(0)!;
  final rest = line.substring(lead.length);
  final indent = _indentOf(lead);
  final base = lead.length;

  if (rest.trim().isEmpty) {
    return _Parsed(
        type: RichLineType.blank, lead: lead, contentStart: line.length);
  }
  if (_dividerRe.hasMatch(rest)) {
    return _Parsed(
        type: RichLineType.divider, lead: lead, contentStart: line.length);
  }

  var m = _checkRe.firstMatch(rest);
  if (m != null) {
    final content = m.group(3) ?? '';
    final bullet = m.group(1);
    return _Parsed(
      type: RichLineType.check,
      indent: indent,
      checked: m.group(2) != ' ',
      lead: lead,
      contentStart: line.length - content.length,
      content: content,
      checkPos: base + (bullet != null ? 2 : 0) + 1,
      bulletChar: bullet,
    );
  }

  m = _headingRe.firstMatch(rest);
  if (m != null) {
    final content = m.group(2)!;
    final hashes = m.group(1)!.length;
    return _Parsed(
      type: RichLineType.heading,
      lead: lead,
      contentStart: line.length - content.length,
      content: content,
      level: hashes > 3 ? 3 : hashes,
    );
  }

  m = _quoteRe.firstMatch(rest);
  if (m != null) {
    final content = m.group(1) ?? '';
    return _Parsed(
      type: RichLineType.quote,
      indent: indent,
      lead: lead,
      contentStart: line.length - content.length,
      content: content,
    );
  }

  m = _bulletRe.firstMatch(rest);
  if (m != null) {
    final content = m.group(2)!;
    return _Parsed(
      type: RichLineType.bullet,
      indent: indent,
      lead: lead,
      contentStart: line.length - content.length,
      content: content,
      bulletChar: m.group(1),
    );
  }

  m = _numberedRe.firstMatch(rest);
  if (m != null) {
    final content = m.group(3)!;
    return _Parsed(
      type: RichLineType.numbered,
      indent: indent,
      lead: lead,
      contentStart: line.length - content.length,
      content: content,
      number: int.parse(m.group(1)!),
      numDelim: m.group(2)!,
    );
  }

  m = _letteredRe.firstMatch(rest);
  if (m != null) {
    final content = m.group(2)!;
    return _Parsed(
      type: RichLineType.lettered,
      indent: indent,
      lead: lead,
      contentStart: line.length - content.length,
      content: content,
      letter: m.group(1)!,
    );
  }

  return _Parsed(
    type: RichLineType.text,
    indent: indent,
    lead: lead,
    contentStart: base,
    content: rest,
  );
}

// ── Multi-line blocks (fenced code, pipe tables) ────────────────────

enum _Blk { none, fence, code, tableHeader, tableSeparator, tableRow }

final RegExp _fenceOpenRe = RegExp(r'^[ \t]*(`{3,})([^`]*)$');
final RegExp _fenceCloseRe = RegExp(r'^[ \t]*(`{3,})[ \t]*$');
final RegExp _tableSepCellRe = RegExp(r'^[ \t]*:?-+:?[ \t]*$');

bool _isTableRow(String line) {
  final t = line.trim();
  return t.length >= 2 && t.startsWith('|') && t.endsWith('|');
}

bool _isTableSep(String line) {
  if (!_isTableRow(line)) return false;
  final cells = _rawCells(line.trim());
  return cells.isNotEmpty && cells.every(_tableSepCellRe.hasMatch);
}

/// Splits a trimmed `|a|b|` row on unescaped pipes (outer pipes dropped).
List<String> _rawCells(String row) {
  var inner = row;
  if (inner.startsWith('|')) inner = inner.substring(1);
  if (inner.endsWith('|') && !inner.endsWith('\\|')) {
    inner = inner.substring(0, inner.length - 1);
  }
  final cells = <String>[];
  final buf = StringBuffer();
  for (var i = 0; i < inner.length; i++) {
    final c = inner[i];
    if (c == '\\' && i + 1 < inner.length && inner[i + 1] == '|') {
      buf.write('|');
      i++;
    } else if (c == '|') {
      cells.add(buf.toString());
      buf.clear();
    } else {
      buf.write(c);
    }
  }
  cells.add(buf.toString());
  return cells;
}

/// Cells of a pipe-table row (outer pipes removed, cells trimmed, `\|`
/// unescaped). Works on [RichLine.content] of a [RichLineType.tableRow].
List<String> splitTableRow(String row) =>
    [for (final c in _rawCells(row.trim())) c.trim()];

enum RichTableAlign { none, left, center, right }

/// Column alignments of a `|---|:---:|---:|` separator line.
List<RichTableAlign> tableAlignments(String separator) => [
      for (final c in splitTableRow(separator))
        c.startsWith(':') && c.endsWith(':') && c.length > 1
            ? RichTableAlign.center
            : c.endsWith(':')
                ? RichTableAlign.right
                : c.startsWith(':')
                    ? RichTableAlign.left
                    : RichTableAlign.none,
    ];

/// Classifies every line of a `split('\n')` list into multi-line blocks.
List<_Blk> _classify(List<String> lines) {
  final out = List<_Blk>.filled(lines.length, _Blk.none);
  bool startsTable(int i) =>
      i + 1 < lines.length &&
      _isTableRow(lines[i]) &&
      _isTableSep(lines[i + 1]) &&
      _rawCells(lines[i].trim()).length ==
          _rawCells(lines[i + 1].trim()).length;

  var i = 0;
  while (i < lines.length) {
    final line = _stripCr(lines[i]);
    final open = _fenceOpenRe.firstMatch(line);
    if (open != null) {
      final ticks = open.group(1)!.length;
      out[i++] = _Blk.fence;
      while (i < lines.length) {
        final close = _fenceCloseRe.firstMatch(_stripCr(lines[i]));
        if (close != null && close.group(1)!.length >= ticks) {
          out[i++] = _Blk.fence;
          break;
        }
        out[i++] = _Blk.code;
      }
      continue;
    }
    if (startsTable(i)) {
      out[i] = _Blk.tableHeader;
      out[i + 1] = _Blk.tableSeparator;
      i += 2;
      while (i < lines.length &&
          _isTableRow(lines[i]) &&
          !startsTable(i) &&
          _fenceOpenRe.firstMatch(_stripCr(lines[i])) == null) {
        out[i++] = _Blk.tableRow;
      }
      continue;
    }
    i++;
  }
  return out;
}

/// Whether line [index] of [text] is inside a fenced code block (fence lines
/// included).
bool _isCodeLine(List<String> lines, int index) {
  if (index < 0 || index >= lines.length) return false;
  final b = _classify(lines)[index];
  return b == _Blk.fence || b == _Blk.code;
}

/// Parses [text] into one [RichLine] per `\n`-separated line.
List<RichLine> parseRich(String text) {
  final lines = text.split('\n');
  final blocks = _classify(lines);
  return [
    for (var i = 0; i < lines.length; i++) _blockLine(lines[i], blocks[i], i),
  ];
}

RichLine _blockLine(String raw, _Blk block, int index) {
  final line = _stripCr(raw);
  switch (block) {
    case _Blk.none:
      return _toRichLine(_parseLine(raw), index);
    case _Blk.fence:
      final m = _fenceOpenRe.firstMatch(line);
      return RichLine(
        type: RichLineType.codeFence,
        content: m?.group(2)?.trim() ?? '',
        sourceIndex: index,
      );
    case _Blk.code:
      return RichLine(
          type: RichLineType.code, content: line, sourceIndex: index);
    case _Blk.tableHeader:
    case _Blk.tableRow:
      return RichLine(
          type: RichLineType.tableRow,
          content: line.trim(),
          sourceIndex: index);
    case _Blk.tableSeparator:
      return RichLine(
          type: RichLineType.tableSeparator,
          content: line.trim(),
          sourceIndex: index);
  }
}

RichLine _toRichLine(_Parsed p, int index) => RichLine(
      type: p.type,
      indent: p.indent,
      checked: p.checked,
      content: p.content,
      sourceIndex: index,
      level: p.type == RichLineType.heading ? p.level : 0,
    );

// ════════════════════════════════════════════════════════════════════
// Display helpers
// ════════════════════════════════════════════════════════════════════

String _letterFor(int n) {
  // 1 -> a, 26 -> z, 27 -> aa (bijective base 26).
  var s = '';
  while (n > 0) {
    n--;
    s = String.fromCharCode(0x61 + n % 26) + s;
    n ~/= 26;
  }
  return s;
}

/// Display markers for numbered/lettered lines, keyed by `sourceIndex`.
///
/// Items are numbered by their position within a contiguous run of
/// same-type/same-indent items (deeper-indented children don't break the
/// run), so the typed digits don't matter.
Map<int, String> displayMarkers(List<RichLine> lines) {
  final result = <int, String>{};
  final runType = List<RichLineType?>.filled(kMaxRichIndent + 1, null);
  final runCount = List<int>.filled(kMaxRichIndent + 1, 0);

  void resetFrom(int level) {
    for (var l = level; l <= kMaxRichIndent; l++) {
      runType[l] = null;
      runCount[l] = 0;
    }
  }

  for (final line in lines) {
    final isNested = line.isListItem || line.type == RichLineType.quote;
    if (!isNested) {
      resetFrom(0);
      continue;
    }
    final lvl = line.indent.clamp(0, kMaxRichIndent);
    resetFrom(lvl + 1);
    if (runType[lvl] == line.type) {
      runCount[lvl]++;
    } else {
      runType[lvl] = line.type;
      runCount[lvl] = 1;
    }
    if (line.type == RichLineType.numbered) {
      result[line.sourceIndex] = '${runCount[lvl]}.';
    } else if (line.type == RichLineType.lettered) {
      result[line.sourceIndex] = '${_letterFor(runCount[lvl])}.';
    }
  }
  return result;
}

/// Start/end offsets of line [index] in [text] (end excludes `\r\n`/`\n`).
(int, int)? _lineRange(String text, int index) {
  if (index < 0) return null;
  var start = 0;
  for (var i = 0; i < index; i++) {
    final nl = text.indexOf('\n', start);
    if (nl < 0) return null;
    start = nl + 1;
  }
  var end = text.indexOf('\n', start);
  if (end < 0) end = text.length;
  if (end > start && text.codeUnitAt(end - 1) == 0x0D) end--;
  return (start, end);
}

/// Flips `[ ]` <-> `[x]` on line [lineIndex]. Every other byte is untouched.
/// Lines inside fenced code blocks are never toggled.
String toggleCheckAt(String text, int lineIndex) {
  final r = _lineRange(text, lineIndex);
  if (r == null) return text;
  if (_isCodeLine(text.split('\n'), lineIndex)) return text;
  final p = _parseLine(text.substring(r.$1, r.$2));
  if (p.type != RichLineType.check) return text;
  final pos = r.$1 + p.checkPos;
  return text.replaceRange(pos, pos + 1, p.checked ? ' ' : 'x');
}

/// Removes line [lineIndex] (and one adjacent line break).
String removeLineAt(String text, int lineIndex) {
  final r = _lineRange(text, lineIndex);
  if (r == null) return text;
  final (start, _) = r;
  final nl = text.indexOf('\n', start);
  if (nl >= 0) {
    // Remove the line together with its own terminator.
    return text.replaceRange(start, nl + 1, '');
  }
  // Last line: remove the preceding line break instead.
  if (start == 0) return '';
  var cut = start - 1; // the '\n'
  if (cut > 0 && text.codeUnitAt(cut - 1) == 0x0D) cut--;
  return text.substring(0, cut);
}

/// Moves line [from] so that it ends up at index [to].
String moveLine(String text, int from, int to) {
  final count = '\n'.allMatches(text).length + 1;
  if (from < 0 || from >= count) return text;
  to = to.clamp(0, count - 1);
  if (from == to) return text;
  final r = _lineRange(text, from)!;
  final line = text.substring(r.$1, r.$2);
  final eol = text.contains('\r\n') ? '\r\n' : '\n';
  final removed = removeLineAt(text, from);
  final newCount = count - 1;
  if (to >= newCount) {
    return removed + eol + line;
  }
  final target = _lineRange(removed, to)!;
  return removed.replaceRange(target.$1, target.$1, line + eol);
}

/// First line index of the contiguous list block containing [lineIndex]
/// (considering only siblings at the same indent; stops at a shallower
/// parent item).
int listBlockStart(String text, int lineIndex) {
  final lines = parseRich(text);
  if (lineIndex < 0 || lineIndex >= lines.length) return lineIndex;
  final cur = lines[lineIndex];
  if (!cur.isListItem) return lineIndex;
  var j = lineIndex;
  while (j - 1 >= 0 &&
      lines[j - 1].isListItem &&
      lines[j - 1].indent >= cur.indent) {
    j--;
  }
  // Skip deeper children that have no parent inside the block.
  while (j < lineIndex && lines[j].indent > cur.indent) {
    j++;
  }
  return j;
}

/// Replaces the content of line [lineIndex], keeping its prefix and indent.
/// Code-block and table lines are left unchanged.
String setLineContent(String text, int lineIndex, String content) {
  final r = _lineRange(text, lineIndex);
  if (r == null) return text;
  if (_classify(text.split('\n'))[lineIndex] != _Blk.none) return text;
  final p = _parseLine(text.substring(r.$1, r.$2));
  final clean = content.replaceAll('\r', '').replaceAll('\n', ' ');
  if (p.type == RichLineType.blank || p.type == RichLineType.divider) {
    return text.replaceRange(r.$1, r.$2, clean);
  }
  final line = text.substring(r.$1, r.$2);
  // `[ ]` / `>` without a trailing space need one before new content.
  final needsSpace = clean.isNotEmpty &&
      p.contentStart == line.length &&
      !line.endsWith(' ') &&
      !line.endsWith('\t') &&
      p.type != RichLineType.text;
  return text.replaceRange(
      r.$1 + p.contentStart, r.$2, needsSpace ? ' $clean' : clean);
}

/// Removes every checked checkbox line.
String clearCheckedItems(String text) {
  final lines = parseRich(text);
  var out = text;
  for (var i = lines.length - 1; i >= 0; i--) {
    final l = lines[i];
    if (l.type == RichLineType.check && l.checked) out = removeLineAt(out, i);
  }
  return out;
}

/// Number of ticked and total checkbox lines.
({int done, int total}) checklistCounts(String text) {
  var done = 0, total = 0;
  for (final l in parseRich(text)) {
    if (l.type != RichLineType.check) continue;
    total++;
    if (l.checked) done++;
  }
  return (done: done, total: total);
}

/// [content] with all inline markup removed (`**`, `*`, `_`, `~~`, backticks,
/// escapes; `[label](url)` becomes `label`).
String stripInline(String content) =>
    parseInline(content).map((s) => s.text).join();

/// One-line preview: prefixes and inline markers stripped, blank/divider/
/// code-fence/table-separator lines dropped, table rows turned into their
/// cells joined with ` · `, code lines kept verbatim (trimmed), lines joined
/// with ` · `.
String flattenForPreview(String text) {
  final parts = <String>[];
  for (final l in parseRich(text)) {
    final String c;
    switch (l.type) {
      case RichLineType.blank:
      case RichLineType.divider:
      case RichLineType.codeFence:
      case RichLineType.tableSeparator:
        continue;
      case RichLineType.code:
        c = l.content.trim();
      case RichLineType.tableRow:
        c = splitTableRow(l.content)
            .map((cell) => stripInline(cell).trim())
            .where((cell) => cell.isNotEmpty)
            .join(' · ');
      default:
        c = stripInline(l.content).trim();
    }
    if (c.isNotEmpty) parts.add(c);
  }
  return parts.join(' · ');
}

/// True when [pasted] has at least 2 non-empty lines and none of them
/// already carries a list prefix.
bool looksLikePlainList(String pasted) {
  var nonEmpty = 0;
  final lines = pasted.split('\n');
  if (_classify(lines).any((b) => b != _Blk.none)) return false;
  for (final raw in lines) {
    final p = _parseLine(raw);
    if (p.type == RichLineType.blank) continue;
    if (p.type != RichLineType.text) return false;
    nonEmpty++;
  }
  return nonEmpty >= 2;
}

/// Prefixes every non-empty line with `[ ] `, keeping indentation. Existing
/// bullets/numbers are replaced; existing checkboxes, headings and dividers
/// are kept. Code blocks and tables are left untouched.
String convertToChecklist(String text) {
  final lines = text.split('\n');
  final blocks = _classify(lines);
  for (var i = 0; i < lines.length; i++) {
    if (blocks[i] != _Blk.none) continue;
    final raw = lines[i];
    final cr = raw.endsWith('\r') ? '\r' : '';
    final p = _parseLine(raw);
    switch (p.type) {
      case RichLineType.blank:
      case RichLineType.check:
      case RichLineType.heading:
      case RichLineType.divider:
        continue;
      default:
        lines[i] = '${p.lead}[ ] ${p.content}$cr';
    }
  }
  return lines.join('\n');
}

// ════════════════════════════════════════════════════════════════════
// Inline parsing
// ════════════════════════════════════════════════════════════════════

/// Coarse classification of an [InlineSegment]. Precedence: a segment with a
/// [InlineSegment.url] is [link]; else [code]; else [bold], [italic],
/// [strike] (first flag set); else [text]. The style flags on the segment
/// carry the full combination (e.g. a bold italic link).
enum InlineKind { text, bold, link, italic, strike, code }

class InlineSegment {
  final InlineKind kind;
  final String text;

  /// Target URL for [InlineKind.link] (`www.` gets `https://`).
  final String? url;

  final bool bold;
  final bool italic;
  final bool strike;

  /// Inline code span: [text] is verbatim (no formatting inside).
  final bool code;

  /// The flag matching [kind] is implied, e.g.
  /// `InlineSegment(InlineKind.bold, 'x')` has `bold == true`.
  const InlineSegment(
    this.kind,
    this.text, {
    this.url,
    bool bold = false,
    bool italic = false,
    bool strike = false,
    bool code = false,
  })  : bold = bold || kind == InlineKind.bold,
        italic = italic || kind == InlineKind.italic,
        strike = strike || kind == InlineKind.strike,
        code = code || kind == InlineKind.code;

  bool _sameStyle(InlineSegment o) =>
      o.kind == kind &&
      o.url == url &&
      o.bold == bold &&
      o.italic == italic &&
      o.strike == strike &&
      o.code == code;

  @override
  bool operator ==(Object other) =>
      other is InlineSegment && _sameStyle(other) && other.text == text;

  @override
  int get hashCode => Object.hash(kind, text, url, bold, italic, strike, code);

  @override
  String toString() {
    final flags = [
      if (bold && kind != InlineKind.bold) 'bold',
      if (italic && kind != InlineKind.italic) 'italic',
      if (strike && kind != InlineKind.strike) 'strike',
      if (code && kind != InlineKind.code) 'code',
    ];
    return 'InlineSegment(${kind.name}, "$text"'
        '${url == null ? '' : ', $url'}'
        '${flags.isEmpty ? '' : ', +${flags.join('+')}'})';
  }
}

final RegExp _urlRe =
    RegExp(r'(?:https?://|www\.)[^\s<>]+', caseSensitive: false);
final RegExp _punctRe = RegExp(r'[\p{P}\p{S}]', unicode: true);
final RegExp _wordCharRe = RegExp(r'[\p{L}\p{N}]', unicode: true);
const String _escapable = r'''!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~''';

String _trimUrl(String url) {
  var u = url;
  while (u.isNotEmpty) {
    final last = u[u.length - 1];
    if ('.,;:!?\'"*_~'.contains(last)) {
      u = u.substring(0, u.length - 1);
    } else if (last == ')' &&
        ')'.allMatches(u).length > '('.allMatches(u).length) {
      u = u.substring(0, u.length - 1);
    } else if (last == ']' &&
        ']'.allMatches(u).length > '['.allMatches(u).length) {
      u = u.substring(0, u.length - 1);
    } else {
      break;
    }
  }
  return u;
}

/// `https://x` / `http://x` / `mailto:x` as-is, `www.x` → `https://www.x`,
/// anything else (including a bare `https://`) → null.
String? _normalizeUrl(String url) {
  final lower = url.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return url.split('://')[1].isNotEmpty ? url : null;
  }
  if (lower.startsWith('www.')) return url.length > 4 ? 'https://$url' : null;
  if (lower.startsWith('mailto:')) return url.length > 7 ? url : null;
  return null;
}

// ── Inline syntax tree (internal) ───────────────────────────────────

sealed class _N {}

class _Txt extends _N {
  _Txt(this.s);
  final String s;
}

/// A run of `*`, `_` or `~~` that may open and/or close emphasis.
class _Delim extends _N {
  _Delim(this.ch, this.count, {required this.canOpen, required this.canClose})
      : orig = count;
  final String ch;
  int count;
  final int orig;
  final bool canOpen;
  final bool canClose;
}

const int _kBold = 1, _kItalic = 2, _kStrike = 4;

class _Span extends _N {
  _Span(this.style, this.children);
  final int style;
  final List<_N> children;
}

class _Code extends _N {
  _Code(this.s);
  final String s;
}

class _Link extends _N {
  _Link(this.children, this.url);
  final List<_N> children;
  final String url;
}

bool _isWs(String? c) => c == null || c.trim().isEmpty;
bool _isPunct(String? c) => c != null && _punctRe.hasMatch(c);

int _runLength(String s, int i) {
  var j = i;
  while (j < s.length && s[j] == s[i]) {
    j++;
  }
  return j - i;
}

/// Tries to read `[label](url)` at [i]; returns the node and the end offset.
(_Link, int)? _tryMdLink(String s, int i) {
  var depth = 0;
  var j = i + 1;
  while (j < s.length) {
    final c = s[j];
    if (c == '\\' && j + 1 < s.length) {
      j += 2;
      continue;
    }
    if (c == '[') {
      depth++;
    } else if (c == ']') {
      if (depth == 0) break;
      depth--;
    }
    j++;
  }
  if (j + 1 >= s.length || s[j + 1] != '(') return null;
  final labelEnd = j;
  var k = labelEnd + 2;
  var parens = 0;
  while (k < s.length) {
    final c = s[k];
    if (c == ' ' || c == '\t') return null; // no titles / spaces in URLs
    if (c == '\\' && k + 1 < s.length) {
      k += 2;
      continue;
    }
    if (c == '(') {
      parens++;
    } else if (c == ')') {
      if (parens == 0) break;
      parens--;
    }
    k++;
  }
  if (k >= s.length) return null;
  var dest = s.substring(labelEnd + 2, k);
  if (dest.length >= 2 && dest.startsWith('<') && dest.endsWith('>')) {
    dest = dest.substring(1, dest.length - 1);
  }
  final url = _normalizeUrl(dest);
  if (url == null) return null;
  final label = s.substring(i + 1, labelEnd);
  final children = label.trim().isEmpty
      ? <_N>[_Txt(dest)]
      : _processEmphasis(_tokenize(label, links: false));
  return (_Link(children, url), k + 1);
}

List<_N> _tokenize(String s, {required bool links}) {
  final out = <_N>[];
  final buf = StringBuffer();
  void flush() {
    if (buf.isNotEmpty) {
      out.add(_Txt(buf.toString()));
      buf.clear();
    }
  }

  var i = 0;
  while (i < s.length) {
    final c = s[i];

    // Backslash escapes.
    if (c == '\\' && i + 1 < s.length && _escapable.contains(s[i + 1])) {
      buf.write(s[i + 1]);
      i += 2;
      continue;
    }

    // Code spans: a run of n backticks up to the next run of exactly n.
    if (c == '`') {
      final n = _runLength(s, i);
      var j = i + n;
      var close = -1;
      while (j < s.length) {
        if (s[j] == '`') {
          final m = _runLength(s, j);
          if (m == n) {
            close = j;
            break;
          }
          j += m;
        } else {
          j++;
        }
      }
      if (close < 0) {
        buf.write('`' * n);
        i += n;
        continue;
      }
      var code = s.substring(i + n, close);
      if (code.length >= 2 &&
          code.startsWith(' ') &&
          code.endsWith(' ') &&
          code.trim().isNotEmpty) {
        code = code.substring(1, code.length - 1);
      }
      flush();
      out.add(_Code(code));
      i = close + n;
      continue;
    }

    if (links && c == '[') {
      final link = _tryMdLink(s, i);
      if (link != null) {
        flush();
        out.add(link.$1);
        i = link.$2;
        continue;
      }
    }

    // Bare URLs.
    if (links &&
        (c == 'h' || c == 'H' || c == 'w' || c == 'W') &&
        (i == 0 || !_wordCharRe.hasMatch(s[i - 1]))) {
      final m = _urlRe.matchAsPrefix(s, i);
      if (m != null) {
        final raw = m.group(0)!;
        final url = _trimUrl(raw);
        final full = _normalizeUrl(url);
        if (full == null) {
          buf.write(raw);
          i = m.end;
          continue;
        }
        flush();
        out.add(_Link([_Txt(url)], full));
        i += url.length;
        continue;
      }
    }

    // Emphasis delimiter runs.
    if (c == '*' || c == '_' || c == '~') {
      final n = _runLength(s, i);
      if (c == '~' && n != 2) {
        buf.write(c * n);
        i += n;
        continue;
      }
      final before = i == 0 ? null : s[i - 1];
      final after = i + n < s.length ? s[i + n] : null;
      final left = !_isWs(after) &&
          (!_isPunct(after) || _isWs(before) || _isPunct(before));
      final right = !_isWs(before) &&
          (!_isPunct(before) || _isWs(after) || _isPunct(after));
      final bool canOpen, canClose;
      if (c == '_') {
        // Intraword underscores (snake_case) never open or close.
        canOpen = left && (!right || _isPunct(before));
        canClose = right && (!left || _isPunct(after));
      } else {
        canOpen = left;
        canClose = right;
      }
      if (!canOpen && !canClose) {
        buf.write(c * n);
      } else {
        flush();
        out.add(_Delim(c, n, canOpen: canOpen, canClose: canClose));
      }
      i += n;
      continue;
    }

    buf.write(c);
    i++;
  }
  flush();
  return out;
}

/// CommonMark's "process emphasis" over a flat token list, nesting matched
/// ranges into [_Span]s. Unmatched delimiters stay and render literally.
List<_N> _processEmphasis(List<_N> nodes) {
  var ci = 0;
  while (ci < nodes.length) {
    final closer = nodes[ci];
    if (closer is! _Delim || !closer.canClose) {
      ci++;
      continue;
    }
    var oi = -1;
    for (var k = ci - 1; k >= 0; k--) {
      final o = nodes[k];
      if (o is! _Delim || o.ch != closer.ch || !o.canOpen) continue;
      if (closer.ch == '~') {
        if (o.count == closer.count) {
          oi = k;
          break;
        }
        continue;
      }
      // CommonMark's "rule of 3".
      if ((o.canClose || closer.canOpen) &&
          (o.orig + closer.orig) % 3 == 0 &&
          !(o.orig % 3 == 0 && closer.orig % 3 == 0)) {
        continue;
      }
      oi = k;
      break;
    }
    if (oi < 0) {
      ci++;
      continue;
    }
    final opener = nodes[oi] as _Delim;
    final int use, style;
    if (closer.ch == '~') {
      use = 2;
      style = _kStrike;
    } else {
      use = opener.count >= 2 && closer.count >= 2 ? 2 : 1;
      style = use == 2 ? _kBold : _kItalic;
    }
    final span = _Span(style, nodes.sublist(oi + 1, ci));
    opener.count -= use;
    closer.count -= use;
    nodes.replaceRange(oi + 1, ci, [span]);
    ci = oi + 2; // the closer
    if (opener.count == 0) {
      nodes.removeAt(oi);
      ci--;
    }
    if (closer.count == 0) nodes.removeAt(ci);
    // Otherwise the same closer is tried again against an earlier opener.
  }
  return nodes;
}

void _flatten(
    List<_N> nodes, int style, String? url, List<InlineSegment> out) {
  void emit(String text, {bool code = false}) {
    if (text.isEmpty) return;
    final bold = style & _kBold != 0;
    final italic = style & _kItalic != 0;
    final strike = style & _kStrike != 0;
    final kind = url != null
        ? InlineKind.link
        : code
            ? InlineKind.code
            : bold
                ? InlineKind.bold
                : italic
                    ? InlineKind.italic
                    : strike
                        ? InlineKind.strike
                        : InlineKind.text;
    final seg = InlineSegment(kind, text,
        url: url, bold: bold, italic: italic, strike: strike, code: code);
    if (out.isNotEmpty && out.last._sameStyle(seg)) {
      out[out.length - 1] = InlineSegment(kind, out.last.text + text,
          url: url, bold: bold, italic: italic, strike: strike, code: code);
    } else {
      out.add(seg);
    }
  }

  for (final n in nodes) {
    switch (n) {
      case _Txt():
        emit(n.s);
      case _Delim():
        emit(n.ch * n.count);
      case _Code():
        emit(n.s, code: true);
      case _Span():
        _flatten(n.children, style | n.style, url, out);
      case _Link():
        _flatten(n.children, style, n.url, out);
    }
  }
}

/// Splits [content] into styled segments.
///
/// Supports `**bold**` / `__bold__`, `*italic*` / `_italic_` (underscores
/// only at word boundaries, so `snake_case_words` stay plain),
/// `***bold italic***`, `~~strike~~`, `` `code` `` (verbatim), `[label](url)`
/// (http(s), `www.` or `mailto:` targets only; an empty label shows the URL),
/// bare URLs and backslash escapes of ASCII punctuation. Emphasis follows
/// CommonMark's delimiter rules, so nesting like `**bold _both_**` or
/// `*a **b** c*` works. Limits: links can't nest, link labels don't
/// autolink, a single `~` is literal, link URLs can't contain spaces or
/// titles, no images/HTML/reference links. Unmatched markers render
/// literally.
List<InlineSegment> parseInline(String content) {
  final out = <InlineSegment>[];
  _flatten(_processEmphasis(_tokenize(content, links: true)), 0, null, out);
  return out;
}

// ════════════════════════════════════════════════════════════════════
// Editor helpers
// ════════════════════════════════════════════════════════════════════

String? _nextMarker(_Parsed p) {
  switch (p.type) {
    case RichLineType.check:
      return '${p.bulletChar != null ? '${p.bulletChar} ' : ''}[ ] ';
    case RichLineType.bullet:
      return '${p.bulletChar} ';
    case RichLineType.numbered:
      return '${p.number + 1}${p.numDelim} ';
    case RichLineType.lettered:
      if (p.letter == 'z') return null;
      return '${String.fromCharCode(p.letter.codeUnitAt(0) + 1)}. ';
    case RichLineType.quote:
      return '> ';
    default:
      return null;
  }
}

/// List continuation for a `TextInputFormatter`.
///
/// If the user just inserted a single `\n` after a list line, the new line
/// gets the continued prefix (`[ ] ` unchecked, next number, next letter,
/// same bullet, same indent). If the list item was empty, the prefix is
/// removed instead (ending the list). Returns `null` when nothing applies,
/// including inside fenced code blocks.
TextEditingValue? continueList(
    TextEditingValue oldValue, TextEditingValue newValue) {
  final o = oldValue.text;
  final n = newValue.text;
  if (n.length != o.length + 1) return null;
  final sel = newValue.selection;
  if (!sel.isValid || !sel.isCollapsed) return null;
  final p = sel.baseOffset;
  if (p < 1 || p > n.length || n.codeUnitAt(p - 1) != 0x0A) return null;
  if (!n.startsWith(o.substring(0, p - 1)) || n.substring(p) != o.substring(p - 1)) {
    return null;
  }

  final lineStart = p - 2 < 0 ? 0 : n.lastIndexOf('\n', p - 2) + 1;
  final before = n.substring(lineStart, p - 1);
  var afterEnd = n.indexOf('\n', p);
  if (afterEnd < 0) afterEnd = n.length;
  final after = n.substring(p, afterEnd);

  final parsed = _parseLine(before);
  if (!parsed.isList && parsed.type != RichLineType.quote) return null;
  final lines = n.split('\n');
  final lineIndex = '\n'.allMatches(n.substring(0, lineStart)).length;
  if (_classify(lines)[lineIndex] != _Blk.none) return null;

  if (parsed.content.trim().isEmpty && after.trim().isEmpty) {
    // Empty item: end the list by dropping the prefix (and the new line).
    final text = n.substring(0, lineStart) + n.substring(p);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: lineStart),
    );
  }

  final marker = _nextMarker(parsed);
  if (marker == null) return null;
  final prefix = parsed.lead + marker;
  return TextEditingValue(
    text: n.substring(0, p) + prefix + n.substring(p),
    selection: TextSelection.collapsed(offset: p + prefix.length),
  );
}

/// First and last line index touched by [sel] in [text].
(int, int) _touchedLines(String text, TextSelection sel) {
  int start, end;
  if (!sel.isValid) {
    start = end = text.length;
  } else {
    start = sel.start.clamp(0, text.length);
    end = sel.end.clamp(0, text.length);
  }
  if (end > start && text.codeUnitAt(end - 1) == 0x0A) end--;
  int lineOf(int off) {
    var n = 0;
    for (var i = 0; i < off; i++) {
      if (text.codeUnitAt(i) == 0x0A) n++;
    }
    return n;
  }

  return (lineOf(start), lineOf(end));
}

typedef _LineEdit = ({String line, int oldContentStart, int newContentStart});

/// Rewrites lines [first]..[last] via [edit] (which receives lines without
/// `\r`) and maps the selection so it stays on the same content.
TextEditingValue _editLines(
  TextEditingValue value,
  int first,
  int last,
  _LineEdit? Function(int index, String line) edit,
) {
  final text = value.text;
  final lines = text.split('\n');
  final oldStarts = <int>[];
  var acc = 0;
  for (final l in lines) {
    oldStarts.add(acc);
    acc += l.length + 1;
  }

  final edits = <int, _LineEdit>{};
  for (var i = first; i <= last && i < lines.length; i++) {
    final raw = lines[i];
    final cr = raw.endsWith('\r') ? '\r' : '';
    final e = edit(i, _stripCr(raw));
    if (e == null) continue;
    edits[i] = e;
    lines[i] = e.line + cr;
  }
  if (edits.isEmpty) return value;

  final newStarts = <int>[];
  acc = 0;
  for (final l in lines) {
    newStarts.add(acc);
    acc += l.length + 1;
  }
  final newText = lines.join('\n');

  int map(int off) {
    if (off < 0) return off;
    if (off > text.length) off = text.length;
    var li = 0;
    while (li + 1 < oldStarts.length && oldStarts[li + 1] <= off) {
      li++;
    }
    final col = off - oldStarts[li];
    final e = edits[li];
    if (e == null) return newStarts[li] + col;
    final newCol = col >= e.oldContentStart
        ? e.newContentStart + (col - e.oldContentStart)
        : e.newContentStart;
    return (newStarts[li] + newCol).clamp(0, newText.length);
  }

  final sel = value.selection;
  final TextSelection newSel;
  if (!sel.isValid) {
    final lastLine = last.clamp(0, lines.length - 1);
    newSel = TextSelection.collapsed(
        offset: newStarts[lastLine] + _stripCr(lines[lastLine]).length);
  } else {
    newSel = TextSelection(
      baseOffset: map(sel.baseOffset),
      extentOffset: map(sel.extentOffset),
    );
  }
  return TextEditingValue(
    text: newText,
    selection: newSel,
    composing: TextRange.empty,
  );
}

/// Applies [type] as a line prefix to every line touched by the selection
/// (or the cursor's line). If every touched non-empty line already has that
/// type, the prefix is removed instead. Other list prefixes are replaced.
///
/// Supported: check, bullet, numbered, lettered, heading, quote.
TextEditingValue applyLineType(TextEditingValue value, RichLineType type) {
  const supported = {
    RichLineType.check,
    RichLineType.bullet,
    RichLineType.numbered,
    RichLineType.lettered,
    RichLineType.heading,
    RichLineType.quote,
  };
  if (!supported.contains(type)) return value;

  final text = value.text;
  final (first, last) = _touchedLines(text, value.selection);
  final lines = text.split('\n');
  final blocks = _classify(lines);
  bool inBlock(int i) => blocks[i] != _Blk.none;
  final parsed = [
    for (var i = first; i <= last && i < lines.length; i++) _parseLine(lines[i])
  ];
  final nonEmpty = [
    for (var i = first; i <= last && i < lines.length; i++)
      if (!inBlock(i) &&
          parsed[i - first].type != RichLineType.blank &&
          parsed[i - first].type != RichLineType.divider)
        parsed[i - first]
  ];
  final remove = nonEmpty.isNotEmpty && nonEmpty.every((p) => p.type == type);
  final single = first == last;

  // Continue numbering from an item directly above, if any.
  var counter = 1;
  if (first > 0 &&
      (type == RichLineType.numbered || type == RichLineType.lettered)) {
    final prev = _parseLine(lines[first - 1]);
    final firstLead = parsed.first.type == RichLineType.blank
        ? 0
        : parsed.first.indent;
    if (prev.type == type && prev.indent == firstLead) {
      counter = type == RichLineType.numbered
          ? prev.number + 1
          : prev.letter.codeUnitAt(0) - 0x60 + 1;
    }
  }

  return _editLines(value, first, last, (i, line) {
    final p = parsed[i - first];
    if (inBlock(i) || p.type == RichLineType.divider) return null;
    if (p.type == RichLineType.blank && !single) return null;
    if (remove) {
      return (
        line: p.content,
        oldContentStart: p.contentStart,
        newContentStart: 0,
      );
    }
    if (p.type == type && type != RichLineType.numbered &&
        type != RichLineType.lettered) {
      return null; // already has it (keeps checked state)
    }
    final lead = (p.type == RichLineType.blank || type == RichLineType.heading)
        ? ''
        : p.lead;
    String marker;
    switch (type) {
      case RichLineType.check:
        marker = '[ ] ';
      case RichLineType.bullet:
        marker = '• ';
      case RichLineType.numbered:
        marker = '${counter++}. ';
      case RichLineType.lettered:
        marker = counter <= 26 ? '${_letterFor(counter++)}. ' : 'z. ';
      case RichLineType.heading:
        marker = '# ';
      default:
        marker = '> ';
    }
    final prefix = lead + marker;
    return (
      line: prefix + p.content,
      oldContentStart: p.contentStart,
      newContentStart: prefix.length,
    );
  });
}

/// Indents (or outdents) every touched line by one level (2 spaces),
/// clamped to 0..[kMaxRichIndent]. Blank lines, headings, dividers, code
/// blocks and tables are left alone.
TextEditingValue indentLines(TextEditingValue value, {required bool outdent}) {
  final (first, last) = _touchedLines(value.text, value.selection);
  final blocks = _classify(value.text.split('\n'));
  return _editLines(value, first, last, (i, line) {
    if (blocks[i] != _Blk.none) return null;
    final p = _parseLine(line);
    if (p.type == RichLineType.blank ||
        p.type == RichLineType.heading ||
        p.type == RichLineType.divider) {
      return null;
    }
    final level = (p.indent + (outdent ? -1 : 1)).clamp(0, kMaxRichIndent);
    final newLead = '  ' * level;
    if (newLead == p.lead) return null;
    return (
      line: newLead + line.substring(p.lead.length),
      oldContentStart: p.lead.length,
      newContentStart: newLead.length,
    );
  });
}

// ── Inline markers & code blocks (toolbar) ──────────────────────────

bool _isSpace(int unit) =>
    unit == 0x20 || unit == 0x09 || unit == 0x0A || unit == 0x0D;

(int, int) _selRange(String text, TextSelection sel) {
  if (!sel.isValid) return (text.length, text.length);
  return (sel.start.clamp(0, text.length), sel.end.clamp(0, text.length));
}

TextEditingValue _valueWith(String text, int base, int extent) =>
    TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: base, extentOffset: extent),
      composing: TextRange.empty,
    );

/// Wraps the selection in [marker] (`**`, `*`, `_`, `` ` ``, `~~`), or
/// unwraps it when it's already wrapped by exactly that marker (markers
/// either just outside or at the edges of the selection). Surrounding
/// whitespace in the selection stays outside the markers.
///
/// With a collapsed cursor, inserts an empty pair and puts the cursor
/// between; if the cursor already sits in an empty pair, removes it.
///
/// For `*` / `_`, an odd run counts as italic (so `*` toggles italic on
/// `***x***` but wraps `**x**` into `***x***`).
TextEditingValue toggleInlineMarker(TextEditingValue value, String marker) {
  assert(marker.isNotEmpty);
  final text = value.text;
  final k = marker.length;
  final ch = marker.codeUnitAt(0);
  final single = k == 1 && (marker == '*' || marker == '_');
  bool wrapped(int run) => single ? run.isOdd : run >= k;
  int runBack(int pos) {
    var n = 0;
    while (pos - n - 1 >= 0 && text.codeUnitAt(pos - n - 1) == ch) {
      n++;
    }
    return n;
  }

  int runFwd(int pos) {
    var n = 0;
    while (pos + n < text.length && text.codeUnitAt(pos + n) == ch) {
      n++;
    }
    return n;
  }

  var (s, e) = _selRange(text, value.selection);
  final collapsedAt = e;
  while (s < e && _isSpace(text.codeUnitAt(s))) {
    s++;
  }
  while (e > s && _isSpace(text.codeUnitAt(e - 1))) {
    e--;
  }

  if (s == e) {
    final p = collapsedAt;
    final back = runBack(p), fwd = runFwd(p);
    if (back >= k && fwd >= k && wrapped(back < fwd ? back : fwd)) {
      return _valueWith(text.replaceRange(p - k, p + k, ''), p - k, p - k);
    }
    return _valueWith(text.replaceRange(p, p, marker + marker), p + k, p + k);
  }

  final inner = text.substring(s, e);
  // Markers at the edges of the selection.
  if (inner.length >= 2 * k &&
      inner.startsWith(marker) &&
      inner.endsWith(marker)) {
    var a = 0;
    while (a < inner.length && inner.codeUnitAt(a) == ch) {
      a++;
    }
    var b = 0;
    while (b < inner.length && inner.codeUnitAt(inner.length - 1 - b) == ch) {
      b++;
    }
    if (a < inner.length && wrapped(a < b ? a : b)) {
      final unwrapped = inner.substring(k, inner.length - k);
      return _valueWith(text.replaceRange(s, e, unwrapped), s,
          s + unwrapped.length);
    }
  }
  // Markers just outside the selection.
  final back = runBack(s), fwd = runFwd(e);
  if (back >= k && fwd >= k && wrapped(back < fwd ? back : fwd)) {
    final t = text.replaceRange(e, e + k, '').replaceRange(s - k, s, '');
    return _valueWith(t, s - k, e - k);
  }
  return _valueWith(
      text.replaceRange(s, e, '$marker$inner$marker'), s + k, e + k);
}

final RegExp _mdLinkExactRe = RegExp(r'^\[([^\]\n]*)\]\(([^)\s]*)\)$');

/// Inserts a Markdown link.
///
/// * No selection: `[](https://)` with the cursor inside `[]`.
/// * Selection that is a URL: `[](url)` with the cursor inside `[]`.
/// * Other selection: `[sel](https://)` with `https://` selected, ready to
///   be replaced by the real address.
/// * Selection that already is exactly `[label](url)`: unwrapped to `label`.
TextEditingValue insertLink(TextEditingValue value) {
  const placeholder = 'https://';
  final text = value.text;
  var (s, e) = _selRange(text, value.selection);
  while (s < e && _isSpace(text.codeUnitAt(s))) {
    s++;
  }
  while (e > s && _isSpace(text.codeUnitAt(e - 1))) {
    e--;
  }
  if (s == e) {
    final p = value.selection.isValid
        ? value.selection.end.clamp(0, text.length)
        : text.length;
    return _valueWith(
        text.replaceRange(p, p, '[]($placeholder)'), p + 1, p + 1);
  }
  final sel = text.substring(s, e);
  final existing = _mdLinkExactRe.firstMatch(sel);
  if (existing != null) {
    final label = existing.group(1)!;
    return _valueWith(
        text.replaceRange(s, e, label), s, s + label.length);
  }
  if (!sel.contains(RegExp(r'\s')) && _normalizeUrl(sel) != null) {
    return _valueWith(text.replaceRange(s, e, '[]($sel)'), s + 1, s + 1);
  }
  final label = sel.replaceAll(RegExp(r'\s*\n\s*'), ' ');
  final urlStart = s + label.length + 3;
  return _valueWith(text.replaceRange(s, e, '[$label]($placeholder)'),
      urlStart, urlStart + placeholder.length);
}

/// `(openFence, closeFence?)` line indices of every fenced code block.
List<(int, int?)> _codeBlockRanges(List<_Blk> blocks) {
  final out = <(int, int?)>[];
  int? open;
  for (var i = 0; i < blocks.length; i++) {
    if (blocks[i] != _Blk.fence) continue;
    if (open == null) {
      open = i;
    } else {
      out.add((open, i));
      open = null;
    }
  }
  if (open != null) out.add((open, null));
  return out;
}

/// Wraps the lines touched by the selection in a ```` ``` ```` fenced block
/// (fences on their own lines) and selects the wrapped lines. If any touched
/// line is already inside a code block, those blocks' fences are removed
/// instead (toggle).
TextEditingValue wrapCodeBlock(TextEditingValue value) {
  final text = value.text;
  final (first, last) = _touchedLines(text, value.selection);
  final lines = text.split('\n');
  final blocks = _classify(lines);

  int offsetOf(List<String> ls, int line) {
    var off = 0;
    for (var i = 0; i < line; i++) {
      off += ls[i].length + 1;
    }
    return off;
  }

  final hit = [
    for (final r in _codeBlockRanges(blocks))
      if (r.$1 <= last && (r.$2 ?? lines.length - 1) >= first) r
  ];

  if (hit.isEmpty) {
    final start = offsetOf(lines, first);
    final endLine = _stripCr(lines[last]);
    final end = offsetOf(lines, last) + endLine.length;
    final inner = text.substring(start, end);
    final t = text.replaceRange(start, end, '```\n$inner\n```');
    return _valueWith(t, start + 4, start + 4 + inner.length);
  }

  final remove = <int>{
    for (final r in hit) ...[r.$1, if (r.$2 != null) r.$2!],
  };
  final lo = first < hit.first.$1 ? first : hit.first.$1;
  var hi = hit.last.$2 ?? lines.length - 1;
  if (last > hi) hi = last;
  final kept = <String>[];
  var newLo = -1, newHi = -1;
  for (var i = 0; i < lines.length; i++) {
    if (remove.contains(i)) continue;
    if (i >= lo && i <= hi) {
      if (newLo < 0) newLo = kept.length;
      newHi = kept.length;
    }
    kept.add(lines[i]);
  }
  if (kept.isEmpty) return _valueWith('', 0, 0);
  final t = kept.join('\n');
  if (newLo < 0) {
    // Only fences were selected (empty block).
    final line = lo.clamp(0, kept.length - 1);
    final p = offsetOf(kept, line).clamp(0, t.length);
    return _valueWith(t, p, p);
  }
  final start = offsetOf(kept, newLo);
  final end = offsetOf(kept, newHi) + _stripCr(kept[newHi]).length;
  return _valueWith(t, start, end);
}

/// Toolbar "code" action: a multi-line selection, or a cursor/selection
/// inside a fenced block, toggles a fenced block via [wrapCodeBlock];
/// otherwise toggles an inline `` ` `` span via [toggleInlineMarker].
TextEditingValue toggleCode(TextEditingValue value) {
  final text = value.text;
  final (s, e) = _selRange(text, value.selection);
  var end = e;
  if (end > s && text.codeUnitAt(end - 1) == 0x0A) end--;
  final multiLine = text.substring(s, end).contains('\n');
  final (first, last) = _touchedLines(text, value.selection);
  final blocks = _classify(text.split('\n'));
  var inBlock = false;
  for (var i = first; i <= last && i < blocks.length; i++) {
    if (blocks[i] == _Blk.fence || blocks[i] == _Blk.code) inBlock = true;
  }
  if (multiLine || inBlock) return wrapCodeBlock(value);
  return toggleInlineMarker(value, '`');
}
