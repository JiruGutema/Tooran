import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../providers/categories_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/money.dart';
import '../utils/rich_text.dart';
import 'common.dart';
import 'ledger_groups.dart';
import 'task_actions.dart';

PersonGroup? _findGroup(Category c, String key) {
  // Look at every entry (ignore "hide completed") so the sheet shows all.
  final all = ledgerGroups(c.copyWith(hideCompleted: false));
  for (final g in all) {
    if (g.key == key) return g;
  }
  return null;
}

/// Opens the person's entries, like a task's details.
Future<void> openPersonSheet(
    BuildContext context, String categoryId, String key) {
  if (MediaQuery.sizeOf(context).width >= 900) {
    return openSheet(
      context,
      SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.8,
          child: PersonSheet(categoryId: categoryId, personKey: key)),
    );
  }
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, sc) => PersonSheet(
          categoryId: categoryId, personKey: key, scrollController: sc),
    ),
  );
}

/// "owes you" / "you owe" / "all square" for a person's signed net.
String _direction(AppLocalizations l, Category c, int net) {
  if (net == 0) return l.ledgerAllSquare;
  return net > 0 ? l.ledgerCaptionOwesYou : l.ledgerCaptionYouOwe;
}

/// One row per person in a ledger category, styled like a task row.
class PersonRow extends StatelessWidget {
  const PersonRow({
    super.key,
    required this.category,
    required this.group,
    required this.isLast,
    this.highlighted = false,
    this.onBeforeToggle,
  });

  final Category category;
  final PersonGroup group;
  final bool isLast;
  final bool highlighted;

  /// Lets the list hold its order while the tick animation plays.
  final VoidCallback? onBeforeToggle;

  Future<void> _toggle(BuildContext context) async {
    onBeforeToggle?.call();
    final provider = context.read<CategoriesProvider>();
    final l = context.l10n;
    final before = await provider.togglePerson(category.id, group.key);
    if (before.isEmpty || !context.mounted) return;
    showToast(context, group.allSettled ? l.taskReopened : l.ledgerSettledToast,
        onUndo: () => provider.restoreSnapshots(category.id, before));
  }

  Future<void> _delete(BuildContext context) async {
    final provider = context.read<CategoriesProvider>();
    final l = context.l10n;
    final removed = await provider.deletePerson(category.id, group.key);
    if (removed.isEmpty || !context.mounted) return;
    showToast(context, l.taskDeleted,
        onUndo: () => provider.restoreCleared(category.id, removed));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = category;
    final g = group;
    final settled = g.allSettled;
    final completeOnSwipe = context.watch<SettingsProvider>().swipeRight ==
        SwipeRightAction.complete;
    final latest = g.entries.first;
    final note = flattenForPreview(latest.description);
    final days = DateTime.now().difference(latest.createdAt).inDays;
    final subtitle = [
      if (g.entries.length > 1) l.peopleEntries(g.entries.length),
      if (note.isNotEmpty) note,
      l.ledgerDaysAgo(days),
    ].join(' · ');
    final nextDue = g.nextDue;

    return Dismissible(
      key: ValueKey('person_${c.id}_${g.key}'),
      background: Container(
        color: (completeOnSwipe ? context.success : context.ink2)
            .withValues(alpha: 0.12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 22),
        child: Icon(
            completeOnSwipe
                ? (settled ? Icons.undo : Icons.check)
                : Icons.open_in_new,
            size: 18,
            color: completeOnSwipe ? context.success : context.ink3),
      ),
      secondaryBackground: Container(
        color: context.danger.withValues(alpha: 0.10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        child: Icon(Icons.delete_outline, size: 18, color: context.danger),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          if (completeOnSwipe) {
            _toggle(context);
          } else {
            openPersonSheet(context, c.id, g.key);
          }
          return false;
        }
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) => _delete(context),
      child: InkWell(
        onTap: () => openPersonSheet(context, c.id, g.key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          color: highlighted
              ? context.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 4, 18, 4),
              constraints: const BoxConstraints(minHeight: 56),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom:
                            BorderSide(color: AppTheme.hairline(context.dark))),
              ),
              child: Row(
                children: [
                  AppCheckbox(
                      checked: settled,
                      label: g.person,
                      onTap: () => _toggle(context)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StrikeText(
                            text: g.person,
                            done: settled,
                            maxLines: 1,
                            style: AppTheme.body(
                                size: 16,
                                color: settled ? context.ink3 : context.ink),
                          ),
                          const SizedBox(height: 3),
                          Text(subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.body(
                                  size: 12.5, color: context.ink3)),
                          if (nextDue != null && !settled)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Chip2(
                                icon: Icons.event_outlined,
                                label: fmtDate(context, nextDue),
                                color: nextDue.isBefore(DateTime.now())
                                    ? context.danger
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MoneyText(
                        settled ? 0 : g.netMinor.abs(),
                        c.currency,
                        style: AppTheme.mono(
                            size: 13,
                            color: settled
                                ? context.ink3
                                : ledgerAmountColor(context, c, g.netMinor)),
                      ),
                      Text(
                        _direction(l, c, settled ? 0 : g.netMinor),
                        style: AppTheme.body(size: 11, color: context.ink3),
                      ),
                      // + and − are tracked separately; show both when both exist.
                      if (!settled && g.plusMinor > 0 && g.minusMinor > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MoneyText(g.plusMinor, '',
                                  showPlus: true,
                                  style: AppTheme.mono(
                                      size: 10.5,
                                      color: ledgerAmountColor(context, c, 1))),
                              const SizedBox(width: 6),
                              MoneyText(-g.minusMinor, '',
                                  style: AppTheme.mono(
                                      size: 10.5,
                                      color:
                                          ledgerAmountColor(context, c, -1))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A person's page: totals, every entry (each with its own amount, note and
/// payments), and a button to add another entry for them.
class PersonSheet extends StatelessWidget {
  const PersonSheet(
      {super.key,
      required this.categoryId,
      required this.personKey,
      this.scrollController});

  final String categoryId;
  final String personKey;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = context.watch<CategoriesProvider>();
    final c = provider.byId(categoryId);
    final g = c == null ? null : _findGroup(c, personKey);
    if (c == null || g == null) return const SizedBox.shrink();
    // Actions that close the sheet first continue from the navigator's context.
    final host = Navigator.of(context).context;

    void addEntry() {
      Navigator.of(context).pop();
      TaskActions.addTask(host, c, initialName: g.person);
    }

    Widget total(String label, int minor, Color color, {bool plus = false}) =>
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.eyebrow(context.ink3)),
              const SizedBox(height: 4),
              MoneyText(minor, c.currency,
                  showPlus: plus,
                  style: AppTheme.display(size: 20, color: color)),
            ],
          ),
        );

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SheetGrabber(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 10, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    c.emoji == null ? c.name : '${c.emoji} ${c.name}',
                    style: AppTheme.eyebrow(context.ink3),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconBtn(
                  icon: Icons.ios_share,
                  tooltip: l.commonShare,
                  onTap: () => SharePlus.instance.share(ShareParams(
                    text: [
                      '${g.person}: ${formatMoney(g.netMinor, c.currency, showPlus: true)}',
                      for (final t in g.entries)
                        '  ${t.isCompleted ? '☑' : '☐'} ${formatMoney(t.amountMinor ?? 0, c.currency, showPlus: true)}'
                            '${flattenForPreview(t.description).isEmpty ? '' : ' — ${flattenForPreview(t.description)}'}',
                    ].join('\n'),
                  )),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
              children: [
                Text(g.person,
                    style: AppTheme.display(size: 30, color: context.ink)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.ledgerNet,
                              style: AppTheme.eyebrow(context.ink3)),
                          const SizedBox(height: 4),
                          MoneyText(g.netMinor.abs(), c.currency,
                              style: AppTheme.display(
                                  size: 20,
                                  color: ledgerAmountColor(
                                      context, c, g.netMinor))),
                          Text(_direction(l, c, g.netMinor),
                              style: AppTheme.body(
                                  size: 11.5, color: context.ink3)),
                        ],
                      ),
                    ),
                    total(l.ledgerPlusTotal, g.plusMinor,
                        ledgerAmountColor(context, c, 1),
                        plus: true),
                    total(l.ledgerMinusTotal, -g.minusMinor,
                        ledgerAmountColor(context, c, -1)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: addEntry,
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(l.ledgerAddEntry),
                      ),
                    ),
                    if (g.netMinor > 0) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => SharePlus.instance.share(ShareParams(
                            text: l.ledgerRemindMessage(
                              g.person,
                              formatMoney(g.netMinor.abs(), c.currency),
                              fmtDate(context, g.earliest,
                                  withYear:
                                      g.earliest.year != DateTime.now().year),
                            ),
                          )),
                          icon: const Icon(Icons.notifications_active_outlined,
                              size: 16),
                          label: Text(l.ledgerRemind),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 22),
                Text(l.peopleEntries(g.entries.length).toUpperCase(),
                    style: AppTheme.eyebrow(context.ink3)),
                const SizedBox(height: 4),
                for (var i = 0; i < g.entries.length; i++)
                  _EntryTile(
                      category: c,
                      entry: g.entries[i],
                      isLast: i == g.entries.length - 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One money entry inside a person's page.
class _EntryTile extends StatelessWidget {
  const _EntryTile(
      {required this.category, required this.entry, required this.isLast});
  final Category category;
  final Task entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = category;
    final t = entry;
    final note = flattenForPreview(t.description);
    final date = fmtDate(context, t.createdAt,
        withYear: t.createdAt.year != DateTime.now().year);
    final meta = <String>[
      if (note.isNotEmpty) date,
      if (t.paidMinor > 0 && !t.isCompleted)
        l.ledgerPaidLeft(
            formatMinor(t.paidMinor), formatMinor(t.remainingMinor.abs())),
    ].join(' · ');

    return Dismissible(
      key: ValueKey('entry_${t.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 12),
        color: context.danger.withValues(alpha: 0.10),
        child: Icon(Icons.delete_outline, size: 18, color: context.danger),
      ),
      onDismissed: (_) => TaskActions.delete(context, c, t),
      child: InkWell(
        onTap: () => TaskActions.openDetails(context, c.id, t.id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(color: AppTheme.hairline(context.dark))),
          ),
          child: Row(
            children: [
              AppCheckbox(
                checked: t.isCompleted,
                label: note.isEmpty ? date : note,
                onTap: () => TaskActions.toggle(context, c, t),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StrikeText(
                      text: note.isEmpty ? l.ledgerEntryOn(date) : note,
                      done: t.isCompleted,
                      maxLines: 1,
                      style: AppTheme.body(
                          size: 15,
                          color: t.isCompleted ? context.ink3 : context.ink),
                    ),
                    if (meta.isNotEmpty)
                      Text(meta,
                          style: AppTheme.body(size: 12, color: context.ink3)),
                  ],
                ),
              ),
              MoneyText(
                t.isCompleted ? (t.amountMinor ?? 0) : t.remainingMinor,
                c.currency,
                showPlus: true,
                style: AppTheme.mono(
                  size: 13,
                  color: t.isCompleted
                      ? context.ink3
                      : ledgerAmountColor(context, c, t.remainingMinor),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: context.ink4),
            ],
          ),
        ),
      ),
    );
  }
}
