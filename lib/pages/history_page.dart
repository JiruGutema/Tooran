import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/deleted_category.dart';
import '../providers/categories_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _restore(BuildContext context, DeletedCategory dc) async {
    await context.read<CategoriesProvider>().restoreDeletedCategory(dc.id);
    if (context.mounted) showToast(context, context.l10n.historyRestored(dc.name));
  }

  Future<void> _purge(BuildContext context, DeletedCategory dc) async {
    final l = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l.historyDeleteForeverTitle,
      body: l.historyDeleteForeverBody(dc.name),
      confirmLabel: l.commonDelete,
    );
    if (!ok || !context.mounted) return;
    await context.read<CategoriesProvider>().permanentlyDelete(dc.id);
    if (context.mounted) showToast(context, l.historyPurged(dc.name));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = context.watch<CategoriesProvider>();
    final deleted = provider.deletedCategories.reversed.toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 14, 0),
                child: Row(
                  children: [
                    IconBtn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                    Text(l.historyTitle, style: AppTheme.eyebrow(context.ink3)),
                    const Spacer(),
                    if (deleted.length > 1)
                      TextButton(
                        onPressed: () async {
                          final ok = await confirmDialog(
                            context,
                            title: l.historyClearAll,
                            body: l.historyClearAllBody,
                            confirmLabel: l.commonDelete,
                          );
                          if (ok && context.mounted) await provider.clearHistory();
                        },
                        child: Text(l.historyClearAll, style: TextStyle(color: context.danger)),
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            if (deleted.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.rLg),
                            border: Border.all(color: AppTheme.hairlineStrong(context.dark), width: 1.5),
                          ),
                          child: Icon(Icons.inbox_outlined, color: context.ink3, size: 24),
                        ),
                        const SizedBox(height: 16),
                        Text(l.historyEmptyTitle, style: AppTheme.display(size: 24, color: context.ink)),
                        const SizedBox(height: 6),
                        Text(
                          l.historyEmptyBody,
                          textAlign: TextAlign.center,
                          style: AppTheme.body(size: 14, color: context.ink3),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                sliver: SliverList.builder(
                  itemCount: deleted.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DeletedCard(
                      dc: deleted[i],
                      onRestore: () => _restore(context, deleted[i]),
                      onPurge: () => _purge(context, deleted[i]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeletedCard extends StatelessWidget {
  const _DeletedCard({required this.dc, required this.onRestore, required this.onPurge});
  final DeletedCategory dc;
  final VoidCallback onRestore;
  final VoidCallback onPurge;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final done = dc.tasks.where((t) => t.isCompleted).length;
    final emoji = dc.extras['emoji'] as String?;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: AppTheme.card(context.dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(emoji == null ? dc.name : '$emoji ${dc.name}',
                    style: AppTheme.display(size: 22, color: context.ink)),
              ),
              const SizedBox(width: 8),
              Text(l.historyDeletedOn(fmtDate(context, dc.deletedAt)),
                  style: AppTheme.mono(size: 11, color: context.ink3)),
            ],
          ),
          const SizedBox(height: 4),
          Text(l.historyTaskCount(dc.tasks.length, done), style: AppTheme.body(size: 13, color: context.ink3)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(onPressed: onRestore, child: Text(l.commonRestore)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onPurge,
                    style: OutlinedButton.styleFrom(foregroundColor: context.danger),
                    child: Text(l.historyDeleteForever),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
