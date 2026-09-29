import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../providers/categories_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';
import '../utils/ethiopian_calendar.dart';
import '../utils/rich_text.dart';
import '../utils/spending.dart';
import 'charts.dart';
import 'common.dart';
import 'kind_info.dart';
import '../pages/spending_overview_page.dart';
import 'task_actions.dart';

/// The body of a Spending list: totals, budget, a breakdown by tag, and
/// expenses either grouped by day (newest first) or on a month calendar.
class SpendingView extends StatefulWidget {
  const SpendingView(
      {super.key, required this.category, this.onOpen, this.padding = 18});

  final Category category;

  /// Desktop selects instead of opening the details sheet.
  final void Function(Task task)? onOpen;
  final double padding;

  @override
  State<SpendingView> createState() => _SpendingViewState();
}

class _SpendingViewState extends State<SpendingView> {
  static const _daysShown = 7;
  bool _showAll = false;

  /// Month shown in calendar mode; null for the current one.
  CalMonth? _month;

  /// Day picked on the calendar, whose expenses are listed below it.
  DateTime? _day = startOfDay(DateTime.now());

  void _setCalendar(bool on) => context
      .read<CategoriesProvider>()
      .updateCategory(widget.category.copyWith(spendingCalendar: on));

  @override
  Widget build(BuildContext context) {
    final c = widget.category;
    final l = context.l10n;
    final now = DateTime.now();
    final st = spendingStats(c.tasks, now);
    final days = spendingByDay(c.tasks);
    final pad = widget.padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => SpendingOverviewPage.open(context, c.id),
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 14, pad, 4),
            child: Row(
              children: [
                _Stat(
                    label: l.spendToday,
                    minor: st.todayMinor,
                    currency: c.currency),
                _Stat(
                    label: l.spendWeek,
                    minor: st.weekMinor,
                    currency: c.currency),
                _Stat(
                  label: l.spendMonth,
                  minor: st.monthMinor,
                  currency: c.currency,
                  footnote: st.vsLastMonth == null
                      ? null
                      : l.spendVsLastMonth(
                          '${st.vsLastMonth! >= 0 ? '+' : '−'}${(st.vsLastMonth!.abs() * 100).round()}%'),
                  footColor: st.vsLastMonth == null
                      ? null
                      : (st.vsLastMonth! > 0
                          ? context.warning
                          : context.success),
                ),
              ],
            ),
          ),
        ),
        if ((c.targetMinor ?? 0) > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 10, pad, 0),
            child: _BudgetBar(
                spent: st.monthMinor,
                budget: c.targetMinor!,
                currency: c.currency),
          ),
        if (st.byTag.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 12, pad, 6),
            child: Column(
              children: [
                for (final e in st.byTag.take(5))
                  _TagBar(
                    label: spendingTagLabel(l, e.key),
                    minor: e.value,
                    fraction: st.monthMinor == 0 ? 0 : e.value / st.monthMinor,
                    currency: c.currency,
                  ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        if (days.isEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(pad + 38, 12, pad, 14),
            child: Text(l.spendingNoEntries,
                style: AppTheme.body(size: 13, color: context.ink3)),
          )
        else ...[
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 4, pad, 10),
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: [
                ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.view_agenda_outlined, size: 16),
                    label: Text(l.spendViewList)),
                ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.calendar_month_outlined, size: 16),
                    label: Text(l.calendarTitle)),
              ],
              selected: {c.spendingCalendar},
              onSelectionChanged: (v) => _setCalendar(v.first),
            ),
          ),
          if (c.spendingCalendar)
            ..._calendar(context, days, now)
          else
            ..._list(context, days, now),
        ],
      ],
    );
  }

  /// Expenses grouped by day, the latest [_daysShown] days unless expanded.
  List<Widget> _list(BuildContext context,
      List<(DateTime, List<Task>, int)> days, DateTime now) {
    final l = context.l10n;
    final shown = _showAll ? days : days.take(_daysShown).toList();
    return [
      for (final (day, entries, total) in shown) ...[
        _dayHeader(context, day, total, now),
        for (final e in entries)
          ExpenseRow(
              category: widget.category,
              entry: e,
              pad: widget.padding,
              onOpen: widget.onOpen),
      ],
      if (days.length > _daysShown)
        TextButton(
          onPressed: () => setState(() => _showAll = !_showAll),
          child: Text(_showAll
              ? l.commonShowLess
              : l.listShowMore(days.length - _daysShown)),
        ),
    ];
  }

  /// A month grid shaded by daily totals; the picked day's expenses below.
  List<Widget> _calendar(BuildContext context,
      List<(DateTime, List<Task>, int)> days, DateTime now) {
    final l = context.l10n;
    final c = widget.category;
    final pad = widget.padding;
    final ethiopian = context.watch<SettingsProvider>().ethiopianCalendar;
    final thisMonth = CalMonth.of(now, ethiopian: ethiopian);
    // Flipping the calendar setting starts over at the current month.
    final month = _month?.ethiopian == ethiopian ? _month! : thisMonth;
    final day = _day != null && month.contains(_day!) ? _day : null;
    final picked = day == null
        ? null
        : days.where((d) => isSameDay(d.$1, day)).firstOrNull;
    final loc = intlLocale(context);
    final weekdays = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(loc).format(DateTime(2024, 1, 1 + i))
    ];
    void step(int delta) => setState(() {
          _month = month.shift(delta);
          _day = null;
        });

    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: pad - 12),
        child: Row(
          children: [
            IconBtn(icon: Icons.chevron_left, onTap: () => step(-1)),
            Expanded(
              child: Text(fmtMonth(context, month),
                  textAlign: TextAlign.center,
                  style: AppTheme.body(
                      size: 15, color: context.ink, weight: FontWeight.w600)),
            ),
            IconBtn(icon: Icons.chevron_right, onTap: () => step(1)),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(pad, 4, pad, 12),
        child: SpendCalendar(
          month: month,
          totals: dailyTotals(c.tasks),
          weekdayLabels: weekdays,
          selected: day,
          onTap: (d) => setState(
              () => _day = day != null && isSameDay(d, day) ? null : d),
        ),
      ),
      if (day == null)
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, 14),
          child: Text(l.spendTapDay,
              textAlign: TextAlign.center,
              style: AppTheme.body(size: 13, color: context.ink3)),
        )
      else ...[
        _dayHeader(context, day, picked?.$3 ?? 0, now),
        if (picked == null)
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 12, pad, 14),
            child: Text(l.spendDayEmpty,
                style: AppTheme.body(size: 13, color: context.ink3)),
          )
        else
          for (final e in picked.$2)
            ExpenseRow(
                category: c, entry: e, pad: pad, onOpen: widget.onOpen),
      ],
    ];
  }

  Widget _dayHeader(BuildContext context, DateTime day, int total, DateTime now) {
    final l = context.l10n;
    final pad = widget.padding;
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.6),
      padding: EdgeInsets.fromLTRB(pad, 7, pad, 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isSameDay(day, now)
                  ? l.dueToday
                  : isSameDay(day, now.subtract(const Duration(days: 1)))
                      ? l.spendYesterday
                      : fmtDate(context, day, withYear: day.year != now.year),
              style: AppTheme.eyebrow(context.ink3),
            ),
          ),
          MoneyText(total, widget.category.currency,
              style: AppTheme.mono(size: 11.5, color: context.ink2)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
      {required this.label,
      required this.minor,
      required this.currency,
      this.footnote,
      this.footColor});
  final String label;
  final int minor;
  final String currency;
  final String? footnote;
  final Color? footColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.eyebrow(context.ink3)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: MoneyText(minor, currency,
                style: AppTheme.display(size: 19, color: context.ink)),
          ),
          if (footnote != null)
            Text(footnote!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    AppTheme.body(size: 11, color: footColor ?? context.ink3)),
        ],
      ),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  const _BudgetBar(
      {required this.spent, required this.budget, required this.currency});
  final int spent;
  final int budget;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ratio = spent / budget;
    final color = ratio > 1
        ? context.danger
        : (ratio >= 0.8 ? context.warning : context.primary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: ratio.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 7,
              color: color,
              backgroundColor: context.ink4.withValues(alpha: 0.35),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ratio > 1
              ? l.spendBudgetOver(
                  formatAmountFor(context, spent - budget, currency))
              : l.spendBudgetLeft(
                  formatAmountFor(context, budget - spent, currency),
                  formatAmountFor(context, budget, currency)),
          style: AppTheme.body(
              size: 12, color: ratio > 1 ? context.danger : context.ink3),
        ),
      ],
    );
  }
}

class _TagBar extends StatelessWidget {
  const _TagBar(
      {required this.label,
      required this.minor,
      required this.fraction,
      required this.currency});
  final String label;
  final int minor;
  final double fraction;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.body(size: 12.5, color: context.ink2)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                color: context.primary.withValues(alpha: 0.75),
                backgroundColor: context.ink4.withValues(alpha: 0.25),
              ),
            ),
          ),
          const SizedBox(width: 8),
          MoneyText(minor, currency,
              style: AppTheme.mono(size: 11, color: context.ink3)),
        ],
      ),
    );
  }
}

/// One expense row: tag badge, what-for, note, amount. Swipe to edit/delete.
class ExpenseRow extends StatelessWidget {
  const ExpenseRow(
      {super.key,
      required this.category,
      required this.entry,
      required this.pad,
      this.onOpen});
  final Category category;
  final Task entry;
  final double pad;
  final void Function(Task task)? onOpen;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = category;
    final e = entry;
    final note = flattenForPreview(e.description);
    final tagName = spendingTagName(l, e.tag);
    final subtitle = [
      if (e.name != tagName) tagName,
      if (note.isNotEmpty) note,
    ].join(' · ');

    return Dismissible(
      key: ValueKey('expense_${e.id}'),
      background: Container(
        color: context.ink2.withValues(alpha: 0.10),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: pad),
        child: Icon(Icons.edit_outlined, size: 18, color: context.ink3),
      ),
      secondaryBackground: Container(
        color: context.danger.withValues(alpha: 0.10),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: pad),
        child: Icon(Icons.delete_outline, size: 18, color: context.danger),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          TaskActions.edit(context, c, e);
          return false;
        }
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) => TaskActions.delete(context, c, e),
      child: InkWell(
        onTap: () => onOpen != null
            ? onOpen!(e)
            : TaskActions.openDetails(context, c.id, e.id),
        child: Container(
          padding: EdgeInsets.fromLTRB(pad - 6, 8, pad, 8),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: AppTheme.hairline(context.dark))),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppTheme.rSm),
                ),
                child: Text(spendingTagEmoji[e.tag ?? 'other'] ?? '•',
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(size: 15, color: context.ink)),
                    if (subtitle.isNotEmpty)
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.body(size: 12, color: context.ink3)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MoneyText(e.amountMinor ?? 0, c.currency,
                  style: AppTheme.mono(size: 13, color: context.ink)),
            ],
          ),
        ),
      ),
    );
  }
}
