import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/categories_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';
import '../utils/spending.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/kind_info.dart';
import '../widgets/spending_view.dart';
import '../widgets/task_actions.dart';

/// Full-screen view of a Spending list: pick a period, filter by tag or
/// text, read the totals and charts, browse by calendar, edit expenses.
class SpendingOverviewPage extends StatefulWidget {
  const SpendingOverviewPage({super.key, required this.categoryId});
  final String categoryId;

  static Future<void> open(BuildContext context, String categoryId) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => SpendingOverviewPage(categoryId: categoryId)));

  @override
  State<SpendingOverviewPage> createState() => _SpendingOverviewPageState();
}

class _SpendingOverviewPageState extends State<SpendingOverviewPage> {
  SpendPeriod _period = SpendPeriod.month;
  late SpendRange _range = periodRange(SpendPeriod.month, DateTime.now());
  final Set<String> _tags = {};
  final TextEditingController _query = TextEditingController();

  /// A single day (or month, in Year view) picked on the chart or calendar.
  SpendRange? _drill;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _setPeriod(SpendPeriod p) async {
    if (p == SpendPeriod.custom) {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 10),
        lastDate: DateTime(now.year + 1),
        initialDateRange: DateTimeRange(start: _range.start, end: _range.end.subtract(const Duration(days: 1))),
      );
      if (picked == null) return;
      setState(() {
        _period = p;
        _range = SpendRange(startOfDay(picked.start), startOfDay(picked.end).add(const Duration(days: 1)));
        _drill = null;
      });
      return;
    }
    setState(() {
      _period = p;
      _range = periodRange(p, DateTime.now());
      _drill = null;
    });
  }

  void _step(int delta) => setState(() {
        _range = shiftPeriod(_period, _range, delta);
        _drill = null;
      });

  bool get _hasFilters => _tags.isNotEmpty || _query.text.trim().isNotEmpty || _drill != null;

  String _periodLabel(BuildContext context) {
    final loc = intlLocale(context);
    final lastDay = _range.end.subtract(const Duration(days: 1));
    return switch (_period) {
      SpendPeriod.month => DateFormat.yMMMM(loc).format(_range.start),
      SpendPeriod.year => DateFormat.y(loc).format(_range.start),
      _ => '${fmtDate(context, _range.start)} – ${fmtDate(context, lastDay, withYear: true)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.watch<CategoriesProvider>().byId(widget.categoryId);
    if (c == null) return const Scaffold();
    final now = DateTime.now();
    final loc = intlLocale(context);
    final q = _query.text;

    // What the numbers and charts are about: period + tags + text.
    final inPeriod = filterExpenses(c.tasks, range: _range, tags: _tags, query: q);
    final prev = filterExpenses(c.tasks, range: shiftPeriod(_period, _range, -1), tags: _tags, query: q);
    final total = totalMinor(inPeriod);
    final prevTotal = totalMinor(prev);
    final perDay = total ~/ elapsedDays(_range, now);
    final change = prevTotal == 0 ? null : (total - prevTotal) / prevTotal;
    // The list below: narrowed further by a tapped bar / day.
    final listed = _drill == null ? inPeriod : filterExpenses(inPeriod, range: _drill);
    final buckets = spendingBuckets(inPeriod, _range);
    final daily = _range.days <= 62;
    final byTag = <String, int>{};
    for (final e in filterExpenses(c.tasks, range: _range, query: q)) {
      final t = e.tag ?? 'other';
      byTag[t] = (byTag[t] ?? 0) + (e.amountMinor ?? 0);
    }
    final tagRows = byTag.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final selectedBucket = _drill == null
        ? null
        : buckets.indexWhere((b) => b.$1 == _drill!.start);
    final calendarMonth = _period == SpendPeriod.week || _period == SpendPeriod.month ? _range.start : null;
    final weekdays = [for (var i = 0; i < 7; i++) DateFormat.E(loc).format(DateTime(2024, 1, 1 + i))];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => TaskActions.addTask(context, c),
        icon: const Icon(Icons.add, size: 20),
        label: Text(l.newExpense),
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
                IconBtn(
                  icon: Icons.table_view_outlined,
                  tooltip: l.categoryShareCsv,
                  onTap: () => SharePlus.instance.share(ShareParams(
                    text: spendingCsv(listed, c.currency),
                    subject: '${c.name} · ${_periodLabel(context)}',
                  )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<SpendPeriod>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: SpendPeriod.week, label: Text(l.periodWeek)),
                ButtonSegment(value: SpendPeriod.month, label: Text(l.periodMonth)),
                ButtonSegment(value: SpendPeriod.year, label: Text(l.periodYear)),
                ButtonSegment(value: SpendPeriod.custom, label: Text(l.periodCustom)),
              ],
              selected: {_period},
              onSelectionChanged: (s) => _setPeriod(s.first),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                IconBtn(icon: Icons.chevron_left, onTap: () => _step(-1)),
                Expanded(
                  child: GestureDetector(
                    onTap: _period == SpendPeriod.custom ? () => _setPeriod(SpendPeriod.custom) : null,
                    child: Text(_periodLabel(context),
                        textAlign: TextAlign.center,
                        style: AppTheme.body(size: 15, color: context.ink, weight: FontWeight.w600)),
                  ),
                ),
                IconBtn(icon: Icons.chevron_right, onTap: () => _step(1)),
              ],
            ),
            // Filters sit together above the charts.
            TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              style: AppTheme.body(size: 15, color: context.ink),
              decoration: InputDecoration(
                hintText: l.searchExpenses,
                prefixIcon: Icon(Icons.search, color: context.ink3),
                suffixIcon: q.isEmpty
                    ? null
                    : IconButton(icon: const Icon(Icons.close), onPressed: () => setState(_query.clear)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final tag in spendingTags)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(spendingTagLabel(l, tag)),
                        selected: _tags.contains(tag),
                        showCheckmark: false,
                        onSelected: (v) => setState(() => v ? _tags.add(tag) : _tags.remove(tag)),
                      ),
                    ),
                ],
              ),
            ),
            if (_hasFilters)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _tags.clear();
                    _query.clear();
                    _drill = null;
                  }),
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                  label: Text(l.clearFilters),
                ),
              ),
            const SizedBox(height: 10),
            KpiGrid(
              children: [
                KpiTile(
                  label: l.kpiTotal,
                  value: MoneyText(total, c.currency, style: AppTheme.display(size: 22, color: context.ink)),
                ),
                KpiTile(
                  label: l.kpiDailyAvg,
                  value: MoneyText(perDay, c.currency, style: AppTheme.display(size: 22, color: context.ink)),
                ),
                KpiTile(
                  label: l.kpiCount,
                  value: Text('${inPeriod.length}', style: AppTheme.display(size: 22, color: context.ink)),
                ),
                KpiTile(
                  label: l.kpiVsPrev,
                  value: Text(
                    change == null ? '—' : '${change >= 0 ? '+' : '−'}${(change.abs() * 100).round()}%',
                    style: AppTheme.display(
                      size: 22,
                      color: change == null ? context.ink3 : (change > 0 ? context.warning : context.success),
                    ),
                  ),
                  footnote: prevTotal == 0 ? null : formatAmountFor(context, prevTotal, c.currency),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_period == SpendPeriod.month && (c.targetMinor ?? 0) > 0) ...[
              _BudgetMeter(
                spent: totalMinor(filterExpenses(c.tasks, range: _range)),
                budget: c.targetMinor!,
                currency: c.currency,
              ),
              const SizedBox(height: 14),
            ],
            ChartCard(
              title: l.chartOverTime,
              hint: l.chartTapHint,
              child: TimeBarChart(
                buckets: buckets,
                currency: c.currency,
                selected: selectedBucket == -1 ? null : selectedBucket,
                bottomLabel: (i, d) {
                  if (!daily) return DateFormat.MMM(loc).format(d).substring(0, 1);
                  final step = (buckets.length / 7).ceil();
                  return i % step == 0 ? '${d.day}' : '';
                },
                tooltipLabel: (d) => daily ? fmtDate(context, d) : DateFormat.yMMM(loc).format(d),
                onSelect: (i) => setState(() {
                  if (i == null) {
                    _drill = null;
                  } else {
                    final s = buckets[i].$1;
                    _drill = SpendRange(s, daily ? DateTime(s.year, s.month, s.day + 1) : DateTime(s.year, s.month + 1));
                  }
                }),
              ),
            ),
            if (tagRows.isNotEmpty)
              ChartCard(
                title: l.chartByTag,
                child: RankedBars(
                  items: [for (final e in tagRows) (e.key, spendingTagLabel(l, e.key), e.value)],
                  currency: c.currency,
                  selected: _tags,
                  onTap: (tag) => setState(() => _tags.contains(tag) ? _tags.remove(tag) : _tags.add(tag)),
                ),
              ),
            if (calendarMonth != null)
              ChartCard(
                title: l.calendarTitle,
                trailing: Text(DateFormat.yMMMM(loc).format(calendarMonth),
                    style: AppTheme.body(size: 12.5, color: context.ink3)),
                child: SpendCalendar(
                  month: calendarMonth,
                  totals: dailyTotals(filterExpenses(c.tasks, tags: _tags, query: q)),
                  weekdayLabels: weekdays,
                  selected: _drill != null && _drill!.days == 1 ? _drill!.start : null,
                  onTap: (day) => setState(() {
                    final r = SpendRange(day, day.add(const Duration(days: 1)));
                    _drill = _drill == r ? null : r;
                  }),
                ),
              ),
            if (_drill != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    label: Text(_drill!.days == 1
                        ? fmtDate(context, _drill!.start, withYear: true)
                        : DateFormat.yMMM(loc).format(_drill!.start)),
                    onDeleted: () => setState(() => _drill = null),
                  ),
                ),
              ),
            if (listed.isEmpty)
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (day, entries, dayTotal) in spendingByDay(listed)) ...[
                      Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        padding: const EdgeInsets.fromLTRB(16, 7, 16, 7),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                isSameDay(day, now)
                                    ? l.dueToday
                                    : fmtDate(context, day, withYear: day.year != now.year),
                                style: AppTheme.eyebrow(context.ink3),
                              ),
                            ),
                            MoneyText(dayTotal, c.currency, style: AppTheme.mono(size: 11.5, color: context.ink2)),
                          ],
                        ),
                      ),
                      for (final e in entries) ExpenseRow(category: c, entry: e, pad: 16),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BudgetMeter extends StatelessWidget {
  const _BudgetMeter({required this.spent, required this.budget, required this.currency});
  final int spent;
  final int budget;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ratio = spent / budget;
    final color = ratio > 1 ? context.danger : (ratio >= 0.8 ? context.warning : context.primary);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: AppTheme.card(context.dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.overviewBudget, style: AppTheme.eyebrow(context.ink3))),
              Text('${(ratio * 100).round()}%', style: AppTheme.mono(size: 12, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              color: color,
              backgroundColor: context.ink4.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ratio > 1
                ? l.spendBudgetOver(formatAmountFor(context, spent - budget, currency))
                : l.spendBudgetLeft(
                    formatAmountFor(context, budget - spent, currency), formatAmountFor(context, budget, currency)),
            style: AppTheme.body(size: 12.5, color: ratio > 1 ? context.danger : context.ink3),
          ),
        ],
      ),
    );
  }
}
