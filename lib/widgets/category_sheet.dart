import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/categories_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/money.dart';
import 'common.dart';
import 'kind_info.dart';

/// Create or edit a category: name, type (tasks / owed to me / I owe),
/// currency for ledgers, icon and accent color.
class CategorySheet extends StatefulWidget {
  const CategorySheet({super.key, this.editing, this.onCreated});

  final Category? editing;
  final ValueChanged<Category>? onCreated;

  @override
  State<CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<CategorySheet> {
  late final TextEditingController _name;
  late final TextEditingController _currency;
  late final TextEditingController _customType;
  late final TextEditingController _target;
  late CategoryKind _kind;
  String? _emoji;
  int? _color;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = widget.editing;
    _name = TextEditingController(text: c?.name ?? '');
    _currency = TextEditingController(
        text: c?.currency ?? context.read<SettingsProvider>().defaultCurrency);
    _customType = TextEditingController(text: c?.customType ?? '');
    _target = TextEditingController(
        text: c?.targetMinor == null ? '' : formatMinor(c!.targetMinor!));
    _kind = c?.kind ?? CategoryKind.tasks;
    _emoji = c?.emoji;
    _color = c?.colorValue;
  }

  @override
  void dispose() {
    _name.dispose();
    _currency.dispose();
    _customType.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final provider = context.read<CategoriesProvider>();
    final err = provider.validateName(_name.text, exceptId: widget.editing?.id);
    if (err != null) {
      setState(() => _error = err == CategoryNameError.empty
          ? l.categoryNameEmpty
          : l.categoryNameDuplicate);
      return;
    }
    final currency = _currency.text.trim().isEmpty ? 'ETB' : _currency.text.trim().toUpperCase();
    final customType =
        _kind == CategoryKind.other && _customType.text.trim().isNotEmpty ? _customType.text.trim() : null;
    final target = _kind == CategoryKind.savings || _kind == CategoryKind.spending
        ? parseAmountMinor(_target.text)
        : null;
    final nav = Navigator.of(context);
    if (widget.editing == null) {
      final c = await provider.addCategory(
        _name.text,
        kind: _kind,
        currency: currency,
        emoji: _emoji,
        colorValue: _color,
        customType: customType,
        targetMinor: target,
      );
      if (c != null) widget.onCreated?.call(c);
    } else {
      await provider.updateCategory(widget.editing!.copyWith(
        name: _name.text.trim(),
        kind: _kind,
        currency: currency,
        emoji: _emoji,
        colorValue: _color,
        customType: customType,
        targetMinor: target,
      ));
    }
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final editing = widget.editing != null;
    // Switching a category that already has plain tasks into a ledger goes
    // through the conversion preview instead.
    final ledgerLocked = editing && !widget.editing!.isLedger && widget.editing!.tasks.isNotEmpty;
    final tracksMoney = Category(name: '', kind: _kind).tracksMoney;

    return SheetShell(
      eyebrow: editing ? l.categoryEdit : l.categoryNew,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: _name,
                autofocus: !editing,
                cursorColor: context.primary,
                textCapitalization: TextCapitalization.sentences,
                style: AppTheme.display(size: 24, color: context.ink),
                decoration: InputDecoration(
                  labelText: l.commonNameLabel,
                  hintText: l.categoryNameHint,
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 22),
            Text(l.categoryTypeLabel, style: AppTheme.eyebrow(context.ink3)),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, box) {
                final cols = box.maxWidth > 420 ? 4 : 2;
                final w = (box.maxWidth - 8 * (cols - 1)) / cols;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in CategoryKind.values)
                      SizedBox(
                        width: w,
                        child: _KindTile(
                          kind: k,
                          selected: _kind == k,
                          enabled: !(ledgerLocked &&
                              k == CategoryKind.money),
                          onTap: () => setState(() => _kind = k),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (ledgerLocked)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l.categoryLedgerLockedHint,
                    style: AppTheme.body(size: 12.5, color: context.ink3)),
              ),
            if (_kind == CategoryKind.other) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _customType,
                textCapitalization: TextCapitalization.words,
                style: AppTheme.body(size: 16, color: context.ink),
                decoration: InputDecoration(
                  labelText: l.categoryCustomTypeLabel,
                  hintText: l.categoryCustomTypeHint,
                ),
              ),
            ],
            if (tracksMoney) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_kind == CategoryKind.savings || _kind == CategoryKind.spending) ...[
                    Expanded(
                      child: TextField(
                        controller: _target,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: AppTheme.body(size: 16, color: context.ink),
                        decoration: InputDecoration(
                            labelText: _kind == CategoryKind.spending
                                ? l.categoryBudgetLabel
                                : l.categoryTargetLabel),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _currency,
                      textCapitalization: TextCapitalization.characters,
                      style: AppTheme.body(size: 16, color: context.ink),
                      decoration: InputDecoration(labelText: l.categoryCurrencyLabel),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 22),
            Text(l.categoryIconLabel, style: AppTheme.eyebrow(context.ink3)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _EmojiChoice(
                  label: '∅',
                  selected: _emoji == null,
                  onTap: () => setState(() => _emoji = null),
                ),
                for (final e in categoryEmojis)
                  _EmojiChoice(
                    label: e,
                    selected: _emoji == e,
                    onTap: () => setState(() => _emoji = e),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(l.categoryColorLabel, style: AppTheme.eyebrow(context.ink3)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorChoice(color: null, selected: _color == null, onTap: () => setState(() => _color = null)),
                for (final c in categoryColors)
                  _ColorChoice(color: c, selected: _color == c, onTap: () => setState(() => _color = c)),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.commonCancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(editing ? l.commonSave : l.commonCreate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmojiChoice extends StatelessWidget {
  const _EmojiChoice({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? context.primary.withValues(alpha: 0.12) : null,
          border: Border.all(
            color: selected ? context.primary : AppTheme.hairline(context.dark),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(label, style: TextStyle(fontSize: 19, color: context.ink3)),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({required this.color, required this.selected, required this.onTap});
  final int? color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = color == null ? context.primary : Color(color!);
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? context.ink : Colors.transparent, width: 2),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color == null ? null : c,
              border: color == null ? Border.all(color: context.ink4, width: 1.5) : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _KindTile extends StatelessWidget {
  const _KindTile({
    required this.kind,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });
  final CategoryKind kind;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fg = selected ? context.primary : context.ink2;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppTheme.rSm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            decoration: BoxDecoration(
              color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(AppTheme.rSm),
              border: Border.all(
                color: selected ? context.primary : AppTheme.hairlineStrong(context.dark),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(kindIcon(kind), size: 20, color: fg),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kindName(l, kind),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.body(size: 14, color: context.ink, weight: FontWeight.w600)),
                      Text(kindDescription(l, kind),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.body(size: 11.5, color: context.ink3).copyWith(height: 1.25)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
