import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/theme/app_theme.dart';
import 'package:tooran/widgets/formatted_text.dart';
import 'package:tooran/widgets/rich_text_editor.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

void main() {
  group('FormattedText', () {
    testWidgets('tapping a checkbox row toggles and reports new text',
        (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(FormattedText(
        text: 'Intro\n[ ] milk\n[x] eggs',
        onChanged: (t) => changed = t,
      )));

      await tester.tap(find.text('milk'));
      await tester.pumpAndSettle();
      expect(changed, 'Intro\n[x] milk\n[x] eggs');

      await tester.tap(find.text('eggs'));
      await tester.pumpAndSettle();
      expect(changed, 'Intro\n[x] milk\n[ ] eggs');
    });

    testWidgets('read-only mode has no tap effect', (tester) async {
      await tester.pumpWidget(
          _wrap(const FormattedText(text: '[ ] milk\n[ ] eggs\n- bread')));
      expect(find.text('milk'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
      await tester.tap(find.text('milk'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Still unchecked: the check icon stays hidden.
      final opacities = tester
          .widgetList<AnimatedOpacity>(find.ancestor(
              of: find.byIcon(Icons.check), matching: find.byType(AnimatedOpacity)))
          .map((o) => o.opacity);
      expect(opacities, everyElement(0.0));
    });

    testWidgets('renders all line types and renumbers', (tester) async {
      await tester.pumpWidget(_wrap(const FormattedText(
        text: '# Trip\n1. tent\n3. stove\n  a. gas\n---\n> bring **cash**\n'
            'see www.tooran.io\n1.5 kg rice',
      )));
      expect(find.text('Trip'), findsOneWidget);
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsNothing);
      expect(find.text('a.'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.text('bring cash'), findsOneWidget);
      expect(find.text('see www.tooran.io'), findsOneWidget);
      expect(find.text('1.5 kg rice'), findsOneWidget);
    });

    testWidgets('clear checked removes ticked items', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(FormattedText(
        text: '[x] a\n[ ] b\n[x] c\nafter',
        onChanged: (t) => changed = t,
      )));
      expect(find.text('Clear checked'), findsOneWidget);
      await tester.tap(find.text('Clear checked'));
      await tester.pumpAndSettle();
      expect(changed, '[ ] b\nafter');
      expect(find.text('Clear checked'), findsNothing);
    });

    testWidgets('no clear button without checked items', (tester) async {
      await tester.pumpWidget(_wrap(FormattedText(
        text: '[ ] a\n[ ] b',
        onChanged: (_) {},
      )));
      expect(find.text('Clear checked'), findsNothing);
      expect(find.byType(ReorderableListView), findsOneWidget);
    });

    testWidgets('sinkChecked renders unchecked items first', (tester) async {
      await tester.pumpWidget(_wrap(const FormattedText(
        text: '[x] done\n[ ] todo',
        sinkChecked: true,
      )));
      expect(tester.getTopLeft(find.text('todo')).dy,
          lessThan(tester.getTopLeft(find.text('done')).dy));
    });

    testWidgets('long-press menu deletes an item', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(FormattedText(
        text: '[ ] a\n[ ] b',
        onChanged: (t) => changed = t,
      )));
      await tester.longPress(find.text('b'));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Move to top'), findsOneWidget);
      expect(find.text('Make it its own task'), findsNothing);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(changed, '[ ] a');
    });

    testWidgets('long-press menu moves an item to the top', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(FormattedText(
        text: 'List\n- a\n- b\n- c',
        onChanged: (t) => changed = t,
      )));
      await tester.longPress(find.text('c'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move to top'));
      await tester.pumpAndSettle();
      expect(changed, 'List\n- c\n- a\n- b');
    });

    testWidgets('long-press menu edits an item', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(FormattedText(
        text: '1. a\n2. b',
        onChanged: (t) => changed = t,
      )));
      await tester.longPress(find.text('b'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'bee');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(changed, '1. a\n2. bee');
    });

    testWidgets('promote calls onPromote and removes the line',
        (tester) async {
      String? changed;
      String? promoted;
      await tester.pumpWidget(_wrap(FormattedText(
        text: '[ ] a\n[ ] call mum',
        onChanged: (t) => changed = t,
        onPromote: (c) => promoted = c,
      )));
      await tester.longPress(find.text('call mum'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Make it its own task'));
      await tester.pumpAndSettle();
      expect(promoted, 'call mum');
      expect(changed, '[ ] a');
    });

    testWidgets('swiping a checklist item left deletes it', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(FormattedText(
        text: '[ ] a\n[ ] b\n[ ] c',
        onChanged: (t) => changed = t,
      )));
      await tester.drag(find.text('b'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(changed, '[ ] a\n[ ] c');
      expect(find.text('b'), findsNothing);
      expect(find.text('c'), findsOneWidget);
    });

    testWidgets('drag handle reorders checklist items', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(FormattedText(
        text: '[ ] a\n[ ] b\n[ ] c',
        onChanged: (t) => changed = t,
      )));
      final handle = find.byIcon(Icons.drag_indicator).first;
      final rowHeight = tester.getSize(find.byType(Dismissible).first).height;
      final gesture = await tester.startGesture(tester.getCenter(handle));
      await tester.pump(const Duration(milliseconds: 16));
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(Offset(0, rowHeight * 2.2 / 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(changed, '[ ] b\n[ ] c\n[ ] a');
    });

    testWidgets('custom labels are used', (tester) async {
      await tester.pumpWidget(_wrap(FormattedText(
        text: '[x] a',
        onChanged: (_) {},
        labels: const RichTextLabels(clearChecked: 'Wegräumen'),
      )));
      expect(find.text('Wegräumen'), findsOneWidget);
    });
  });

  group('RichTextEditor', () {
    testWidgets('Enter continues and ends a checklist', (tester) async {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(controller: ctrl)));

      final field = find.byType(TextField);
      await tester.enterText(field, '[ ] milk');
      await tester.enterText(field, '[ ] milk\n');
      expect(ctrl.text, '[ ] milk\n[ ] ');
      expect(ctrl.selection.baseOffset, ctrl.text.length);

      await tester.enterText(field, '[ ] milk\n[ ] eggs');
      await tester.enterText(field, '[ ] milk\n[ ] eggs\n');
      expect(ctrl.text, '[ ] milk\n[ ] eggs\n[ ] ');

      // Enter on the empty item ends the list.
      await tester.enterText(field, '[ ] milk\n[ ] eggs\n[ ] \n');
      expect(ctrl.text, '[ ] milk\n[ ] eggs\n');
    });

    testWidgets('Enter increments numbers', (tester) async {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(controller: ctrl)));
      final field = find.byType(TextField);
      await tester.enterText(field, '1. a');
      await tester.enterText(field, '1. a\n');
      expect(ctrl.text, '1. a\n2. ');
    });

    testWidgets('toolbar applies line types and indent', (tester) async {
      final ctrl = TextEditingController(text: 'milk');
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(controller: ctrl)));
      expect(find.text('CHECKLIST'), findsOneWidget);
      expect(find.text('OUTDENT'), findsOneWidget);

      await tester.tap(find.text('CHECKLIST'));
      await tester.pump();
      expect(ctrl.text, '[ ] milk');

      await tester.ensureVisible(find.text('INDENT'));
      await tester.tap(find.text('INDENT'));
      await tester.pump();
      expect(ctrl.text, '  [ ] milk');

      await tester.ensureVisible(find.text('CHECKLIST'));
      await tester.tap(find.text('CHECKLIST'));
      await tester.pump();
      expect(ctrl.text, 'milk');
    });

    testWidgets('pasting plain lines offers checklist conversion',
        (tester) async {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(controller: ctrl)));
      final field = find.byType(TextField);

      await tester.enterText(field, 'Shop:\n');
      await tester.enterText(field, 'Shop:\nmilk\neggs\nbread');
      await tester.pump();
      expect(find.text('Convert pasted lines to a checklist?'), findsOneWidget);

      await tester.tap(find.text('Convert'));
      await tester.pump();
      expect(ctrl.text, 'Shop:\n[ ] milk\n[ ] eggs\n[ ] bread');
      expect(find.text('Convert pasted lines to a checklist?'), findsNothing);
    });

    testWidgets('paste banner can be dismissed', (tester) async {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(controller: ctrl)));
      await tester.enterText(find.byType(TextField), 'milk\neggs');
      await tester.pump();
      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pump();
      expect(find.text('Convert pasted lines to a checklist?'), findsNothing);
      expect(ctrl.text, 'milk\neggs');
    });
  });

  group('FormattedText markdown', () {
    /// All RichText spans with [text], flattened.
    List<TextSpan> spansWith(WidgetTester tester, String text) {
      final out = <TextSpan>[];
      for (final rt in tester.widgetList<RichText>(find.byType(RichText))) {
        rt.text.visitChildren((span) {
          if (span is TextSpan && span.text == text) out.add(span);
          return true;
        });
      }
      return out;
    }

    testWidgets('code block renders its text raw', (tester) async {
      await tester.pumpWidget(_wrap(FormattedText(
        text: 'Run:\n```sh\n**x**\n- [ ] y\n  indented\n```\nafter',
        onChanged: (_) {},
      )));
      expect(find.text('**x**\n- [ ] y\n  indented'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('```sh'), findsNothing);
      expect(find.text('after'), findsOneWidget);
      // No checkbox was rendered for the fake item.
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('unclosed fence renders to the end', (tester) async {
      await tester.pumpWidget(_wrap(const FormattedText(text: '```\n# not a heading\n\n')));
      expect(find.text('# not a heading'), findsOneWidget);
    });

    testWidgets('table renders a Table with a header', (tester) async {
      await tester.pumpWidget(_wrap(const FormattedText(
        text: '| Day | Task |\n|:---|---:|\n| Mon | **gym** |\n| Tue |\n| x |',
      )));
      expect(find.byType(Table), findsOneWidget);
      final table = tester.widget<Table>(find.byType(Table));
      expect(table.children.length, 4);
      expect(table.children.every((r) => r.children.length == 2), isTrue);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Task'), findsOneWidget);
      expect(find.text('gym'), findsOneWidget);
      expect(find.textContaining('---'), findsNothing);
      final gym = spansWith(tester, 'gym').single;
      expect(gym.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('pipe lines without separator stay text', (tester) async {
      await tester.pumpWidget(_wrap(const FormattedText(text: '| a | b |')));
      expect(find.byType(Table), findsNothing);
      expect(find.text('| a | b |'), findsOneWidget);
    });

    testWidgets('markdown link label is tappable', (tester) async {
      await tester.pumpWidget(
          _wrap(const FormattedText(text: 'see [the docs](https://x.com) now')));
      expect(find.text('see the docs now'), findsOneWidget);
      final span = spansWith(tester, 'the docs').single;
      expect(span.recognizer, isA<TapGestureRecognizer>());
      expect((span.recognizer! as TapGestureRecognizer).onTap, isNotNull);
    });

    testWidgets('inline styles', (tester) async {
      await tester.pumpWidget(_wrap(const FormattedText(
          text: '*it* ~~gone~~ `code` ***both*** snake_case_word')));
      expect(find.text('it gone code both snake_case_word'), findsOneWidget);
      expect(spansWith(tester, 'it').single.style?.fontStyle, FontStyle.italic);
      expect(spansWith(tester, 'gone').single.style?.decoration,
          TextDecoration.lineThrough);
      final code = spansWith(tester, 'code').single.style!;
      expect(code.fontFamily, 'monospace');
      final ctx = tester.element(find.byType(FormattedText));
      expect(code.backgroundColor,
          Theme.of(ctx).colorScheme.surfaceContainerHighest);
      final both = spansWith(tester, 'both').single.style!;
      expect(both.fontWeight, FontWeight.w700);
      expect(both.fontStyle, FontStyle.italic);
    });

    testWidgets('heading levels get decreasing sizes', (tester) async {
      await tester.pumpWidget(_wrap(const FormattedText(
        text: '# One\n## Two\n### Three\nbody',
        style: TextStyle(fontSize: 14),
      )));
      double size(String t) => tester.widget<Text>(find.text(t)).style!.fontSize!;
      expect(size('One'), 20);
      expect(size('Two'), 17);
      expect(size('Three'), 15);
      expect(size('body'), 14);
    });

    testWidgets('new dividers render', (tester) async {
      await tester.pumpWidget(_wrap(const FormattedText(text: 'a\n***\nb\n___\n* c')));
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.text('c'), findsOneWidget);
    });
  });

  group('RichTextEditor markdown', () {
    testWidgets('preview toggle renders and hides the TextField',
        (tester) async {
      final ctrl = TextEditingController(text: '**hi** there\n[ ] task');
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(controller: ctrl)));
      expect(find.text('EDIT'), findsOneWidget);
      final fieldHeight = tester.getSize(find.byType(TextField)).height;

      await tester.tap(find.text('PREVIEW'));
      await tester.pump();
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(FormattedText), findsOneWidget);
      expect(find.text('hi there'), findsOneWidget);
      expect(find.text('task'), findsOneWidget);
      expect(find.text('BOLD'), findsNothing); // toolbar hidden
      final previewHeight = tester
          .getSize(find.ancestor(
              of: find.byType(FormattedText),
              matching: find.byType(ConstrainedBox)).first)
          .height;
      expect(previewHeight, greaterThanOrEqualTo(fieldHeight));

      await tester.tap(find.text('EDIT'));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(FormattedText), findsNothing);
      expect(ctrl.text, '**hi** there\n[ ] task');
    });

    testWidgets('empty preview shows the hint', (tester) async {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(controller: ctrl)));
      await tester.tap(find.text('PREVIEW'));
      await tester.pump();
      expect(find.text('Add notes, steps, links…'), findsOneWidget);
    });

    testWidgets('BOLD chip wraps and unwraps the selection', (tester) async {
      final ctrl = TextEditingController(text: 'make big');
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(controller: ctrl)));
      ctrl.selection = const TextSelection(baseOffset: 5, extentOffset: 8);
      await tester.ensureVisible(find.text('BOLD'));
      await tester.tap(find.text('BOLD'));
      await tester.pump();
      expect(ctrl.text, 'make **big**');
      expect(ctrl.selection, const TextSelection(baseOffset: 7, extentOffset: 10));

      await tester.tap(find.text('BOLD'));
      await tester.pump();
      expect(ctrl.text, 'make big');
    });

    testWidgets('ITALIC, CODE and LINK chips', (tester) async {
      final ctrl = TextEditingController(text: 'a b');
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(controller: ctrl)));

      ctrl.selection = const TextSelection(baseOffset: 2, extentOffset: 3);
      await tester.ensureVisible(find.text('ITALIC'));
      await tester.tap(find.text('ITALIC'));
      await tester.pump();
      expect(ctrl.text, 'a *b*');

      ctrl.value = const TextEditingValue(
          text: 'x\ny', selection: TextSelection(baseOffset: 0, extentOffset: 3));
      await tester.ensureVisible(find.text('CODE'));
      await tester.tap(find.text('CODE'));
      await tester.pump();
      expect(ctrl.text, '```\nx\ny\n```');

      ctrl.value = const TextEditingValue(
          text: 'docs', selection: TextSelection(baseOffset: 0, extentOffset: 4));
      await tester.ensureVisible(find.text('LINK'));
      await tester.tap(find.text('LINK'));
      await tester.pump();
      expect(ctrl.text, '[docs](https://)');
      expect(ctrl.selection, const TextSelection(baseOffset: 7, extentOffset: 15));
    });

    testWidgets('Enter inside a code block does not continue lists',
        (tester) async {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(controller: ctrl)));
      final field = find.byType(TextField);
      await tester.enterText(field, '```\n- a');
      await tester.enterText(field, '```\n- a\n');
      expect(ctrl.text, '```\n- a\n');
    });

    testWidgets('custom labels for new chips', (tester) async {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(_wrap(RichTextEditor(
        controller: ctrl,
        labels: const RichTextLabels(bold: 'Fett', preview: 'Vorschau'),
      )));
      expect(find.text('FETT'), findsOneWidget);
      expect(find.text('VORSCHAU'), findsOneWidget);
    });
  });
}
