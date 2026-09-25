import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../providers/categories_provider.dart';
import '../theme/app_theme.dart';
import '../utils/ledger_parse.dart';
import 'common.dart';

/// "Add as task to…" picker for text shared into Tooran from another app.
/// The first line becomes the task name, the rest its description.
class SharedTextSheet extends StatelessWidget {
  const SharedTextSheet({super.key, required this.text});
  final String text;

  static (String, String) split(String text) {
    final lines = text.trim().split(RegExp(r'\r?\n'));
    var name = lines.first.trim();
    var rest = lines.skip(1).join('\n').trim();
    if (name.length > 120) {
      rest = '$name\n$rest'.trim();
      name = '${name.substring(0, 117)}…';
    }
    return (name, rest);
  }

  Future<void> _add(BuildContext context, Category c) async {
    final l = context.l10n;
    final provider = context.read<CategoriesProvider>();
    final (name, rest) = split(text);
    Task task;
    if (c.isLedger) {
      final parsed = parseLedgerName(name);
      final person = parsed.person.isEmpty ? name : parsed.person;
      task = Task(name: person, person: person, amountMinor: parsed.amountMinor ?? 0, description: rest);
    } else {
      task = Task(name: name, description: rest);
    }
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    await provider.addTask(c.id, task);
    nav.pop();
    messenger?.showSnackBar(SnackBar(content: Text(l.shareAdded(c.name))));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final categories = context.watch<CategoriesProvider>().categories;
    final (name, rest) = split(text);
    return SheetShell(
      eyebrow: l.shareReceivedTitle,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.rMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.body(size: 16, color: context.ink, weight: FontWeight.w500)),
                if (rest.isNotEmpty)
                  Text(rest,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body(size: 13, color: context.ink3)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty)
            Text(l.shareNoCategories, style: AppTheme.body(size: 14, color: context.ink3))
          else ...[
            Text(l.shareReceivedPick.toUpperCase(), style: AppTheme.eyebrow(context.ink3)),
            const SizedBox(height: 6),
            for (final c in categories)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(c.emoji ?? (c.isLedger ? '💰' : '📋'), style: const TextStyle(fontSize: 20)),
                title: Text(c.name),
                trailing: Icon(Icons.add, color: context.ink3),
                onTap: () => _add(context, c),
              ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
