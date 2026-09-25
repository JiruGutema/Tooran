import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../utils/rich_text.dart';

/// User-visible strings for [FormattedText] and `RichTextEditor`.
///
/// English defaults; the app passes localized values.
class RichTextLabels {
  const RichTextLabels({
    this.clearChecked = 'Clear checked',
    this.edit = 'Edit',
    this.delete = 'Delete',
    this.moveToTop = 'Move to top',
    this.makeOwnTask = 'Make it its own task',
    this.editItemTitle = 'Edit item',
    this.save = 'Save',
    this.cancel = 'Cancel',
    this.checklist = 'Checklist',
    this.bullet = 'Bullet',
    this.numbered = 'Numbered',
    this.heading = 'Heading',
    this.quote = 'Quote',
    this.indent = 'Indent',
    this.outdent = 'Outdent',
    this.convertPastedPrompt = 'Convert pasted lines to a checklist?',
    this.convert = 'Convert',
    this.dismiss = 'Dismiss',
    this.descriptionHint = 'Add notes, steps, links…',
    this.reorder = 'Drag to reorder',
    this.bold = 'Bold',
    this.italic = 'Italic',
    this.code = 'Code',
    this.link = 'Link',
    this.preview = 'Preview',
  });

  final String clearChecked;
  final String edit;
  final String delete;
  final String moveToTop;
  final String makeOwnTask;
  final String editItemTitle;
  final String save;
  final String cancel;
  final String checklist;
  final String bullet;
  final String numbered;
  final String heading;
  final String quote;
  final String indent;
  final String outdent;
  final String convertPastedPrompt;
  final String convert;
  final String dismiss;
  final String descriptionHint;
  final String reorder;

  /// Toolbar chips for inline formatting.
  final String bold;
  final String italic;
  final String code;
  final String link;

  /// Editor mode toggle; the other option uses [edit].
  final String preview;
}

const double _kIndentStep = 18;

/// Renders a task description with rich lists (checkboxes, bullets,
/// numbers, headings, quotes, dividers), fenced code blocks, pipe tables and
/// inline Markdown (bold, italic, strike, code, links).
///
/// Read-only by default. When [onChanged] is set, checkboxes can be ticked,
/// checklist items can be reordered (drag handle), swiped away, and
/// long-pressed for more actions; the new text is reported via [onChanged].
class FormattedText extends StatefulWidget {
  const FormattedText({
    super.key,
    required this.text,
    this.style,
    this.onChanged,
    this.onPromote,
    this.sinkChecked = false,
    this.labels = const RichTextLabels(),
  });

  final String text;
  final TextStyle? style;

  /// Makes the text interactive; called with the rewritten description.
  final ValueChanged<String>? onChanged;

  /// Enables "Make it its own task" in the long-press menu; receives the
  /// item's content. The line is then removed via [onChanged].
  final ValueChanged<String>? onPromote;

  /// Render unchecked items before checked ones within a checkbox run
  /// (display only).
  final bool sinkChecked;

  final RichTextLabels labels;

  @override
  State<FormattedText> createState() => _FormattedTextState();
}

enum _ItemAction { edit, delete, moveToTop, promote }

class _FormattedTextState extends State<FormattedText> {
  late String _text = widget.text;

  bool get _interactive => widget.onChanged != null;
  bool get _hasMenu => widget.onChanged != null || widget.onPromote != null;

  @override
  void didUpdateWidget(covariant FormattedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) _text = widget.text;
  }

  void _commit(String next) {
    if (next == _text) return;
    setState(() => _text = next);
    widget.onChanged?.call(next);
  }

  void _toggle(int line) {
    HapticFeedback.selectionClick();
    _commit(toggleCheckAt(_text, line));
  }

  // ── Long-press menu ────────────────────────────────────────────────
  Future<void> _showMenu(RichLine line) async {
    final labels = widget.labels;
    final canEdit = widget.onChanged != null;
    final atTop = listBlockStart(_text, line.sourceIndex) == line.sourceIndex;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final errorC = dark ? AppTheme.dError : AppTheme.lError;

    HapticFeedback.mediumImpact();
    final action = await showModalBottomSheet<_ItemAction>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
              ListTile(
                leading: Icon(Icons.edit_outlined, color: ink2),
                title: Text(labels.edit),
                onTap: () => Navigator.pop(ctx, _ItemAction.edit),
              ),
            if (canEdit && !atTop)
              ListTile(
                leading: Icon(Icons.vertical_align_top, color: ink2),
                title: Text(labels.moveToTop),
                onTap: () => Navigator.pop(ctx, _ItemAction.moveToTop),
              ),
            if (widget.onPromote != null)
              ListTile(
                leading: Icon(Icons.north_east, color: ink2),
                title: Text(labels.makeOwnTask),
                onTap: () => Navigator.pop(ctx, _ItemAction.promote),
              ),
            if (canEdit)
              ListTile(
                leading: Icon(Icons.delete_outline, color: errorC),
                title: Text(labels.delete, style: TextStyle(color: errorC)),
                onTap: () => Navigator.pop(ctx, _ItemAction.delete),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _ItemAction.edit:
        final result = await showDialog<String>(
          context: context,
          builder: (_) => _EditItemDialog(initial: line.content, labels: labels),
        );
        if (!mounted || result == null) return;
        _commit(setLineContent(_text, line.sourceIndex, result));
      case _ItemAction.delete:
        _commit(removeLineAt(_text, line.sourceIndex));
      case _ItemAction.moveToTop:
        _commit(moveLine(
            _text, line.sourceIndex, listBlockStart(_text, line.sourceIndex)));
      case _ItemAction.promote:
        widget.onPromote?.call(line.content);
        if (widget.onChanged != null) {
          _commit(removeLineAt(_text, line.sourceIndex));
        }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_text.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final base = widget.style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final st = _Styles(
      base: base,
      dark: dark,
      primary: theme.colorScheme.primary,
      codeBg: theme.colorScheme.surfaceContainerHighest,
    );

    final lines = parseRich(_text);
    final markers = displayMarkers(lines);
    var lastCheck = -1;
    var hasChecked = false;
    for (final l in lines) {
      if (l.type == RichLineType.check) {
        lastCheck = l.sourceIndex;
        if (l.checked) hasChecked = true;
      }
    }

    // Drop trailing blank lines so they don't add empty space.
    var end = lines.length;
    while (end > 0 && lines[end - 1].type == RichLineType.blank) {
      end--;
    }

    final children = <Widget>[];
    var i = 0;
    while (i < end) {
      final line = lines[i];
      if (line.type == RichLineType.codeFence) {
        // Opening fence, code lines, optional closing fence.
        var j = i + 1;
        while (j < lines.length && lines[j].type == RichLineType.code) {
          j++;
        }
        var codeEnd = j;
        if (j < lines.length && lines[j].type == RichLineType.codeFence) {
          j++;
        } else {
          // Unclosed fence: drop trailing empty lines.
          while (codeEnd > i + 1 && lines[codeEnd - 1].content.trim().isEmpty) {
            codeEnd--;
          }
        }
        children.add(_buildCodeBlock(
            [for (final l in lines.sublist(i + 1, codeEnd)) l.content], st));
        i = j;
        continue;
      }
      if (line.type == RichLineType.tableRow &&
          i + 1 < lines.length &&
          lines[i + 1].type == RichLineType.tableSeparator) {
        var j = i + 2;
        while (j < lines.length &&
            lines[j].type == RichLineType.tableRow &&
            !(j + 1 < lines.length &&
                lines[j + 1].type == RichLineType.tableSeparator)) {
          j++;
        }
        children.add(_buildTable(line, lines[i + 1], lines.sublist(i + 2, j), st));
        i = j;
        continue;
      }
      if (line.type == RichLineType.check) {
        var j = i;
        while (j < end &&
            lines[j].type == RichLineType.check &&
            lines[j].indent == line.indent) {
          j++;
        }
        final run = lines.sublist(i, j);
        children.add(_buildCheckRun(run, st));
        if (_interactive &&
            hasChecked &&
            lastCheck >= i &&
            lastCheck < j) {
          children.add(_buildClearChecked(st));
        }
        i = j;
        continue;
      }
      children.add(_buildLine(line, markers, st, first: i == 0));
      i++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildLine(RichLine line, Map<int, String> markers, _Styles st,
      {required bool first}) {
    final indent = line.indent * _kIndentStep;
    switch (line.type) {
      case RichLineType.blank:
        return const SizedBox(height: 8);
      case RichLineType.divider:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(
            height: 1,
            color: AppTheme.hairlineStrong(st.dark),
            thickness: 1,
          ),
        );
      case RichLineType.heading:
        return Padding(
          padding: EdgeInsets.only(
              top: first ? 0 : (line.level <= 1 ? 12 : 8), bottom: 4),
          child: Semantics(
            header: true,
            child: _InlineText(
                text: line.content,
                style: st.heading(line.level),
                linkColor: st.primary,
                codeBg: st.codeBg),
          ),
        );
      case RichLineType.quote:
        return Padding(
          padding: EdgeInsets.only(left: indent, bottom: 6, top: 2),
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: st.primary.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
            ),
            child: _InlineText(
                text: line.content,
                style: st.quote,
                linkColor: st.primary,
                codeBg: st.codeBg),
          ),
        );
      case RichLineType.bullet:
      case RichLineType.numbered:
      case RichLineType.lettered:
        final Widget marker;
        if (line.type == RichLineType.bullet) {
          marker = Padding(
            padding: EdgeInsets.only(
                top: (st.lineHeight - 6) / 2, right: 10, left: 4),
            child: _BulletDot(level: line.indent, color: st.primary),
          );
        } else {
          marker = Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 22),
              child: Text(
                markers[line.sourceIndex] ?? '',
                style: st.base.copyWith(
                  fontWeight: FontWeight.w700,
                  color: st.primary,
                ),
              ),
            ),
          );
        }
        final row = Padding(
          padding: EdgeInsets.only(
            left: indent,
            top: _hasMenu ? 3 : 0,
            bottom: _hasMenu ? 5 : 6,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              marker,
              Expanded(
                child: _InlineText(
                    text: line.content,
                style: st.base,
                linkColor: st.primary,
                codeBg: st.codeBg),
              ),
            ],
          ),
        );
        if (!_hasMenu) return row;
        return InkWell(
          onLongPress: () => _showMenu(line),
          borderRadius: BorderRadius.circular(AppTheme.rXs),
          child: row,
        );
      case RichLineType.codeFence:
      case RichLineType.code:
      case RichLineType.tableRow:
      case RichLineType.tableSeparator:
        // Rendered as blocks in [build]; a stray row is shown as text.
        if (line.type != RichLineType.tableRow) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _InlineText(
              text: line.content,
              style: st.base,
              linkColor: st.primary,
              codeBg: st.codeBg),
        );
      case RichLineType.text:
      case RichLineType.check:
        return Padding(
          padding: EdgeInsets.only(left: indent, bottom: 4),
          child: _InlineText(
              text: line.content,
                style: st.base,
                linkColor: st.primary,
                codeBg: st.codeBg),
        );
    }
  }

  Widget _buildCodeBlock(List<String> code, _Styles st) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: st.codeBg,
          borderRadius: BorderRadius.circular(AppTheme.rSm),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SelectableText(code.join('\n'), style: st.code),
        ),
      ),
    );
  }

  Widget _buildTable(RichLine header, RichLine separator, List<RichLine> rows,
      _Styles st) {
    final head = splitTableRow(header.content);
    final cols = head.length;
    final aligns = tableAlignments(separator.content);
    List<String> fit(List<String> cells) => [
          for (var c = 0; c < cols; c++) c < cells.length ? cells[c] : '',
        ];
    TextAlign alignOf(int c) => switch (c < aligns.length ? aligns[c] : null) {
          RichTableAlign.center => TextAlign.center,
          RichTableAlign.right => TextAlign.right,
          _ => TextAlign.left,
        };
    Widget cell(String text, int c, TextStyle style) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: _InlineText(
              text: text,
              style: style,
              linkColor: st.primary,
              codeBg: st.codeBg,
              textAlign: alignOf(c),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          border: TableBorder.all(
            color: AppTheme.hairlineStrong(st.dark),
            width: 1,
            borderRadius: BorderRadius.circular(AppTheme.rXs),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(color: st.codeBg.withValues(alpha: 0.5)),
              children: [
                for (final (c, t) in fit(head).indexed)
                  Semantics(header: true, child: cell(t, c, st.tableHeader)),
              ],
            ),
            for (final r in rows)
              TableRow(children: [
                for (final (c, t) in fit(splitTableRow(r.content)).indexed)
                  cell(t, c, st.base),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRun(List<RichLine> run, _Styles st) {
    final items = List<RichLine>.of(run);
    if (widget.sinkChecked) {
      // Stable partition: unchecked first.
      items
        ..clear()
        ..addAll(run.where((l) => !l.checked))
        ..addAll(run.where((l) => l.checked));
    }

    // Stable keys: content + occurrence, so deleting/moving an item doesn't
    // hand its state to a neighbour.
    final seen = <String, int>{};
    final keys = <Key>[];
    for (final l in items) {
      final id = '${l.indent}|${l.content}';
      final n = seen[id] = (seen[id] ?? 0) + 1;
      keys.add(ValueKey<String>('rich-check|$id|$n'));
    }

    if (!_interactive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [for (final l in items) _checkRow(l, st)],
      );
    }

    final reorderable = items.length >= 2;
    Widget item(int index) {
      final l = items[index];
      return Dismissible(
        key: keys[index],
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: st.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTheme.rXs),
          ),
          child: Icon(Icons.delete_outline, size: 18, color: st.error),
        ),
        onDismissed: (_) => _commit(removeLineAt(_text, l.sourceIndex)),
        child: _checkRow(
          l,
          st,
          handle: reorderable
              ? ReorderableDragStartListener(
                  index: index,
                  child: Semantics(
                    label: widget.labels.reorder,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Icon(Icons.drag_indicator,
                          size: 16, color: st.ink4),
                    ),
                  ),
                )
              : null,
        ),
      );
    }

    if (!reorderable) return item(0);

    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      padding: EdgeInsets.zero,
      proxyDecorator: (child, _, animation) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Material(
          color: st.dark ? AppTheme.dSurface2 : AppTheme.lSurface2,
          elevation: 3 * animation.value,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppTheme.rXs),
          child: child,
        ),
        child: child,
      ),
      onReorderItem: (oldIndex, newIndex) {
        if (newIndex == oldIndex) return;
        HapticFeedback.selectionClick();
        _commit(moveLine(
          _text,
          items[oldIndex].sourceIndex,
          items[newIndex].sourceIndex,
        ));
      },
      children: [for (var k = 0; k < items.length; k++) item(k)],
    );
  }

  Widget _checkRow(RichLine line, _Styles st, {Widget? handle}) {
    final interactive = _interactive;
    final row = Padding(
      padding: EdgeInsets.only(
        left: line.indent * _kIndentStep,
        top: interactive ? 10 : 3,
        bottom: interactive ? 10 : 3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: ((st.lineHeight - 18) / 2).clamp(0, 20).toDouble()),
            child: _CheckBox(checked: line.checked, primary: st.primary, border: st.ink4),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InlineText(
              text: line.content,
              style: line.checked ? st.checkedText : st.base,
              linkColor: st.primary,
              codeBg: st.codeBg,
            ),
          ),
          if (handle != null) handle,
        ],
      ),
    );

    return Semantics(
      container: true,
      checked: line.checked,
      label: line.content,
      excludeSemantics: true,
      onTap: interactive ? () => _toggle(line.sourceIndex) : null,
      onLongPress: _hasMenu ? () => _showMenu(line) : null,
      child: interactive || _hasMenu
          ? InkWell(
              onTap: interactive ? () => _toggle(line.sourceIndex) : null,
              onLongPress: _hasMenu ? () => _showMenu(line) : null,
              borderRadius: BorderRadius.circular(AppTheme.rXs),
              child: row,
            )
          : row,
    );
  }

  Widget _buildClearChecked(_Styles st) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          HapticFeedback.selectionClick();
          _commit(clearCheckedItems(_text));
        },
        style: TextButton.styleFrom(
          foregroundColor: st.ink3,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          textStyle: AppTheme.body(size: 13, weight: FontWeight.w500),
        ),
        icon: const Icon(Icons.done_all, size: 14),
        label: Text(widget.labels.clearChecked),
      ),
    );
  }
}

class _Styles {
  _Styles({
    required this.base,
    required this.dark,
    required this.primary,
    required this.codeBg,
  });

  final TextStyle base;
  final bool dark;
  final Color primary;

  /// Background of code spans/blocks (colorScheme.surfaceContainerHighest).
  final Color codeBg;

  Color get ink => dark ? AppTheme.dInk : AppTheme.lInk;
  Color get ink3 => dark ? AppTheme.dInk3 : AppTheme.lInk3;
  Color get ink4 => dark ? AppTheme.dInk4 : AppTheme.lInk4;
  Color get error => dark ? AppTheme.dError : AppTheme.lError;

  double get lineHeight => (base.fontSize ?? 14) * (base.height ?? 1.45);

  /// Level 1: body+6, level 2: body+3, level 3: body+1 (all w600).
  TextStyle heading(int level) {
    final size = base.fontSize ?? 14;
    final delta = switch (level) { <= 1 => 6.0, 2 => 3.0, _ => 1.0 };
    return base.merge(AppTheme.body(
        size: size + delta, weight: FontWeight.w600, color: ink));
  }

  TextStyle get tableHeader =>
      base.copyWith(fontWeight: FontWeight.w600, color: ink);

  TextStyle get code => base.copyWith(
        fontFamily: 'monospace',
        fontFamilyFallback: const ['monospace'],
        fontSize: (base.fontSize ?? 14) - 1,
        letterSpacing: 0,
        height: 1.4,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  TextStyle get quote => base.copyWith(fontStyle: FontStyle.italic, color: ink3);

  TextStyle get checkedText => base.copyWith(
        color: ink3,
        decoration: TextDecoration.lineThrough,
        decorationColor: ink3,
      );
}

class _BulletDot extends StatelessWidget {
  const _BulletDot({required this.level, required this.color});
  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = color.withValues(alpha: 0.7);
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: level == 1 ? Colors.transparent : c,
        shape: BoxShape.circle,
        border: level == 1 ? Border.all(color: c, width: 1.2) : null,
      ),
    );
  }
}

/// 18px rounded checkbox matching the app's task checkbox.
class _CheckBox extends StatelessWidget {
  const _CheckBox(
      {required this.checked, required this.primary, required this.border});
  final bool checked;
  final Color primary;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: checked ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.rXs),
        border: Border.all(color: checked ? primary : border, width: 1.5),
      ),
      child: AnimatedScale(
        scale: checked ? 1 : 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: checked ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(Icons.check, size: 12, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}

/// Text with inline Markdown (bold, italic, strike, code) and tappable links.
class _InlineText extends StatefulWidget {
  const _InlineText({
    required this.text,
    required this.style,
    required this.linkColor,
    required this.codeBg,
    this.textAlign,
  });
  final String text;
  final TextStyle style;
  final Color linkColor;
  final Color codeBg;
  final TextAlign? textAlign;

  @override
  State<_InlineText> createState() => _InlineTextState();
}

class _InlineTextState extends State<_InlineText> {
  final List<TapGestureRecognizer> _recognizers = [];
  List<InlineSegment> _segments = const [];

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(covariant _InlineText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _parse();
  }

  void _parse() {
    _disposeRecognizers();
    _segments = parseInline(widget.text);
    for (final s in _segments) {
      if (s.url != null) {
        _recognizers.add(TapGestureRecognizer()..onTap = () => _open(s.url!));
      }
    }
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  static Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Nothing sensible to do if no app can open the link.
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  TextStyle? _styleFor(InlineSegment s) {
    final base = widget.style;
    final decorations = <TextDecoration>[
      if (base.decoration != null && base.decoration != TextDecoration.none)
        base.decoration!,
      if (s.strike) TextDecoration.lineThrough,
      if (s.url != null) TextDecoration.underline,
    ];
    final plain = !s.bold && !s.italic && !s.code && decorations.isEmpty;
    if (plain && s.url == null) return null;
    return TextStyle(
      fontWeight: s.bold ? FontWeight.w700 : null,
      fontStyle: s.italic ? FontStyle.italic : null,
      color: s.url != null ? widget.linkColor : null,
      decoration: decorations.isEmpty
          ? null
          : TextDecoration.combine(decorations),
      decorationColor: s.url != null ? widget.linkColor : null,
      fontFamily: s.code ? 'monospace' : null,
      fontFamilyFallback: s.code ? const ['monospace'] : null,
      fontSize: s.code ? (base.fontSize ?? 14) - 1 : null,
      letterSpacing: s.code ? 0 : null,
      backgroundColor: s.code ? widget.codeBg : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    if (_segments.isEmpty ||
        (_segments.length == 1 && _segments.first.kind == InlineKind.text)) {
      return Text(
        _segments.isEmpty ? widget.text : _segments.first.text,
        style: style,
        textAlign: widget.textAlign,
      );
    }
    var r = 0;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (final s in _segments)
            TextSpan(
              text: s.text,
              style: _styleFor(s),
              recognizer: s.url != null ? _recognizers[r++] : null,
              mouseCursor: s.url != null ? SystemMouseCursors.click : null,
            ),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}

class _EditItemDialog extends StatefulWidget {
  const _EditItemDialog({required this.initial, required this.labels});
  final String initial;
  final RichTextLabels labels;

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() => Navigator.pop(context, _ctrl.text.trim());

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    return AlertDialog(
      title: Text(widget.labels.editItemTitle),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        style: AppTheme.body(size: 15, color: ink),
        cursorColor: Theme.of(context).colorScheme.primary,
        decoration: const InputDecoration(),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.labels.cancel),
        ),
        TextButton(onPressed: _save, child: Text(widget.labels.save)),
      ],
    );
  }
}
