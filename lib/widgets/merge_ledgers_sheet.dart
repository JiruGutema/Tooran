import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/categories_provider.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'kind_info.dart';

/// Combines money lists (e.g. "Take back" + "Give back") into one Money
/// list where + means they owe you and − means you owe them.
class MergeLedgersSheet extends StatefulWidget {
  const MergeLedgersSheet({super.key, required this.category});
  final Category category;

  @override
  State<MergeLedgersSheet> createState() => _MergeLedgersSheetState();
}

class _MergeLedgersSheetState extends State<MergeLedgersSheet> {
  late final List<Category> _all;
  late final Set<String> _selected;
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CategoriesProvider>();
    _all = [widget.category, ...provider.mergeCandidates(widget.category)];
    _selected = _all.map((c) => c.id).toSet();
    _name = TextEditingController(
      text: widget.category.kind == CategoryKind.money ? widget.category.name : '',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_name.text.isEmpty) _name.text = context.l10n.ledgerPresetMoney;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  int get _peopleAfter {
    final keys = <String>{};
    for (final c in _all.where((c) => _selected.contains(c.id))) {
      for (final t in c.tasks) {
        keys.add(CategoriesProvider.personKey(t));
      }
    }
    return keys.length;
  }

  Future<void> _merge() async {
    final l = context.l10n;
    final provider = context.read<CategoriesProvider>();
    final nav = Navigator.of(context);
    final host = nav.context;
    final name = _name.text.trim().isEmpty ? l.ledgerPresetMoney : _name.text.trim();
    // Keep the chosen order: the list the menu was opened from goes first.
    final ids = _all.where((c) => _selected.contains(c.id)).map((c) => c.id).toList();
    final undo = await provider.mergeLedgers(ids, name: name);
    nav.pop();
    if (undo != null && host.mounted) {
      showToast(host, l.mergeDone(name), onUndo: () => provider.undoMerge(undo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SheetShell(
      eyebrow: l.mergeTitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.mergeBody, style: AppTheme.body(size: 14, color: context.ink2)),
            const SizedBox(height: 12),
            for (final c in _all)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _selected.contains(c.id),
                onChanged: (v) => setState(() {
                  v == true ? _selected.add(c.id) : _selected.remove(c.id);
                }),
                secondary: Icon(kindIcon(c.kind), color: context.ink2),
                title: Text(c.emoji == null ? c.name : '${c.emoji} ${c.name}'),
                subtitle: Text('${categoryTypeLabel(l, c)} · ${l.peopleEntries(c.tasks.length)}'),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              style: AppTheme.body(size: 16, color: context.ink),
              decoration: InputDecoration(labelText: l.mergeNameLabel),
            ),
            const SizedBox(height: 10),
            Text(l.mergePeopleCount(_peopleAfter), style: AppTheme.body(size: 13, color: context.ink3)),
            const SizedBox(height: 22),
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
                    onPressed: _selected.length < 2 ? null : _merge,
                    child: Text(l.mergeApply),
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
