import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/categories_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/ledger_parse.dart';
import '../utils/money.dart';
import 'common.dart';

/// Turns an existing to-do category (e.g. "Take back" with tasks like
/// "Abebe – 500") into a ledger, with a preview of how each task is read.
class ConvertLedgerSheet extends StatefulWidget {
  const ConvertLedgerSheet({super.key, required this.category});
  final Category category;

  @override
  State<ConvertLedgerSheet> createState() => _ConvertLedgerSheetState();
}

class _ConvertLedgerSheetState extends State<ConvertLedgerSheet> {
  late final TextEditingController _currency =
      TextEditingController(text: context.read<SettingsProvider>().defaultCurrency);

  @override
  void dispose() {
    _currency.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final parsed = {
      for (final t in widget.category.tasks) t.id: parseLedgerName(t.name),
    };
    final currency = _currency.text.trim().isEmpty ? 'ETB' : _currency.text.trim().toUpperCase();

    return SheetShell(
      eyebrow: l.convertTitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.convertBody, style: AppTheme.body(size: 14, color: context.ink2)),
            const SizedBox(height: 16),
            SizedBox(
              width: 140,
              child: TextField(
                controller: _currency,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: l.categoryCurrencyLabel),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),
            for (final t in widget.category.tasks)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.hairline(context.dark))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name,
                              style: AppTheme.body(size: 12, color: context.ink3),
                              overflow: TextOverflow.ellipsis),
                          Text(
                            parsed[t.id]!.person.isEmpty ? t.name : parsed[t.id]!.person,
                            style: AppTheme.body(size: 15, color: context.ink, weight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      parsed[t.id]!.amountMinor == null
                          ? l.convertNoAmount
                          : formatMoney(parsed[t.id]!.amountMinor!, currency),
                      style: AppTheme.mono(
                        size: 12,
                        color: parsed[t.id]!.amountMinor == null ? context.warning : context.ink2,
                      ),
                    ),
                  ],
                ),
              ),
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
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await context.read<CategoriesProvider>().convertToLedger(
                        widget.category.id,
                        CategoryKind.money,
                        currency,
                        {
                          for (final e in parsed.entries)
                            e.key: (
                              person: e.value.person.isEmpty
                                  ? widget.category.tasks.firstWhere((t) => t.id == e.key).name
                                  : e.value.person,
                              amountMinor: e.value.amountMinor,
                            ),
                        },
                      );
                      nav.pop();
                    },
                    child: Text(l.commonApply),
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
