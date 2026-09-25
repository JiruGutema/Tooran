import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/rich_text.dart';
import 'formatted_text.dart' show FormattedText, RichTextLabels;

export 'formatted_text.dart' show RichTextLabels;

/// Multiline description editor with list continuation on Enter, a
/// formatting toolbar (line types, indent, bold/italic/code/link),
/// "convert pasted lines to a checklist" and an Edit / Preview toggle.
class RichTextEditor extends StatefulWidget {
  const RichTextEditor({
    super.key,
    required this.controller,
    this.labels = const RichTextLabels(),
    this.minLines = 3,
    this.maxLines = 8,
    this.style,
    this.focusNode,
  });

  final TextEditingController controller;
  final RichTextLabels labels;
  final int minLines;
  final int maxLines;
  final TextStyle? style;
  final FocusNode? focusNode;

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  late final _RichListFormatter _formatter = _RichListFormatter(_onPaste);

  int? _pasteStart;
  String? _pasteText;

  /// Showing the rendered preview instead of the text field.
  bool _preview = false;
  final GlobalKey _fieldKey = GlobalKey();
  double? _fieldHeight;

  void _setPreview(bool preview) {
    if (preview == _preview) return;
    if (preview) {
      final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) _fieldHeight = box.size.height;
      _focus.unfocus();
    }
    setState(() {
      _preview = preview;
      if (preview) _pasteStart = _pasteText = null;
    });
    if (!preview) _focus.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant RichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _pasteStart = _pasteText = null;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onPaste(int start, String inserted) {
    if (!mounted) return;
    setState(() {
      _pasteStart = start;
      _pasteText = inserted;
    });
  }

  bool get _pasteValid {
    final s = _pasteStart, p = _pasteText;
    if (s == null || p == null) return false;
    final t = widget.controller.text;
    return s + p.length <= t.length && t.substring(s, s + p.length) == p;
  }

  void _onControllerChanged() {
    if (_pasteText != null && !_pasteValid) {
      setState(() => _pasteStart = _pasteText = null);
    }
  }

  void _dismissPaste() => setState(() => _pasteStart = _pasteText = null);

  void _convertPaste() {
    if (!_pasteValid) return _dismissPaste();
    final c = widget.controller;
    final s = _pasteStart!;
    final e = s + _pasteText!.length;
    final converted = convertToChecklist(_pasteText!);
    setState(() => _pasteStart = _pasteText = null);
    c.value = TextEditingValue(
      text: c.text.replaceRange(s, e, converted),
      selection: TextSelection.collapsed(offset: s + converted.length),
    );
    _focus.requestFocus();
  }

  void _apply(TextEditingValue Function(TextEditingValue v) edit) {
    final c = widget.controller;
    c.value = edit(c.value.copyWith(composing: TextRange.empty));
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink4 = dark ? AppTheme.dInk4 : AppTheme.lInk4;
    final primary = Theme.of(context).colorScheme.primary;
    final labels = widget.labels;

    final tools = <(String, IconData, VoidCallback)>[
      (
        labels.checklist,
        Icons.checklist,
        () => _apply((v) => applyLineType(v, RichLineType.check))
      ),
      (
        labels.bullet,
        Icons.format_list_bulleted,
        () => _apply((v) => applyLineType(v, RichLineType.bullet))
      ),
      (
        labels.numbered,
        Icons.format_list_numbered,
        () => _apply((v) => applyLineType(v, RichLineType.numbered))
      ),
      (
        labels.heading,
        Icons.title,
        () => _apply((v) => applyLineType(v, RichLineType.heading))
      ),
      (
        labels.quote,
        Icons.format_quote,
        () => _apply((v) => applyLineType(v, RichLineType.quote))
      ),
      (
        labels.indent,
        Icons.format_indent_increase,
        () => _apply((v) => indentLines(v, outdent: false))
      ),
      (
        labels.outdent,
        Icons.format_indent_decrease,
        () => _apply((v) => indentLines(v, outdent: true))
      ),
      (
        labels.bold,
        Icons.format_bold,
        () => _apply((v) => toggleInlineMarker(v, '**'))
      ),
      (
        labels.italic,
        Icons.format_italic,
        () => _apply((v) => toggleInlineMarker(v, '*'))
      ),
      (labels.code, Icons.code, () => _apply(toggleCode)),
      (labels.link, Icons.link, () => _apply(insertLink)),
    ];
    final textStyle = widget.style ?? AppTheme.body(size: 15, color: ink);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_preview)
          _buildPreview(textStyle, ink4, dark)
        else
          TextField(
            key: _fieldKey,
            controller: widget.controller,
            focusNode: _focus,
            cursorColor: primary,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            inputFormatters: [_formatter],
            style: textStyle,
            decoration: InputDecoration(
              hintText: labels.descriptionHint,
              hintStyle: AppTheme.body(size: 15, color: ink4),
              border: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: AppTheme.hairline(dark), width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: AppTheme.hairline(dark), width: 1),
              ),
            ),
          ),
        if (_pasteText != null && !_preview)
          TextFieldTapRegion(
            child: _PasteBanner(
              labels: labels,
              onConvert: _convertPaste,
              onDismiss: _dismissPaste,
            ),
          ),
        const SizedBox(height: 12),
        TextFieldTapRegion(
          child: Row(
            children: [
              _ModeToggle(
                editLabel: labels.edit,
                previewLabel: labels.preview,
                preview: _preview,
                onChanged: _setPreview,
              ),
              if (!_preview) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < tools.length; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          _ToolChip(
                            label: tools[i].$1,
                            icon: tools[i].$2,
                            onTap: tools[i].$3,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Read-only rendering of the current text, at least as tall as the text
  /// field was so the surrounding sheet doesn't jump.
  Widget _buildPreview(TextStyle textStyle, Color hintColor, bool dark) {
    final text = widget.controller.text;
    final minHeight = _fieldHeight ??
        widget.minLines *
                (textStyle.fontSize ?? 15) *
                (textStyle.height ?? 1.45) +
            24;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.hairline(dark), width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: text.trim().isEmpty
              ? Text(widget.labels.descriptionHint,
                  style: textStyle.copyWith(color: hintColor))
              : FormattedText(
                  text: text,
                  style: textStyle,
                  labels: widget.labels,
                ),
        ),
      ),
    );
  }
}

/// Two-option Edit / Preview switch, styled like the tool chips.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.editLabel,
    required this.previewLabel,
    required this.preview,
    required this.onChanged,
  });

  final String editLabel;
  final String previewLabel;
  final bool preview;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final primary = Theme.of(context).colorScheme.primary;

    Widget option(String label, IconData icon, bool value) {
      final selected = preview == value;
      final color = selected ? primary : ink2;
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        onTap: () => onChanged(value),
        child: InkWell(
          onTap: () => onChanged(value),
          canRequestFocus: false,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: selected
                  ? primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 5),
                Text(label.toUpperCase(),
                    style: AppTheme.mono(size: 11, color: color)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.hairlineStrong(dark), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          option(editLabel, Icons.edit_outlined, false),
          option(previewLabel, Icons.visibility_outlined, true),
        ],
      ),
    );
  }
}

/// Continues lists on Enter and reports pasted plain multi-line text.
class _RichListFormatter extends TextInputFormatter {
  _RichListFormatter(this.onPaste);

  final void Function(int start, String inserted) onPaste;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final continued = continueList(oldValue, newValue);
    if (continued != null) return continued;

    final o = oldValue.text, n = newValue.text;
    if (n.length - o.length >= 2) {
      var pre = 0;
      final maxPre = o.length < n.length ? o.length : n.length;
      while (pre < maxPre && o.codeUnitAt(pre) == n.codeUnitAt(pre)) {
        pre++;
      }
      var suf = 0;
      while (suf < o.length - pre &&
          suf < n.length - pre &&
          o.codeUnitAt(o.length - 1 - suf) ==
              n.codeUnitAt(n.length - 1 - suf)) {
        suf++;
      }
      final inserted = n.substring(pre, n.length - suf);
      if (inserted.contains('\n') && looksLikePlainList(inserted)) {
        onPaste(pre, inserted);
      }
    }
    return newValue;
  }
}

class _PasteBanner extends StatelessWidget {
  const _PasteBanner({
    required this.labels,
    required this.onConvert,
    required this.onDismiss,
  });

  final RichTextLabels labels;
  final VoidCallback onConvert;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.rSm),
        border: Border.all(color: AppTheme.hairlineStrong(dark), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.checklist, size: 14, color: primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              labels.convertPastedPrompt,
              style: AppTheme.body(size: 13, color: ink2),
            ),
          ),
          TextButton(
            onPressed: onConvert,
            style: TextButton.styleFrom(
              foregroundColor: primary,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 36),
            ),
            child: Text(labels.convert),
          ),
          IconButton(
            onPressed: onDismiss,
            tooltip: labels.dismiss,
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close, color: ink3),
          ),
        ],
      ),
    );
  }
}

/// Small outlined tool chip (28px high, mono label) matching the task sheet.
class _ToolChip extends StatelessWidget {
  const _ToolChip(
      {required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        canRequestFocus: false,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.hairlineStrong(dark), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: ink2),
              const SizedBox(width: 6),
              Text(label.toUpperCase(),
                  style: AppTheme.mono(size: 11, color: ink2)),
            ],
          ),
        ),
      ),
    );
  }
}
