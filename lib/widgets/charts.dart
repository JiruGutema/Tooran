import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/money.dart';
import 'common.dart';

/// Short axis numbers: 950, 1.2k, 35k, 1.4M (whole currency units).
String compactAmount(int minor) {
  final v = minor / 100;
  final a = v.abs();
  final sign = v < 0 ? '−' : '';
  if (a >= 1e6) return '$sign${(a / 1e6).toStringAsFixed(a >= 1e7 ? 0 : 1)}M';
  if (a >= 1e3) return '$sign${(a / 1e3).toStringAsFixed(a >= 1e4 ? 0 : 1)}k';
  return '$sign${a.round()}';
}

/// A card that holds one chart: title, optional hint, content.
class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.title, required this.child, this.hint, this.trailing});
  final String title;
  final String? hint;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: AppTheme.card(context.dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: AppTheme.body(size: 15, color: context.ink, weight: FontWeight.w600)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(hint!, style: AppTheme.body(size: 12, color: context.ink3)),
            ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// A headline number with a label and an optional colored footnote.
class KpiTile extends StatelessWidget {
  const KpiTile({super.key, required this.label, required this.value, this.footnote, this.footColor});
  final String label;
  final Widget value;
  final String? footnote;
  final Color? footColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: AppTheme.card(context.dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.eyebrow(context.ink3)),
          const SizedBox(height: 4),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: value),
          if (footnote != null)
            Text(footnote!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.body(size: 11.5, color: footColor ?? context.ink3)),
        ],
      ),
    );
  }
}

/// Headline tiles two per row; each row takes the height of its taller
/// tile, so footnotes and large text never overflow.
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.children, this.spacing = 10});
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) SizedBox(height: spacing),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                SizedBox(width: spacing),
                Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Column chart of one series over time. Tapping a bar selects it; the
/// selected bar keeps the accent color and the rest fade (emphasis).
class TimeBarChart extends StatelessWidget {
  const TimeBarChart({
    super.key,
    required this.buckets,
    required this.currency,
    required this.bottomLabel,
    required this.tooltipLabel,
    this.selected,
    this.onSelect,
    this.height = 180,
  });

  final List<(DateTime, int)> buckets;
  final String currency;

  /// Axis label for bucket i, or '' to skip it.
  final String Function(int i, DateTime start) bottomLabel;
  final String Function(DateTime start) tooltipLabel;
  final int? selected;
  final ValueChanged<int?>? onSelect;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxY = buckets.fold<int>(0, (m, b) => math.max(m, b.$2));
    final top = maxY == 0 ? 100.0 : maxY * 1.15;
    final primary = context.primary;
    final faded = primary.withValues(alpha: 0.35);
    final width = buckets.length > 20 ? 5.0 : (buckets.length > 10 ? 10.0 : 18.0);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: top,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (var i = 0; i < buckets.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: buckets[i].$2.toDouble(),
                  width: width,
                  color: selected == null || selected == i ? primary : faded,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(math.min(4, width / 2))),
                ),
              ]),
          ],
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: top / 4,
            getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.hairline(context.dark), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: top / 4,
                getTitlesWidget: (v, meta) => v == 0 || v >= top
                    ? const SizedBox.shrink()
                    : SideTitleWidget(
                        meta: meta,
                        child: Text(compactAmount(v.round()), style: AppTheme.mono(size: 9.5, color: context.ink3)),
                      ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= buckets.length) return const SizedBox.shrink();
                  final label = bottomLabel(i, buckets[i].$1);
                  return label.isEmpty
                      ? const SizedBox.shrink()
                      : SideTitleWidget(
                          meta: meta,
                          child: Text(label, style: AppTheme.mono(size: 9.5, color: context.ink3)),
                        );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => context.ink,
              tooltipBorderRadius: BorderRadius.circular(AppTheme.rXs),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                '${tooltipLabel(buckets[gi].$1)}\n',
                AppTheme.body(size: 11.5, color: Theme.of(context).colorScheme.surface),
                children: [
                  TextSpan(
                    text: formatMoney(buckets[gi].$2, currency),
                    style: AppTheme.body(
                        size: 13, color: Theme.of(context).colorScheme.surface, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            touchCallback: (event, response) {
              if (onSelect == null || !event.isInterestedForInteractions) return;
              if (event is FlTapUpEvent) {
                final i = response?.spot?.touchedBarGroupIndex;
                onSelect!(i == null || i == selected ? null : i);
              }
            },
          ),
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }
}

/// Horizontal bars ranked by value, one hue. Tap a row to toggle it.
class RankedBars extends StatelessWidget {
  const RankedBars({
    super.key,
    required this.items,
    required this.currency,
    this.selected = const {},
    this.onTap,
  });

  /// (key, label, value) — largest first.
  final List<(String, String, int)> items;
  final String currency;
  final Set<String> selected;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<int>(0, (s, e) => s + e.$3);
    final maxV = items.fold<int>(0, (m, e) => math.max(m, e.$3));
    return Column(
      children: [
        for (final (key, label, value) in items)
          InkWell(
            onTap: onTap == null ? null : () => onTap!(key),
            borderRadius: BorderRadius.circular(AppTheme.rXs),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 108,
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(
                          size: 12.5,
                          color: context.ink,
                          weight: selected.contains(key) ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) => Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 10,
                          width: maxV == 0 ? 0 : math.max(4, box.maxWidth * value / maxV),
                          decoration: BoxDecoration(
                            color: selected.isEmpty || selected.contains(key)
                                ? context.primary
                                : context.primary.withValues(alpha: 0.3),
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 92,
                    child: Text(
                      '${compactAmount(value)} · ${total == 0 ? 0 : (value * 100 / total).round()}%',
                      textAlign: TextAlign.right,
                      style: AppTheme.mono(size: 10.5, color: context.ink2),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Bars around a zero line: positive to the right (in the user's favour),
/// negative to the left. Each row is labeled, so color is never the only cue.
class DivergingBars extends StatelessWidget {
  const DivergingBars({super.key, required this.items, required this.currency, this.onTap});

  /// (label, signed value)
  final List<(String, int)> items;
  final String currency;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final maxAbs = items.fold<int>(0, (m, e) => math.max(m, e.$2.abs()));
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          InkWell(
            onTap: onTap == null ? null : () => onTap!(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 92,
                    child: Text(items[i].$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(size: 12.5, color: context.ink)),
                  ),
                  Expanded(
                    child: LayoutBuilder(builder: (context, box) {
                      final half = box.maxWidth / 2;
                      final v = items[i].$2;
                      final w = maxAbs == 0 ? 0.0 : math.max(3.0, half * v.abs() / maxAbs);
                      final color = v >= 0 ? context.success : context.warning;
                      return SizedBox(
                        height: 12,
                        child: Stack(
                          children: [
                            Positioned(
                              left: half - 0.5,
                              top: -2,
                              bottom: -2,
                              child: Container(width: 1, color: context.ink4),
                            ),
                            Positioned(
                              left: v >= 0 ? half + 1 : half - 1 - w,
                              width: w,
                              top: 1,
                              bottom: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: v >= 0
                                      ? const BorderRadius.horizontal(right: Radius.circular(4))
                                      : const BorderRadius.horizontal(left: Radius.circular(4)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: Text(
                      '${items[i].$2 > 0 ? '+' : ''}${compactAmount(items[i].$2)}',
                      textAlign: TextAlign.right,
                      style: AppTheme.mono(size: 10.5, color: context.ink2),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Two series per month (+ and −), grouped bars with a legend.
class FlowChart extends StatelessWidget {
  const FlowChart({
    super.key,
    required this.flows,
    required this.currency,
    required this.monthLabel,
    required this.plusLabel,
    required this.minusLabel,
  });

  final List<(DateTime, int, int)> flows;
  final String currency;
  final String Function(DateTime) monthLabel;
  final String plusLabel;
  final String minusLabel;

  @override
  Widget build(BuildContext context) {
    final maxY = flows.fold<int>(0, (m, f) => math.max(m, math.max(f.$2, f.$3)));
    final top = maxY == 0 ? 100.0 : maxY * 1.15;
    final plus = context.success;
    final minus = context.warning;
    Widget legend(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            Flexible(child: Text(label, style: AppTheme.body(size: 12, color: context.ink2))),
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 14, runSpacing: 4, children: [legend(plus, plusLabel), legend(minus, minusLabel)]),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: BarChart(
            BarChartData(
              maxY: top,
              minY: 0,
              groupsSpace: 14,
              barGroups: [
                for (var i = 0; i < flows.length; i++)
                  BarChartGroupData(x: i, barsSpace: 2, barRods: [
                    BarChartRodData(
                        toY: flows[i].$2.toDouble(),
                        width: 9,
                        color: plus,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
                    BarChartRodData(
                        toY: flows[i].$3.toDouble(),
                        width: 9,
                        color: minus,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
                  ]),
              ],
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: top / 4,
                getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.hairline(context.dark), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 38,
                    interval: top / 4,
                    getTitlesWidget: (v, meta) => v == 0 || v >= top
                        ? const SizedBox.shrink()
                        : SideTitleWidget(
                            meta: meta,
                            child: Text(compactAmount(v.round()), style: AppTheme.mono(size: 9.5, color: context.ink3)),
                          ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= flows.length) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(monthLabel(flows[i].$1), style: AppTheme.mono(size: 9.5, color: context.ink3)),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => context.ink,
                  tooltipBorderRadius: BorderRadius.circular(AppTheme.rXs),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                    '${monthLabel(flows[gi].$1)} · ${ri == 0 ? plusLabel : minusLabel}\n',
                    AppTheme.body(size: 11, color: Theme.of(context).colorScheme.surface),
                    children: [
                      TextSpan(
                        text: formatMoney(ri == 0 ? flows[gi].$2 : flows[gi].$3, currency),
                        style: AppTheme.body(
                            size: 13, color: Theme.of(context).colorScheme.surface, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A month grid shaded by how much was spent each day (one hue, darker =
/// more). Tap a day to select it.
class SpendCalendar extends StatelessWidget {
  const SpendCalendar({
    super.key,
    required this.month,
    required this.totals,
    required this.weekdayLabels,
    this.selected,
    this.onTap,
  });

  final DateTime month;
  final Map<DateTime, int> totals;

  /// Monday-first short weekday names.
  final List<String> weekdayLabels;
  final DateTime? selected;
  final ValueChanged<DateTime>? onTap;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday - 1;
    final maxV = [
      for (var d = 1; d <= daysInMonth; d++) totals[DateTime(month.year, month.month, d)] ?? 0
    ].fold<int>(0, math.max);
    final today = DateTime.now();
    final cells = lead + daysInMonth;
    final rows = (cells / 7).ceil();

    return Column(
      children: [
        Row(
          children: [
            for (final w in weekdayLabels)
              Expanded(
                child: Center(child: Text(w, style: AppTheme.mono(size: 10, color: context.ink3))),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Builder(builder: (context) {
                      final n = r * 7 + c - lead + 1;
                      if (n < 1 || n > daysInMonth) return const SizedBox.shrink();
                      final day = DateTime(month.year, month.month, n);
                      final v = totals[day] ?? 0;
                      final t = maxV == 0 ? 0.0 : v / maxV;
                      final isSel = selected != null &&
                          selected!.year == day.year &&
                          selected!.month == day.month &&
                          selected!.day == day.day;
                      final isToday =
                          day.year == today.year && day.month == today.month && day.day == today.day;
                      final fill = v == 0 ? Colors.transparent : context.primary.withValues(alpha: 0.12 + 0.7 * t);
                      final dark = t > 0.55;
                      return Padding(
                        padding: const EdgeInsets.all(2),
                        child: Semantics(
                          button: true,
                          selected: isSel,
                          label: '$n: ${v == 0 ? '0' : compactAmount(v)}',
                          child: InkWell(
                            onTap: onTap == null ? null : () => onTap!(day),
                            borderRadius: BorderRadius.circular(AppTheme.rXs),
                            child: Container(
                              decoration: BoxDecoration(
                                color: fill,
                                borderRadius: BorderRadius.circular(AppTheme.rXs),
                                border: Border.all(
                                  color: isSel
                                      ? context.ink
                                      : (isToday ? context.primary : AppTheme.hairline(context.dark)),
                                  width: isSel ? 2 : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$n',
                                      style: AppTheme.body(
                                          size: 12,
                                          color: dark ? Theme.of(context).colorScheme.onPrimary : context.ink,
                                          weight: isToday ? FontWeight.w600 : FontWeight.w400)),
                                  if (v > 0)
                                    FittedBox(
                                      child: Text(compactAmount(v),
                                          style: AppTheme.mono(
                                              size: 8.5,
                                              color: dark
                                                  ? Theme.of(context).colorScheme.onPrimary
                                                  : context.ink2)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
