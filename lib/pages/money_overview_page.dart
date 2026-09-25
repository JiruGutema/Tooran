import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/categories_provider.dart';
import '../theme/app_theme.dart';
import '../utils/money_stats.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/person_sheet.dart';
import '../widgets/task_actions.dart';

enum _Show { open, settled, all }

enum _Sort { largest, name, oldest }

/// Full-screen view of a Money list: who owes whom in total, balances per
/// person, money flow over recent months, and a filterable list of people.
class MoneyOverviewPage extends StatefulWidget {
  const MoneyOverviewPage({super.key, required this.categoryId});
  final String categoryId;

  static Future<void> open(BuildContext context, String categoryId) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => MoneyOverviewPage(categoryId: categoryId)));

  @override
  State<MoneyOverviewPage> createState() => _MoneyOverviewPageState();
}

class _MoneyOverviewPageState extends State<MoneyOverviewPage> {
  _Show _show = _Show.open;
  _Sort _sort = _Sort.largest;
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.watch<CategoriesProvider>().byId(widget.categoryId);
    if (c == null) return const Scaffold();
    final loc = intlLocale(context);
    final totals = moneyTotals(c);
    final all = ledgerGroups(c.copyWith(hideCompleted: false));
    final q = _query.text.trim().toLowerCase();
    final people = all
        .where((g) => switch (_show) {
              _Show.open => !g.allSettled,
              _Show.settled => g.allSettled,
              _Show.all => true,
            })
        .where((g) => q.isEmpty || g.person.toLowerCase().contains(q) ||
            g.entries.any((t) => t.description.toLowerCase().contains(q)))
        .toList();
    switch (_sort) {
      case _Sort.largest:
        people.sort((a, b) => b.netMinor.abs().compareTo(a.netMinor.abs()));
      case _Sort.name:
        people.sort((a, b) => a.person.toLowerCase().compareTo(b.person.toLowerCase()));
      case _Sort.oldest:
        people.sort((a, b) => a.earliest.compareTo(b.earliest));
    }
    final chartPeople = all.where((g) => g.netMinor != 0).toList()
      ..sort((a, b) => b.netMinor.abs().compareTo(a.netMinor.abs()));
    final top = chartPeople.take(10).toList();
    final net = totals.netMinor;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => TaskActions.addTask(context, c),
        icon: const Icon(Icons.add, size: 20),
        label: Text(l.ledgerAddEntry),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Row(
              children: [
                IconBtn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.overviewTitle.toUpperCase(), style: AppTheme.eyebrow(context.ink3)),
                      Text(c.emoji == null ? c.name : '${c.emoji} ${c.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.display(size: 26, color: context.ink)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            KpiGrid(
              children: [
                KpiTile(
                  label: l.moneyKpiOwedToYou,
                  value: MoneyText(totals.owedToYouMinor, c.currency,
                      style: AppTheme.display(size: 22, color: context.success)),
                ),
                KpiTile(
                  label: l.moneyKpiYouOwe,
                  value: MoneyText(totals.youOweMinor, c.currency,
                      style: AppTheme.display(size: 22, color: context.warning)),
                ),
                KpiTile(
                  label: l.ledgerNet,
                  value: MoneyText(net.abs(), c.currency,
                      style: AppTheme.display(
                          size: 22,
                          color: net == 0 ? context.ink3 : (net > 0 ? context.success : context.warning))),
                  footnote: net == 0
                      ? l.ledgerAllSquare
                      : (net > 0 ? l.ledgerCaptionOwesYou : l.ledgerCaptionYouOwe),
                ),
                KpiTile(
                  label: l.moneyKpiPeople,
                  value: Text('${totals.people}', style: AppTheme.display(size: 22, color: context.ink)),
                  footnote: totals.oldestOpen == null
                      ? null
                      : l.overviewOldest(fmtDate(context, totals.oldestOpen!,
                          withYear: totals.oldestOpen!.year != DateTime.now().year)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (top.isNotEmpty)
              ChartCard(
                title: l.chartByPerson,
                child: DivergingBars(
                  items: [for (final g in top) (g.person, g.netMinor)],
                  currency: c.currency,
                  onTap: (i) => openPersonSheet(context, c.id, top[i].key),
                ),
              ),
            ChartCard(
              title: l.chartFlow,
              child: FlowChart(
                flows: monthlyFlows(c.tasks, DateTime.now()),
                currency: c.currency,
                monthLabel: (m) => DateFormat.MMM(loc).format(m),
                plusLabel: l.legendPlus,
                minusLabel: l.legendMinus,
              ),
            ),
            SegmentedButton<_Show>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: _Show.open, label: Text(l.filterOpen)),
                ButtonSegment(value: _Show.settled, label: Text(l.filterSettled)),
                ButtonSegment(value: _Show.all, label: Text(l.filterAll)),
              ],
              selected: {_show},
              onSelectionChanged: (s) => setState(() => _show = s.first),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _query,
                    onChanged: (_) => setState(() {}),
                    style: AppTheme.body(size: 15, color: context.ink),
                    decoration: InputDecoration(
                      hintText: l.searchPeople,
                      prefixIcon: Icon(Icons.search, color: context.ink3),
                      suffixIcon: _query.text.isEmpty
                          ? null
                          : IconButton(icon: const Icon(Icons.close), onPressed: () => setState(_query.clear)),
                    ),
                  ),
                ),
                PopupMenuButton<_Sort>(
                  icon: Icon(Icons.sort, color: context.ink2),
                  tooltip: l.categorySort,
                  initialValue: _sort,
                  onSelected: (v) => setState(() => _sort = v),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: _Sort.largest, child: Text(l.sortLargest)),
                    PopupMenuItem(value: _Sort.name, child: Text(l.sortName)),
                    PopupMenuItem(value: _Sort.oldest, child: Text(l.sortOldest)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (people.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(l.noMatches,
                    textAlign: TextAlign.center, style: AppTheme.body(size: 14, color: context.ink3)),
              )
            else
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: AppTheme.card(context.dark),
                child: Column(
                  children: [
                    for (var i = 0; i < people.length; i++)
                      PersonRow(category: c, group: people[i], isLast: i == people.length - 1),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
