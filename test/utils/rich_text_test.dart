import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/utils/rich_text.dart';

RichLine one(String line) => parseRich(line).single;

TextEditingValue at(String text, [int? offset]) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset ?? text.length),
    );

/// Simulates typing '\n' at the end of [text] (or at [offset]).
TextEditingValue? enter(String text, [int? offset]) {
  final o = offset ?? text.length;
  final newText = '${text.substring(0, o)}\n${text.substring(o)}';
  return continueList(
    at(text, o),
    TextEditingValue(
        text: newText, selection: TextSelection.collapsed(offset: o + 1)),
  );
}

void main() {
  group('parseRich', () {
    test('checkbox variants', () {
      for (final s in ['[ ] milk', '- [ ] milk', '* [ ] milk', '• [ ] milk']) {
        final l = one(s);
        expect(l.type, RichLineType.check, reason: s);
        expect(l.checked, isFalse, reason: s);
        expect(l.content, 'milk', reason: s);
      }
      for (final s in ['[x] milk', '[X] milk', '- [x] milk', '- [X] milk']) {
        final l = one(s);
        expect(l.type, RichLineType.check, reason: s);
        expect(l.checked, isTrue, reason: s);
        expect(l.content, 'milk', reason: s);
      }
      expect(one('[ ]').type, RichLineType.check);
      expect(one('[ ]').content, '');
      expect(one('[ ]milk').type, RichLineType.text);
    });

    test('bullets', () {
      for (final s in ['• a', '- a', '* a']) {
        expect(one(s).type, RichLineType.bullet, reason: s);
        expect(one(s).content, 'a');
      }
      expect(one('**bold** text').type, RichLineType.text);
      expect(one('-a').type, RichLineType.text);
    });

    test('numbered and lettered', () {
      expect(one('1. a').type, RichLineType.numbered);
      expect(one('12) a').type, RichLineType.numbered);
      expect(one('12) a').content, 'a');
      expect(one('a. x').type, RichLineType.lettered);
      expect(one('a. x').content, 'x');
      expect(one('1.5 kg flour').type, RichLineType.text);
      expect(one('1.5 kg flour').content, '1.5 kg flour');
      expect(one('2.').type, RichLineType.text);
      expect(one('ab. x').type, RichLineType.text);
      expect(one('A. x').type, RichLineType.text);
    });

    test('heading, quote, divider', () {
      expect(one('# Groceries').type, RichLineType.heading);
      expect(one('# Groceries').content, 'Groceries');
      expect(one('## Sub').type, RichLineType.heading);
      expect(one('## Sub').content, 'Sub');
      expect(one('#hashtag').type, RichLineType.text);
      expect(one('> note').type, RichLineType.quote);
      expect(one('> note').content, 'note');
      expect(one('---').type, RichLineType.divider);
      expect(one('-----').type, RichLineType.divider);
      expect(one('--').type, RichLineType.text);
    });

    test('blank and plain text', () {
      expect(one('').type, RichLineType.blank);
      expect(one('   ').type, RichLineType.blank);
      expect(one('hello').type, RichLineType.text);
      expect(one('hello').content, 'hello');
    });

    test('indentation', () {
      expect(one('  - a').indent, 1);
      expect(one('    - a').indent, 2);
      expect(one('      - a').indent, 2); // clamped
      expect(one('\t[ ] a').indent, 1);
      expect(one('\t\t1. a').indent, 2);
      expect(one(' - a').indent, 0);
      expect(one('  [x] a').checked, isTrue);
    });

    test('windows line endings', () {
      final lines = parseRich('[ ] a\r\n[x] b\r\n1. c\r\n');
      expect(lines.map((l) => l.type).toList(), [
        RichLineType.check,
        RichLineType.check,
        RichLineType.numbered,
        RichLineType.blank,
      ]);
      expect(lines[0].content, 'a');
      expect(lines[1].content, 'b');
      expect(lines[1].checked, isTrue);
      expect(lines[2].content, 'c');
    });

    test('mixed content keeps sourceIndex', () {
      final lines =
          parseRich('# Trip\nBring:\n[ ] tent\n  - pegs\n\n---\n> rain?');
      expect(lines.map((l) => l.type).toList(), [
        RichLineType.heading,
        RichLineType.text,
        RichLineType.check,
        RichLineType.bullet,
        RichLineType.blank,
        RichLineType.divider,
        RichLineType.quote,
      ]);
      expect(lines.map((l) => l.sourceIndex).toList(),
          [0, 1, 2, 3, 4, 5, 6]);
      expect(lines[3].indent, 1);
    });
  });

  group('displayMarkers', () {
    test('renumbers by position', () {
      final m = displayMarkers(parseRich('1. a\n3. b\n4. c'));
      expect(m, {0: '1.', 1: '2.', 2: '3.'});
    });

    test('letters and nested runs', () {
      final m = displayMarkers(parseRich('1. a\n  a. x\n  c. y\n5. b'));
      expect(m, {0: '1.', 1: 'a.', 2: 'b.', 3: '2.'});
    });

    test('runs restart after other content', () {
      final m = displayMarkers(parseRich('1. a\n2. b\ntext\n7. c\n\n9. d'));
      expect(m[0], '1.');
      expect(m[1], '2.');
      expect(m[3], '1.');
      expect(m[5], '1.');
    });

    test('nested run restarts under a new parent', () {
      final m = displayMarkers(parseRich('1. a\n  1. x\n  1. y\n2. b\n  1. z'));
      expect(m, {0: '1.', 1: '1.', 2: '2.', 3: '2.', 4: '1.'});
    });
  });

  group('toggleCheckAt', () {
    test('toggles only the target line', () {
      const text = 'Intro\n[ ] a\n- [x] b\n[X] c';
      expect(toggleCheckAt(text, 1), 'Intro\n[x] a\n- [x] b\n[X] c');
      expect(toggleCheckAt(text, 2), 'Intro\n[ ] a\n- [ ] b\n[X] c');
      expect(toggleCheckAt(text, 3), 'Intro\n[ ] a\n- [x] b\n[ ] c');
    });

    test('keeps other bytes identical, including \\r\\n', () {
      const text = '  [ ] a\r\n\t[ ] b  \r\n1.5 kg\r\n';
      final out = toggleCheckAt(text, 1);
      expect(out, '  [ ] a\r\n\t[x] b  \r\n1.5 kg\r\n');
      expect(out.length, text.length);
      expect(toggleCheckAt(out, 1), text);
    });

    test('no-op for non-check lines and bad indexes', () {
      const text = '- a\nb';
      expect(toggleCheckAt(text, 0), text);
      expect(toggleCheckAt(text, 5), text);
      expect(toggleCheckAt(text, -1), text);
    });
  });

  group('line editing', () {
    test('removeLineAt', () {
      expect(removeLineAt('a\nb\nc', 1), 'a\nc');
      expect(removeLineAt('a\nb\nc', 0), 'b\nc');
      expect(removeLineAt('a\nb\nc', 2), 'a\nb');
      expect(removeLineAt('a', 0), '');
      expect(removeLineAt('a\r\nb\r\nc', 2), 'a\r\nb');
      expect(removeLineAt('a\r\nb\r\nc', 1), 'a\r\nc');
      expect(removeLineAt('a', 3), 'a');
    });

    test('moveLine', () {
      expect(moveLine('a\nb\nc', 0, 2), 'b\nc\na');
      expect(moveLine('a\nb\nc', 2, 0), 'c\na\nb');
      expect(moveLine('a\nb\nc', 1, 0), 'b\na\nc');
      expect(moveLine('a\nb\nc', 0, 1), 'b\na\nc');
      expect(moveLine('a\nb\nc', 1, 1), 'a\nb\nc');
      expect(moveLine('a\r\nb\r\nc', 2, 0), 'c\r\na\r\nb');
    });

    test('listBlockStart', () {
      const text = 'Title\n[ ] a\n  [ ] sub\n[ ] b\n\n[ ] c';
      expect(listBlockStart(text, 3), 1);
      expect(listBlockStart(text, 1), 1);
      expect(listBlockStart(text, 2), 2);
      expect(listBlockStart(text, 5), 5);
      expect(listBlockStart(text, 0), 0);
      expect(moveLine(text, 3, listBlockStart(text, 3)),
          'Title\n[ ] b\n[ ] a\n  [ ] sub\n\n[ ] c');
    });

    test('setLineContent keeps prefix and indent', () {
      expect(setLineContent('x\n  - [x] old\ny', 1, 'new'), 'x\n  - [x] new\ny');
      expect(setLineContent('3) old', 0, 'new'), '3) new');
      expect(setLineContent('plain', 0, 'other'), 'other');
      expect(setLineContent('[ ] a\r\nb', 0, 'z'), '[ ] z\r\nb');
      expect(setLineContent('[ ]', 0, 'z'), '[ ] z');
    });

    test('clearCheckedItems', () {
      expect(clearCheckedItems('[x] a\n[ ] b\n- [X] c\ntext\n[ ] d'),
          '[ ] b\ntext\n[ ] d');
      expect(clearCheckedItems('[ ] a\n[x] b'), '[ ] a');
      expect(clearCheckedItems('no list'), 'no list');
    });

    test('checklistCounts', () {
      final c = checklistCounts('[x] a\n[ ] b\n- [X] c\n• d');
      expect(c.done, 2);
      expect(c.total, 3);
      expect(checklistCounts('nothing'), (done: 0, total: 0));
    });
  });

  group('preview and paste helpers', () {
    test('flattenForPreview', () {
      expect(
        flattenForPreview(
            '# Trip\n[ ] tent\n[x] **stove**\n\n---\n- pegs\n1. map\n> rain?\n'),
        'Trip · tent · stove · pegs · map · rain?',
      );
      expect(flattenForPreview(''), '');
      expect(flattenForPreview('1.5 kg flour'), '1.5 kg flour');
    });

    test('looksLikePlainList', () {
      expect(looksLikePlainList('milk\neggs\nbread'), isTrue);
      expect(looksLikePlainList('milk\n\neggs\n'), isTrue);
      expect(looksLikePlainList('milk'), isFalse);
      expect(looksLikePlainList('milk\n'), isFalse);
      expect(looksLikePlainList('- milk\neggs'), isFalse);
      expect(looksLikePlainList('[ ] milk\n[ ] eggs'), isFalse);
    });

    test('convertToChecklist', () {
      expect(convertToChecklist('milk\n  eggs\n\nbread'),
          '[ ] milk\n  [ ] eggs\n\n[ ] bread');
      expect(convertToChecklist('- a\n1. b\n[x] c'), '[ ] a\n[ ] b\n[x] c');
      expect(convertToChecklist('a\r\nb'), '[ ] a\r\n[ ] b');
    });
  });

  group('parseInline', () {
    test('plain text', () {
      expect(parseInline('hello'), [const InlineSegment(InlineKind.text, 'hello')]);
      expect(parseInline(''), isEmpty);
    });

    test('bold', () {
      expect(parseInline('an **important** note'), const [
        InlineSegment(InlineKind.text, 'an '),
        InlineSegment(InlineKind.bold, 'important'),
        InlineSegment(InlineKind.text, ' note'),
      ]);
      expect(parseInline('**a** and **b**').where((s) => s.kind == InlineKind.bold).length, 2);
      expect(parseInline('2 ** 3 **'), [const InlineSegment(InlineKind.text, '2 ** 3 **')]);
    });

    test('links', () {
      expect(parseInline('see https://example.com/a?b=1.'), const [
        InlineSegment(InlineKind.text, 'see '),
        InlineSegment(InlineKind.link, 'https://example.com/a?b=1',
            url: 'https://example.com/a?b=1'),
        InlineSegment(InlineKind.text, '.'),
      ]);
      expect(parseInline('go www.tooran.io now'), const [
        InlineSegment(InlineKind.text, 'go '),
        InlineSegment(InlineKind.link, 'www.tooran.io', url: 'https://www.tooran.io'),
        InlineSegment(InlineKind.text, ' now'),
      ]);
      expect(parseInline('(http://x.com/a)'), const [
        InlineSegment(InlineKind.text, '('),
        InlineSegment(InlineKind.link, 'http://x.com/a', url: 'http://x.com/a'),
        InlineSegment(InlineKind.text, ')'),
      ]);
      expect(parseInline('https://en.wikipedia.org/wiki/Foo_(bar)').single.url,
          'https://en.wikipedia.org/wiki/Foo_(bar)');
    });
  });

  group('continueList', () {
    test('checkbox continues unchecked', () {
      final v = enter('[x] milk')!;
      expect(v.text, '[x] milk\n[ ] ');
      expect(v.selection.baseOffset, v.text.length);
      expect(enter('- [ ] milk')!.text, '- [ ] milk\n- [ ] ');
    });

    test('numbers increment, keeping delimiter and indent', () {
      expect(enter('3. eggs')!.text, '3. eggs\n4. ');
      expect(enter('9) eggs')!.text, '9) eggs\n10) ');
      expect(enter('a\n  1. x')!.text, 'a\n  1. x\n  2. ');
    });

    test('letters increment', () {
      expect(enter('a. first')!.text, 'a. first\nb. ');
      expect(enter('c. third')!.text, 'c. third\nd. ');
    });

    test('bullets and quotes keep their marker', () {
      expect(enter('• x')!.text, '• x\n• ');
      expect(enter('- x')!.text, '- x\n- ');
      expect(enter('  * x')!.text, '  * x\n  * ');
      expect(enter('> x')!.text, '> x\n> ');
    });

    test('empty item ends the list', () {
      final v = enter('[ ] milk\n[ ] ')!;
      expect(v.text, '[ ] milk\n');
      expect(v.selection.baseOffset, v.text.length);
      expect(enter('1. a\n2. ')!.text, '1. a\n');
      expect(enter('  • ')!.text, '');
    });

    test('splitting in the middle of an item', () {
      final v = enter('[ ] milkeggs\nnext', 8)!;
      expect(v.text, '[ ] milk\n[ ] eggs\nnext');
      expect(v.selection.baseOffset, 13);
    });

    test('returns null when not applicable', () {
      expect(enter('plain text'), isNull);
      expect(enter('# heading'), isNull);
      expect(enter('1.5 kg'), isNull);
      // Not a single newline insertion.
      expect(continueList(at('[ ] a'), at('[ ] ab')), isNull);
      expect(continueList(at('[ ] a'), at('[ ] a\n\n')), isNull);
    });
  });

  group('applyLineType', () {
    test('cursor line gets a checkbox, then toggles off', () {
      final v = applyLineType(at('milk', 2), RichLineType.check);
      expect(v.text, '[ ] milk');
      expect(v.selection.baseOffset, 6);
      final back = applyLineType(v, RichLineType.check);
      expect(back.text, 'milk');
      expect(back.selection.baseOffset, 2);
    });

    test('empty line gets a prefix', () {
      final v = applyLineType(at(''), RichLineType.bullet);
      expect(v.text, '• ');
      expect(v.selection.baseOffset, 2);
    });

    test('selection applies to every touched line', () {
      const text = 'milk\neggs\n\nbread\nafter';
      final v = applyLineType(
        const TextEditingValue(
          text: text,
          selection: TextSelection(baseOffset: 1, extentOffset: 13),
        ),
        RichLineType.check,
      );
      expect(v.text, '[ ] milk\n[ ] eggs\n\n[ ] bread\nafter');
      expect(v.selection.start, 5);
      expect(v.selection.end, 25);
    });

    test('selection ending at a line start excludes that line', () {
      const text = 'a\nb\nc';
      final v = applyLineType(
        const TextEditingValue(
          text: text,
          selection: TextSelection(baseOffset: 0, extentOffset: 4),
        ),
        RichLineType.bullet,
      );
      expect(v.text, '• a\n• b\nc');
    });

    test('numbered is sequential and replaces other prefixes', () {
      const text = '- a\n[x] b\nc';
      final v = applyLineType(
        TextEditingValue(
          text: text,
          selection: TextSelection(baseOffset: 0, extentOffset: text.length),
        ),
        RichLineType.numbered,
      );
      expect(v.text, '1. a\n2. b\n3. c');
    });

    test('numbered continues from item above', () {
      final v = applyLineType(at('1. a\n2. b\nc'), RichLineType.numbered);
      expect(v.text, '1. a\n2. b\n3. c');
    });

    test('toggle off only when all touched lines have the type', () {
      const text = '[ ] a\nb';
      final sel = TextSelection(baseOffset: 0, extentOffset: text.length);
      final v = applyLineType(
          TextEditingValue(text: text, selection: sel), RichLineType.check);
      expect(v.text, '[ ] a\n[ ] b');
      final off = applyLineType(
          TextEditingValue(
              text: v.text,
              selection: TextSelection(baseOffset: 0, extentOffset: v.text.length)),
          RichLineType.check);
      expect(off.text, 'a\nb');
    });

    test('keeps checked state and indent when already a checkbox', () {
      const text = '  [x] a\nb';
      final v = applyLineType(
        TextEditingValue(
          text: text,
          selection: TextSelection(baseOffset: 0, extentOffset: text.length),
        ),
        RichLineType.check,
      );
      expect(v.text, '  [x] a\n[ ] b');
    });

    test('heading and quote', () {
      expect(applyLineType(at('  - Title'), RichLineType.heading).text, '# Title');
      expect(applyLineType(at('## Title'), RichLineType.heading).text, 'Title');
      expect(applyLineType(at('note'), RichLineType.quote).text, '> note');
      expect(applyLineType(at('> note'), RichLineType.quote).text, 'note');
    });

    test('preserves \\r\\n', () {
      final v = applyLineType(
        const TextEditingValue(
          text: 'a\r\nb',
          selection: TextSelection(baseOffset: 0, extentOffset: 4),
        ),
        RichLineType.check,
      );
      expect(v.text, '[ ] a\r\n[ ] b');
    });

    test('invalid selection targets the last line', () {
      final v = applyLineType(
        const TextEditingValue(text: 'a\nb'),
        RichLineType.bullet,
      );
      expect(v.text, 'a\n• b');
      expect(v.selection.baseOffset, v.text.length);
    });
  });

  group('indentLines', () {
    test('indent and outdent with clamping', () {
      var v = at('[ ] a', 5);
      v = indentLines(v, outdent: false);
      expect(v.text, '  [ ] a');
      expect(v.selection.baseOffset, 7);
      v = indentLines(v, outdent: false);
      expect(v.text, '    [ ] a');
      v = indentLines(v, outdent: false);
      expect(v.text, '    [ ] a'); // clamped at 2
      v = indentLines(v, outdent: true);
      expect(v.text, '  [ ] a');
      v = indentLines(v, outdent: true);
      expect(v.text, '[ ] a');
      v = indentLines(v, outdent: true);
      expect(v.text, '[ ] a'); // clamped at 0
      expect(v.selection.baseOffset, 5);
    });

    test('multi-line selection, skipping blanks and headings', () {
      const text = '# H\n- a\n\n- b';
      final v = indentLines(
        TextEditingValue(
          text: text,
          selection: TextSelection(baseOffset: 0, extentOffset: text.length),
        ),
        outdent: false,
      );
      expect(v.text, '# H\n  - a\n\n  - b');
    });

    test('tabs are normalised to spaces', () {
      expect(indentLines(at('\t- a'), outdent: false).text, '    - a');
      expect(indentLines(at('\t- a'), outdent: true).text, '- a');
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // Markdown extensions
  // ════════════════════════════════════════════════════════════════════

  TextEditingValue sel(String text, int base, int extent) => TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: base, extentOffset: extent));

  String selected(TextEditingValue v) =>
      v.text.substring(v.selection.start, v.selection.end);

  List<RichLineType> types(String text) =>
      parseRich(text).map((l) => l.type).toList();

  group('markdown blocks', () {
    test('heading levels', () {
      expect(one('# A').level, 1);
      expect(one('## A').level, 2);
      expect(one('### A').level, 3);
      expect(one('###### A').level, 3);
      expect(one('###### A').content, 'A');
      expect(one('####### A').type, RichLineType.text);
      expect(one('#A').type, RichLineType.text);
      expect(one('text').level, 0);
      expect(one('- a').level, 0);
    });

    test('dividers: ---, ***, ___ with optional spaces', () {
      for (final s in ['---', '***', '___', '* * *', '- - -', '_ _ _', '*****', '  ***  ']) {
        expect(one(s).type, RichLineType.divider, reason: s);
      }
      expect(one('* item').type, RichLineType.bullet);
      expect(one('- item').type, RichLineType.bullet);
      expect(one('**bold**').type, RichLineType.text);
      expect(one('***bold italic***').type, RichLineType.text);
      expect(one('**').type, RichLineType.text);
      expect(one('__').type, RichLineType.text);
      expect(one('-*-').type, RichLineType.text);
      expect(one('snake_case').type, RichLineType.text);
    });

    test('fenced code block', () {
      const text = 'Run:\n```dart\n- [ ] not a box\n  **raw**\n\n```\n[ ] real';
      final lines = parseRich(text);
      expect(lines.map((l) => l.type).toList(), [
        RichLineType.text,
        RichLineType.codeFence,
        RichLineType.code,
        RichLineType.code,
        RichLineType.code,
        RichLineType.codeFence,
        RichLineType.check,
      ]);
      expect(lines[1].content, 'dart');
      expect(lines[2].content, '- [ ] not a box');
      expect(lines[3].content, '  **raw**'); // indentation preserved
      expect(lines[4].content, '');
      expect(lines[5].content, '');
      expect(lines[2].isCode && lines[1].isCode, isTrue);
      expect(lines[6].isCode, isFalse);
    });

    test('closing fence needs at least as many backticks', () {
      expect(types('````\n```\n````\nx'), [
        RichLineType.codeFence,
        RichLineType.code,
        RichLineType.codeFence,
        RichLineType.text,
      ]);
      // Inline triple backticks are not a fence.
      expect(types('```inline```'), [RichLineType.text]);
    });

    test('unclosed fence runs to the end', () {
      expect(types('a\n```\n[ ] x\n# y'), [
        RichLineType.text,
        RichLineType.codeFence,
        RichLineType.code,
        RichLineType.code,
      ]);
    });

    test('checkboxes inside code are not counted or toggled', () {
      const text = '[ ] real\n```\n[ ] fake\n[x] fake\n```\n[x] done';
      expect(checklistCounts(text), (done: 1, total: 2));
      expect(toggleCheckAt(text, 2), text);
      expect(toggleCheckAt(text, 3), text);
      expect(toggleCheckAt(text, 0), text.replaceFirst('[ ] real', '[x] real'));
      expect(clearCheckedItems(text), '[ ] real\n```\n[ ] fake\n[x] fake\n```');
      expect(setLineContent(text, 2, 'x'), text);
      // Unclosed fence swallows the rest.
      expect(checklistCounts('```\n[ ] a\n[x] b'), (done: 0, total: 0));
    });

    test('tables', () {
      const text = 'Plan\n| Day | Task |\n|---|:---:|\n| Mon | **gym** |\n|Tue|rest|\nafter';
      final lines = parseRich(text);
      expect(lines.map((l) => l.type).toList(), [
        RichLineType.text,
        RichLineType.tableRow,
        RichLineType.tableSeparator,
        RichLineType.tableRow,
        RichLineType.tableRow,
        RichLineType.text,
      ]);
      expect(splitTableRow(lines[1].content), ['Day', 'Task']);
      expect(splitTableRow(lines[3].content), ['Mon', '**gym**']);
      expect(splitTableRow(lines[4].content), ['Tue', 'rest']);
      expect(tableAlignments('|---|:---:|--:|:--|'), [
        RichTableAlign.none,
        RichTableAlign.center,
        RichTableAlign.right,
        RichTableAlign.left,
      ]);
      expect(splitTableRow(r'| a \| b | c |'), ['a | b', 'c']);
    });

    test('pipe lines without a separator stay text', () {
      expect(types('| a | b |\n| c | d |'), [RichLineType.text, RichLineType.text]);
      expect(types('|just a pipe'), [RichLineType.text]);
      expect(types('|'), [RichLineType.text]);
      // Cell count mismatch between header and separator.
      expect(types('| a | b |\n|---|'), [RichLineType.text, RichLineType.text]);
      // Table inside code is code.
      expect(types('```\n| a |\n|---|\n```'), [
        RichLineType.codeFence,
        RichLineType.code,
        RichLineType.code,
        RichLineType.codeFence,
      ]);
    });

    test('a new header + separator starts a second table', () {
      expect(types('|a|\n|-|\n|b|\n|c|\n|-|\n|d|'), [
        RichLineType.tableRow,
        RichLineType.tableSeparator,
        RichLineType.tableRow,
        RichLineType.tableRow,
        RichLineType.tableSeparator,
        RichLineType.tableRow,
      ]);
    });

    test('continueList does nothing inside code blocks', () {
      expect(enter('```\n- a'), isNull);
      expect(enter('```\n[ ] a'), isNull);
      expect(enter('```\nx\n```\n- a')!.text, '```\nx\n```\n- a\n- ');
    });

    test('toolbar line helpers skip code and table lines', () {
      const text = '```\ncode\n```\nplain';
      final all = sel(text, 0, text.length);
      expect(applyLineType(all, RichLineType.bullet).text,
          '```\ncode\n```\n• plain');
      expect(indentLines(all, outdent: false).text, '```\ncode\n```\n  plain');
    });

    test('paste helpers ignore code blocks', () {
      expect(looksLikePlainList('```\nfoo\nbar\n```'), isFalse);
      expect(convertToChecklist('a\n```\nb\n```'), '[ ] a\n```\nb\n```');
    });
  });

  group('parseInline markdown', () {
    InlineSegment seg(String text) => parseInline(text).single;

    test('italic with * and _', () {
      expect(parseInline('an *easy* one'), const [
        InlineSegment(InlineKind.text, 'an '),
        InlineSegment(InlineKind.italic, 'easy'),
        InlineSegment(InlineKind.text, ' one'),
      ]);
      expect(seg('_easy_'), const InlineSegment(InlineKind.italic, 'easy'));
      expect(seg('__strong__'), const InlineSegment(InlineKind.bold, 'strong'));
    });

    test('underscores inside words stay plain', () {
      expect(seg('snake_case_words'),
          const InlineSegment(InlineKind.text, 'snake_case_words'));
      expect(seg('file_name.txt and my_var'),
          const InlineSegment(InlineKind.text, 'file_name.txt and my_var'));
      // Intraword `*` still works (CommonMark), unlike `_`.
      expect(parseInline('un*frigging*believable')[1],
          const InlineSegment(InlineKind.italic, 'frigging'));
    });

    test('bold italic', () {
      final s = seg('***both***');
      expect(s.text, 'both');
      expect(s.bold && s.italic, isTrue);
      expect(s.kind, InlineKind.bold);
    });

    test('nested bold and italic', () {
      expect(parseInline('**bold _both_**'), const [
        InlineSegment(InlineKind.bold, 'bold '),
        InlineSegment(InlineKind.bold, 'both', italic: true),
      ]);
      expect(parseInline('*a **b** c*'), const [
        InlineSegment(InlineKind.italic, 'a '),
        InlineSegment(InlineKind.bold, 'b', italic: true),
        InlineSegment(InlineKind.italic, ' c'),
      ]);
      expect(parseInline('**a *b***'), const [
        InlineSegment(InlineKind.bold, 'a '),
        InlineSegment(InlineKind.bold, 'b', italic: true),
      ]);
    });

    test('strikethrough', () {
      expect(parseInline('~~old~~ new'), const [
        InlineSegment(InlineKind.strike, 'old'),
        InlineSegment(InlineKind.text, ' new'),
      ]);
      expect(seg('~single~').kind, InlineKind.text);
      expect(seg('~~ spaced ~~').kind, InlineKind.text);
      final s = parseInline('**~~x~~**').single;
      expect(s.bold && s.strike, isTrue);
    });

    test('code spans are verbatim', () {
      expect(parseInline('run `a **b** _c_` now'), const [
        InlineSegment(InlineKind.text, 'run '),
        InlineSegment(InlineKind.code, 'a **b** _c_'),
        InlineSegment(InlineKind.text, ' now'),
      ]);
      expect(seg('``a ` b``'), const InlineSegment(InlineKind.code, 'a ` b'));
      expect(seg('` x `'), const InlineSegment(InlineKind.code, 'x'));
      expect(seg('`https://x.com`').kind, InlineKind.code);
      expect(seg('**`x`**'), const InlineSegment(InlineKind.code, 'x', bold: true));
    });

    test('markdown links', () {
      expect(parseInline('see [the docs](https://x.com/a_(b)) now'), const [
        InlineSegment(InlineKind.text, 'see '),
        InlineSegment(InlineKind.link, 'the docs', url: 'https://x.com/a_(b)'),
        InlineSegment(InlineKind.text, ' now'),
      ]);
      expect(seg('[site](www.x.com)'),
          const InlineSegment(InlineKind.link, 'site', url: 'https://www.x.com'));
      expect(parseInline('[**big** deal](https://x.com)'), const [
        InlineSegment(InlineKind.link, 'big', url: 'https://x.com', bold: true),
        InlineSegment(InlineKind.link, ' deal', url: 'https://x.com'),
      ]);
      expect(seg('[](https://x.com)'),
          const InlineSegment(InlineKind.link, 'https://x.com', url: 'https://x.com'));
    });

    test('invalid markdown links render literally', () {
      for (final s in [
        '[label](not a url)',
        '[label](foo)',
        '[label](https://)',
        '[label] (https://x.com)',
        '[label](https://x.com',
        'see [1] and (2)',
      ]) {
        expect(parseInline(s).map((x) => x.text).join(), s, reason: s);
        expect(parseInline(s).any((x) => x.kind == InlineKind.link && x.text == 'label'),
            isFalse, reason: s);
      }
      expect(seg('see [1] and (2)'), const InlineSegment(InlineKind.text, 'see [1] and (2)'));
    });

    test('escapes render the literal char', () {
      expect(seg(r'\*not italic\*'),
          const InlineSegment(InlineKind.text, '*not italic*'));
      expect(seg(r'\_x\_ \`y\` \~~z\~~ \[a](b)'),
          const InlineSegment(InlineKind.text, '_x_ `y` ~~z~~ [a](b)'));
      expect(seg(r'C:\Users\me'), const InlineSegment(InlineKind.text, r'C:\Users\me'));
      expect(seg(r'\\'), const InlineSegment(InlineKind.text, r'\'));
    });

    test('unmatched markers render literally', () {
      for (final s in ['**open', 'close**', '*a', '_a', '~~a', '`a', 'a * b', '5 * 3 = 15']) {
        expect(seg(s), InlineSegment(InlineKind.text, s), reason: s);
      }
      expect(parseInline('**a*'), const [
        InlineSegment(InlineKind.text, '*'),
        InlineSegment(InlineKind.italic, 'a'),
      ]);
    });

    test('bare urls still autolink next to markers', () {
      expect(parseInline('**https://x.com**'), const [
        InlineSegment(InlineKind.link, 'https://x.com', url: 'https://x.com', bold: true),
      ]);
      expect(seg('https://x.com/a_b_c').url, 'https://x.com/a_b_c');
      expect(parseInline('go to https://x.com/a*')[1].url, 'https://x.com/a');
    });

    test('stripInline', () {
      expect(stripInline(r'**a** *b* ~~c~~ `d` [e](https://x.com) \*'), 'a b c d e *');
    });
  });

  group('flattenForPreview markdown', () {
    test('strips inline markers and links', () {
      expect(flattenForPreview('## *Plan* for ~~Mon~~ `Tue`\n[x] see [docs](https://x.com)'),
          'Plan for Mon Tue · see docs');
    });

    test('skips fences and separators, joins table cells', () {
      expect(
        flattenForPreview('```js\n  let a = 1;\n```\n| A | B |\n|---|---|\n| **1** | 2 |\n***'),
        'let a = 1; · A · B · 1 · 2',
      );
    });
  });

  group('toggleInlineMarker', () {
    test('wraps a selection', () {
      final v = toggleInlineMarker(sel('make it big', 8, 11), '**');
      expect(v.text, 'make it **big**');
      expect(selected(v), 'big');
      expect(toggleInlineMarker(sel('a b', 2, 3), '*').text, 'a *b*');
      expect(toggleInlineMarker(sel('a b', 2, 3), '`').text, 'a `b`');
    });

    test('keeps surrounding whitespace outside', () {
      final v = toggleInlineMarker(sel('say hi there', 3, 7), '**');
      expect(v.text, 'say **hi** there');
      expect(selected(v), 'hi');
    });

    test('unwraps when markers are just outside the selection', () {
      final v = toggleInlineMarker(sel('make it **big**', 10, 13), '**');
      expect(v.text, 'make it big');
      expect(selected(v), 'big');
    });

    test('unwraps when the selection includes the markers', () {
      final v = toggleInlineMarker(sel('make it **big**', 8, 15), '**');
      expect(v.text, 'make it big');
      expect(selected(v), 'big');
      expect(toggleInlineMarker(sel('`x`', 0, 3), '`').text, 'x');
    });

    test('italic vs bold runs', () {
      // Italic on bold text adds italic instead of stripping a star.
      expect(toggleInlineMarker(sel('**b**', 2, 3), '*').text, '***b***');
      // Italic on bold-italic removes the italic.
      expect(toggleInlineMarker(sel('***b***', 3, 4), '*').text, '**b**');
      // Bold on bold-italic removes the bold.
      expect(toggleInlineMarker(sel('***b***', 3, 4), '**').text, '*b*');
      // Bold on italic adds bold.
      expect(toggleInlineMarker(sel('*b*', 1, 2), '**').text, '***b***');
    });

    test('no selection inserts a pair with the cursor between', () {
      final v = toggleInlineMarker(at('ab', 1), '**');
      expect(v.text, 'a****b');
      expect(v.selection, const TextSelection.collapsed(offset: 3));
      final w = toggleInlineMarker(at(''), '`');
      expect(w.text, '``');
      expect(w.selection.baseOffset, 1);
      // Pressing again removes the empty pair.
      final back = toggleInlineMarker(v, '**');
      expect(back.text, 'ab');
      expect(back.selection.baseOffset, 1);
    });

    test('invalid selection appends at the end', () {
      final v = toggleInlineMarker(
          const TextEditingValue(text: 'x', selection: TextSelection.collapsed(offset: -1)),
          '*');
      expect(v.text, 'x**');
      expect(v.selection.baseOffset, 2);
    });
  });

  group('insertLink', () {
    test('no selection', () {
      final v = insertLink(at('see ', 4));
      expect(v.text, 'see [](https://)');
      expect(v.selection, const TextSelection.collapsed(offset: 5));
    });

    test('selection becomes the label and https:// is selected', () {
      final v = insertLink(sel('read the docs now', 5, 13));
      expect(v.text, 'read [the docs](https://) now');
      expect(selected(v), 'https://');
    });

    test('selected URL becomes the target', () {
      final v = insertLink(sel('go www.x.com', 3, 12));
      expect(v.text, 'go [](www.x.com)');
      expect(v.selection, const TextSelection.collapsed(offset: 4));
    });

    test('selected link is unwrapped', () {
      final v = insertLink(sel('a [b](https://x.com) c', 2, 20));
      expect(v.text, 'a b c');
      expect(selected(v), 'b');
    });
  });

  group('wrapCodeBlock', () {
    test('wraps the touched lines in fences', () {
      const text = 'intro\nlet a = 1;\nlet b = 2;\nend';
      final v = wrapCodeBlock(sel(text, 8, 20));
      expect(v.text, 'intro\n```\nlet a = 1;\nlet b = 2;\n```\nend');
      expect(selected(v), 'let a = 1;\nlet b = 2;');
      expect(types(v.text)[2], RichLineType.code);
    });

    test('toggles an existing block off', () {
      const text = 'intro\n```\nlet a = 1;\nlet b = 2;\n```\nend';
      final v = wrapCodeBlock(sel(text, 12, 14));
      expect(v.text, 'intro\nlet a = 1;\nlet b = 2;\nend');
      expect(selected(v), 'let a = 1;\nlet b = 2;');
    });

    test('unclosed block toggles off too', () {
      expect(wrapCodeBlock(at('```\nx', 5)).text, 'x');
      expect(wrapCodeBlock(at('```\n```', 0)).text, '');
    });

    test('toggleCode picks inline or block', () {
      expect(toggleCode(sel('a b', 2, 3)).text, 'a `b`');
      expect(toggleCode(sel('a\nb', 0, 3)).text, '```\na\nb\n```');
      expect(toggleCode(at('```\nx\n```', 5)).text, 'x');
      // A selection ending right after a newline is still single-line.
      expect(toggleCode(sel('ab\nc', 0, 3)).text, '`ab`\nc');
    });
  });
}
