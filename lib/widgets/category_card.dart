import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../providers/categories_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/money.dart';
import '../utils/spending.dart';
import '../utils/rich_text.dart';
import 'cat_ring.dart';
import 'common.dart';
import 'convert_ledger_sheet.dart';
import 'kind_info.dart';
import 'ledger_groups.dart';
import 'merge_ledgers_sheet.dart';
import 'person_sheet.dart';
import 'spending_view.dart';
import '../pages/money_overview_page.dart';
import '../pages/spending_overview_page.dart';
import 'task_actions.dart';

/// Expandable category card on the mobile home screen.
class CategoryCard extends StatefulWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.expanded,
    required this.onToggleExpanded,
    this.highlightTaskId,
  });

  final Category category;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  /// Briefly highlighted row (after opening a search result or widget link).
  final String? highlightTaskId;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  /// While set, rows keep this order so a just-completed task finishes its
  /// strike-through before sliding to the bottom.
  List<String>? _frozenOrder;
  List<String>? _frozenPeople;
  Timer? _unfreeze;

  /// Rows a long list shows until "Show all" is tapped.
  static const _cap = 8;
  bool _showAll = false;

  /// Task ids seen at the last update, to spot newly added ones.
  Set<String> _knownIds = {};

  @override
  void initState() {
    super.initState();
    _knownIds = {for (final t in widget.category.tasks) t.id};
    if (_isCut(widget.highlightTaskId)) _showAll = true;
  }

  @override
  void didUpdateWidget(covariant CategoryCard old) {
    super.didUpdateWidget(old);
    // Collapsing the card also shortens its list again.
    if (!widget.expanded) _showAll = false;
    // Categories are updated in place, so compare ids rather than widgets:
    // a just-added entry, or one opened from search, must not be cut off.
    final ids = {for (final t in widget.category.tasks) t.id};
    if (widget.expanded && ids.difference(_knownIds).any(_isCut) ||
        (widget.highlightTaskId != old.highlightTaskId &&
            _isCut(widget.highlightTaskId))) {
      _showAll = true;
    }
    _knownIds = ids;
  }

  /// Savings in stored order are oldest first; the card keeps the newest.
  bool _keepsLast(Category c) =>
      c.kind == CategoryKind.savings &&
      (c.ledgerSort == LedgerSort.manual || c.ledgerSort == LedgerSort.oldest);

  /// Whether [c] has more rows than a card shows at once. Lists only a
  /// couple of rows over the cap are always shown whole.
  bool _isLong(Category c) =>
      !c.isSpending &&
      (c.isLedger ? _peopleRows(c).length : _rows(c).length) > _cap + 2;

  /// The part of [all] a card shows, and how many rows it leaves out.
  (List<T>, int) _limit<T>(Category c, List<T> all) {
    if (_showAll || !_isLong(c)) return (all, 0);
    final cut = all.length - _cap;
    return _keepsLast(c)
        ? (all.sublist(cut), cut)
        : (all.sublist(0, _cap), cut);
  }

  /// Whether task [id] is in a row the card is currently leaving out.
  bool _isCut(String? id) {
    final c = widget.category;
    if (id == null || c.isSpending) return false;
    if (c.isLedger) {
      final (shown, cut) = _limit(c, _peopleRows(c));
      return cut > 0 && !shown.any((g) => g.entries.any((t) => t.id == id));
    }
    final (shown, cut) = _limit(c, _rows(c));
    return cut > 0 && !shown.any((t) => t.id == id);
  }

  /// "Show all · N more" (or "Show N earlier") while cut, "Show less" after.
  Widget _moreRow(BuildContext context, Category c, int cut) {
    final l = context.l10n;
    return InkWell(
      onTap: () => setState(() => _showAll = !_showAll),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(56, 12, 22, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _showAll
                    ? l.commonShowLess
                    : _keepsLast(c)
                        ? l.listShowEarlier(cut)
                        : l.listShowMore(cut),
                style: AppTheme.mono(size: 11, color: context.primary),
              ),
            ),
            Icon(
              _showAll == _keepsLast(c) ? Icons.expand_more : Icons.expand_less,
              size: 16,
              color: context.primary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _unfreeze?.cancel();
    super.dispose();
  }

  List<Task> _rows(Category c) {
    final visible = visibleTasks(c);
    final frozen = _frozenOrder;
    if (frozen == null) return visible;
    final index = {for (var i = 0; i < frozen.length; i++) frozen[i]: i};
    final ordered = List.of(visible)
      ..sort(
          (a, b) => (index[a.id] ?? 1 << 20).compareTo(index[b.id] ?? 1 << 20));
    return ordered;
  }

  List<PersonGroup> _peopleRows(Category c) {
    final groups = ledgerGroups(c);
    final frozen = _frozenPeople;
    if (frozen == null) return groups;
    final index = {for (var i = 0; i < frozen.length; i++) frozen[i]: i};
    return List.of(groups)
      ..sort((a, b) =>
          (index[a.key] ?? 1 << 20).compareTo(index[b.key] ?? 1 << 20));
  }

  /// Keeps people where they are while the tick animation plays; a settled
  /// person then moves to the bottom.
  void _freezePeople(List<PersonGroup> shown) {
    _frozenPeople = shown.map((g) => g.key).toList();
    _unfreeze?.cancel();
    _unfreeze = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _frozenPeople = null);
    });
  }

  void _toggle(Category c, Task t) {
    if (c.sinkCompleted || c.isLedger || c.hideCompleted) {
      _frozenOrder = _rows(c).map((x) => x.id).toList();
      _unfreeze?.cancel();
      _unfreeze = Timer(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => _frozenOrder = null);
      });
    }
    TaskActions.toggle(context, c, t);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.category;
    final l = context.l10n;
    final dark = context.dark;
    final accent =
        c.colorValue == null ? context.primary : Color(c.colorValue!);
    final total = c.totalCount;
    final pct = c.progress;
    final (rows, cutRows) = _limit(c, _rows(c));
    final hiddenCount = !c.hideCompleted
        ? 0
        : c.isLedger
            ? ledgerGroups(c.copyWith(hideCompleted: false))
                .where((g) => g.allSettled)
                .length
            : c.tasks.where((t) => t.isCompleted).length;
    final (people, cutPeople) =
        c.isLedger ? _limit(c, _peopleRows(c)) : (const <PersonGroup>[], 0);
    final cut = c.isLedger ? cutPeople : cutRows;
    final more = _isLong(c);
    final moreOnTop = more && _keepsLast(c);
    final canDrag = !c.tracksMoney || c.ledgerSort == LedgerSort.manual;

    return Dismissible(
      key: ValueKey('cat_${c.id}'),
      background: _swipeBg(context, Alignment.centerLeft, context.primary,
          l.swipeEdit, Icons.edit_outlined),
      secondaryBackground: _swipeBg(context, Alignment.centerRight,
          context.danger, l.swipeDelete, Icons.delete_outline),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          TaskActions.editCategory(context, c);
        } else {
          TaskActions.deleteCategory(context, c);
        }
        return false;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: AppTheme.card(dark, emphasized: widget.expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: widget.onToggleExpanded,
              borderRadius: BorderRadius.circular(AppTheme.rMd),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 4, 14),
                child: Row(
                  children: [
                    _Glyph(category: c, pct: pct, accent: accent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (c.pinned)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(Icons.push_pin,
                                      size: 14, color: context.ink3),
                                ),
                              Flexible(
                                child: Text(
                                  c.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.display(
                                      size: 24, color: context.ink),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (c.isLedger)
                            Row(
                              children: [
                                MoneyText(
                                  c.outstandingMinor,
                                  c.currency,
                                  showPlus: c.kind == CategoryKind.money,
                                  style: AppTheme.mono(
                                    size: 12,
                                    color: ledgerAmountColor(
                                        context, c, c.outstandingMinor),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    '  ·  ${categoryTypeLabel(l, c)}',
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.mono(
                                        size: 11, color: context.ink3),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              c.kind == CategoryKind.tasks
                                  ? categorySummary(l, c)
                                  : '${categoryTypeLabel(l, c)} · ${categorySummary(l, c)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTheme.mono(size: 11, color: context.ink3),
                            ),
                        ],
                      ),
                    ),
                    CategoryMenu(
                        category: c,
                        onSelected: (a) => handleCategoryMenu(context, c, a)),
                    AnimatedRotation(
                      turns: widget.expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: Icon(Icons.chevron_right,
                          size: 20, color: context.ink3),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: AppTheme.hairline(dark)),
                  if (total == 0 && !c.isSpending)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(56, 16, 22, 14),
                      child: Text(l.categoryNoTasksHint,
                          style: AppTheme.body(size: 13, color: context.ink3)),
                    )
                  else if (c.isSpending)
                    SpendingView(category: c)
                  else ...[
                    if (moreOnTop) _moreRow(context, c, cut),
                    if (c.isLedger)
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: people.length,
                        onReorderStart: (_) => HapticFeedback.mediumImpact(),
                        onReorder: (a, b) => context
                            .read<CategoriesProvider>()
                            .reorderPeople(
                                c.id, people.map((g) => g.key).toList(), a, b),
                        proxyDecorator: (child, _, __) =>
                            Material(color: Colors.transparent, child: child),
                        itemBuilder: (ctx, i) {
                          final g = people[i];
                          final row = PersonRow(
                            category: c,
                            group: g,
                            isLast: i == people.length - 1 &&
                                hiddenCount == 0 &&
                                !(more && !moreOnTop),
                            highlighted: g.entries
                                .any((t) => t.id == widget.highlightTaskId),
                            onBeforeToggle: () => _freezePeople(people),
                          );
                          return canDrag
                              ? ReorderableDelayedDragStartListener(
                                  key: ValueKey('person_${g.key}'),
                                  index: i,
                                  child: row)
                              : KeyedSubtree(
                                  key: ValueKey('person_${g.key}'), child: row);
                        },
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: rows.length,
                        onReorderStart: (_) => HapticFeedback.mediumImpact(),
                        onReorder: (a, b) => context
                            .read<CategoriesProvider>()
                            .reorderVisibleTasks(
                                c.id, rows.map((t) => t.id).toList(), a, b),
                        proxyDecorator: (child, _, __) =>
                            Material(color: Colors.transparent, child: child),
                        itemBuilder: (ctx, i) {
                          final t = rows[i];
                          final row = TaskRow(
                            category: c,
                            task: t,
                            isLast: i == rows.length - 1 &&
                                hiddenCount == 0 &&
                                !(more && !moreOnTop),
                            highlighted: t.id == widget.highlightTaskId,
                            onToggle: () => _toggle(c, t),
                          );
                          return canDrag
                              ? ReorderableDelayedDragStartListener(
                                  key: ValueKey('task_${t.id}'),
                                  index: i,
                                  child: row)
                              : KeyedSubtree(
                                  key: ValueKey('task_${t.id}'), child: row);
                        },
                      ),
                    if (more && !moreOnTop) _moreRow(context, c, cut),
                  ],
                  if (hiddenCount > 0)
                    InkWell(
                      onTap: () => handleCategoryMenu(context, c, 'hide'),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(56, 10, 22, 10),
                        child: Text(
                          '${c.isLedger ? l.categoryHiddenSettled(hiddenCount) : l.categoryHiddenCompleted(hiddenCount)} · ${l.commonShow}',
                          style: AppTheme.mono(size: 11, color: context.ink3),
                        ),
                      ),
                    ),
                  Container(height: 1, color: AppTheme.hairline(dark)),
                  InkWell(
                    onTap: () => TaskActions.addTask(context, c),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(56, 14, 22, 14),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 14, color: context.ink3),
                          const SizedBox(width: 8),
                          Text(addEntryLabel(l, c),
                              style:
                                  AppTheme.mono(size: 11, color: context.ink3)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              crossFadeState: widget.expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }
}

/// Runs an action picked from [CategoryMenu].
Future<void> handleCategoryMenu(
    BuildContext context, Category c, String action) async {
  final provider = context.read<CategoriesProvider>();
  switch (action) {
    case 'edit':
      await TaskActions.editCategory(context, c);
    case 'delete':
      await TaskActions.deleteCategory(context, c);
    case 'pin':
      await provider.updateCategory(c.copyWith(pinned: !c.pinned));
    case 'hide':
      await provider
          .updateCategory(c.copyWith(hideCompleted: !c.hideCompleted));
    case 'sink':
      await provider
          .updateCategory(c.copyWith(sinkCompleted: !c.sinkCompleted));
    case 'clear':
      await TaskActions.clearCompleted(context, c);
    case 'share':
      await TaskActions.shareCategory(c);
    case 'overview':
      if (c.isSpending) {
        await SpendingOverviewPage.open(context, c.id);
      } else {
        await MoneyOverviewPage.open(context, c.id);
      }
    case 'csv':
      await SharePlus.instance.share(ShareParams(
        text: spendingCsv(c.tasks, c.currency),
        subject: c.name,
      ));
    case 'merge':
      await openSheet(context, MergeLedgersSheet(category: c));
    case 'convert':
      await openSheet(context, ConvertLedgerSheet(category: c));
    case 'sort_manual':
      await provider.updateCategory(c.copyWith(ledgerSort: LedgerSort.manual));
    case 'sort_largest':
      await provider.updateCategory(c.copyWith(ledgerSort: LedgerSort.largest));
    case 'sort_oldest':
      await provider.updateCategory(c.copyWith(ledgerSort: LedgerSort.oldest));
    case 'sort_due':
      await provider
          .updateCategory(c.copyWith(ledgerSort: LedgerSort.dueSoonest));
  }
}

Widget _swipeBg(BuildContext context, Alignment align, Color color,
    String label, IconData icon) {
  final isLeft = align == Alignment.centerLeft;
  // Pick white or black text, whichever reads better on the swipe color.
  final fg = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : Colors.black87;
  return Container(
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(AppTheme.rMd)),
    alignment: align,
    padding: const EdgeInsets.symmetric(horizontal: 22),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLeft) Icon(icon, color: fg, size: 18),
        if (isLeft) const SizedBox(width: 8),
        Text(label, style: AppTheme.mono(size: 11, color: fg)),
        if (!isLeft) const SizedBox(width: 8),
        if (!isLeft) Icon(icon, color: fg, size: 18),
      ],
    ),
  );
}

/// Progress ring (tasks) or emoji badge; pulses once when a category is finished.
class _Glyph extends StatefulWidget {
  const _Glyph(
      {required this.category, required this.pct, required this.accent});
  final Category category;
  final double pct;
  final Color accent;

  @override
  State<_Glyph> createState() => _GlyphState();
}

class _GlyphState extends State<_Glyph> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  bool _wasComplete = false;

  @override
  void initState() {
    super.initState();
    _wasComplete = widget.category.isCompleted;
  }

  @override
  void didUpdateWidget(covariant _Glyph old) {
    super.didUpdateWidget(old);
    final complete = widget.category.isCompleted;
    if (complete && !_wasComplete && !widget.category.isLedger) {
      HapticFeedback.mediumImpact();
      _pulse.forward(from: 0);
    }
    _wasComplete = complete;
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.category;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final v = _pulse.value;
        // Scale up then settle, with a fading halo.
        final scale = 1 + 0.25 * (v < 0.4 ? v / 0.4 : (1 - v) / 0.6);
        // Fixed 36×36 footprint: the halo and the scale are drawn outside
        // the layout, so the card never grows or shifts while it plays.
        return SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (_pulse.isAnimating)
                Positioned.fill(
                  child: OverflowBox(
                    maxWidth: 80,
                    maxHeight: 80,
                    child: Container(
                      width: 36 + 28 * v,
                      height: 36 + 28 * v,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: widget.accent.withValues(alpha: 1 - v),
                            width: 2),
                      ),
                    ),
                  ),
                ),
              Transform.scale(
                  scale: _pulse.isAnimating ? scale : 1, child: child),
            ],
          ),
        );
      },
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (c.isLedger || c.kind == CategoryKind.notes)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accent.withValues(alpha: 0.12),
                ),
              )
            else
              CatRing(
                  progress: widget.pct,
                  size: 36,
                  stroke: 2.5,
                  color: widget.accent),
            if (c.emoji != null)
              Text(c.emoji!, style: const TextStyle(fontSize: 16))
            else
              Icon(kindIcon(c.kind), size: 16, color: widget.accent),
          ],
        ),
      ),
    );
  }
}

/// Where an item sits in [CategoryMenu]; also the order of the groups.
enum _MenuGroup { quick, view, sort, more, danger }

class _MenuEntry {
  const _MenuEntry(this.value, this.icon, this.label, this.group,
      {this.checked = false});
  final String value;
  final IconData icon;
  final String label;
  final _MenuGroup group;

  /// On for toggles and the current sort.
  final bool checked;
}

/// Everything the ⋮ menu offers for [c], grouped and in display order.
List<_MenuEntry> _menuEntries(BuildContext context, Category c) {
  final l = context.l10n;
  return [
    if (c.isSpending || c.isLedger)
      _MenuEntry('overview', Icons.insights_outlined, l.overviewTitle,
          _MenuGroup.quick),
    _MenuEntry('pin', c.pinned ? Icons.push_pin : Icons.push_pin_outlined,
        c.pinned ? l.categoryUnpin : l.categoryPin, _MenuGroup.quick,
        checked: c.pinned),
    _MenuEntry('share', Icons.ios_share, l.commonShare, _MenuGroup.quick),
    _MenuEntry('edit', Icons.edit_outlined, l.commonEdit, _MenuGroup.quick),
    if (c.hasCheckboxes)
      _MenuEntry('hide', Icons.visibility_off_outlined, l.categoryHideCompleted,
          _MenuGroup.view,
          checked: c.hideCompleted),
    if (!c.tracksMoney && c.hasCheckboxes)
      _MenuEntry('sink', Icons.vertical_align_bottom, l.categorySinkCompleted,
          _MenuGroup.view,
          checked: c.sinkCompleted),
    if (c.tracksMoney && !c.isSpending) ...[
      _MenuEntry(
          'sort_manual', Icons.drag_handle, l.sortManual, _MenuGroup.sort,
          checked: c.ledgerSort == LedgerSort.manual),
      _MenuEntry(
          'sort_largest', Icons.trending_down, l.sortLargest, _MenuGroup.sort,
          checked: c.ledgerSort == LedgerSort.largest),
      _MenuEntry('sort_oldest', Icons.history, l.sortOldest, _MenuGroup.sort,
          checked: c.ledgerSort == LedgerSort.oldest),
      _MenuEntry('sort_due', Icons.event, l.sortDueSoonest, _MenuGroup.sort,
          checked: c.ledgerSort == LedgerSort.dueSoonest),
    ],
    if (c.completedCount > 0)
      _MenuEntry('clear', Icons.cleaning_services_outlined,
          l.categoryClearCompleted, _MenuGroup.more),
    if (c.isSpending)
      _MenuEntry('csv', Icons.table_view_outlined, l.categoryShareCsv,
          _MenuGroup.more),
    if (c.isLedger &&
        context.read<CategoriesProvider>().mergeCandidates(c).isNotEmpty)
      _MenuEntry(
          'merge', Icons.merge_type, l.categoryMergeLedgers, _MenuGroup.more),
    if (c.kind == CategoryKind.tasks && c.tasks.isNotEmpty)
      _MenuEntry('convert', Icons.account_balance_wallet_outlined,
          l.categoryConvertToLedger, _MenuGroup.more),
    _MenuEntry(
        'delete', Icons.delete_outline, l.commonDelete, _MenuGroup.danger),
  ];
}

/// The ⋮ menu on a category: pin, hide/sink completed, sort, share, convert…
/// A popup on wide screens, a grouped bottom sheet on phones.
class CategoryMenu extends StatelessWidget {
  const CategoryMenu(
      {super.key, required this.category, required this.onSelected});
  final Category category;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final icon = Icon(Icons.more_vert, size: 20, color: context.ink3);
    if (MediaQuery.sizeOf(context).width < 900) {
      return IconButton(
        icon: icon,
        tooltip: l.tooltipMore,
        onPressed: () async {
          // The sheet only picks; the action runs from here once it's closed,
          // so actions that open their own sheet or dialog aren't stacked on it.
          final v = await openSheet<String>(
              context, _CategoryMenuSheet(category: category));
          if (v != null && context.mounted) onSelected(v);
        },
      );
    }
    return PopupMenuButton<String>(
      icon: icon,
      tooltip: l.tooltipMore,
      position: PopupMenuPosition.under,
      onSelected: onSelected,
      itemBuilder: (_) {
        final items = <PopupMenuEntry<String>>[];
        _MenuGroup? group;
        for (final e in _menuEntries(context, category)) {
          if (group != null && e.group != group) {
            items.add(const PopupMenuDivider());
          }
          group = e.group;
          final color =
              e.group == _MenuGroup.danger ? context.danger : context.ink2;
          items.add(PopupMenuItem(
            value: e.value,
            child: Row(
              children: [
                Icon(e.icon, size: 18, color: color),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(e.label,
                        style: e.group == _MenuGroup.danger
                            ? TextStyle(color: context.danger)
                            : null)),
                if (e.checked && e.group != _MenuGroup.quick)
                  Icon(Icons.check, size: 16, color: context.primary),
              ],
            ),
          ));
        }
        return items;
      },
    );
  }
}

/// Phone version of [CategoryMenu]: quick-action tiles, then toggles, sort
/// chips and less common actions, with Delete set apart at the bottom.
/// Pops with the picked action's value.
class _CategoryMenuSheet extends StatelessWidget {
  const _CategoryMenuSheet({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = category;
    final entries = _menuEntries(context, c);
    List<_MenuEntry> of(_MenuGroup g) =>
        entries.where((e) => e.group == g).toList();
    final quick = of(_MenuGroup.quick);
    final view = of(_MenuGroup.view);
    final sort = of(_MenuGroup.sort);
    final more = of(_MenuGroup.more);
    void pick(String v) => Navigator.of(context).pop(v);

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
          child:
              Text(text.toUpperCase(), style: AppTheme.eyebrow(context.ink3)),
        );

    Widget row(_MenuEntry e, {Widget? trailing, Color? color}) => InkWell(
          onTap: () => pick(e.value),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 18, 12),
            child: Row(
              children: [
                Icon(e.icon, size: 20, color: color ?? context.ink2),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(e.label,
                      style:
                          AppTheme.body(size: 15, color: color ?? context.ink)),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        );

    return SheetShell(
      eyebrow: c.emoji == null ? c.name : '${c.emoji} ${c.name}',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final e in quick)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _QuickTile(entry: e, onTap: () => pick(e.value)),
                      ),
                    ),
                ],
              ),
            ),
            if (view.isNotEmpty) ...[
              header(l.menuSectionView),
              for (final e in view)
                row(e,
                    trailing: IgnorePointer(
                      child: Switch(value: e.checked, onChanged: (_) {}),
                    )),
            ],
            if (sort.isNotEmpty) ...[
              header(l.categorySort),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in sort)
                      ChoiceChip(
                        avatar: Icon(e.icon, size: 16),
                        label: Text(e.label),
                        selected: e.checked,
                        showCheckmark: false,
                        onSelected: (_) => pick(e.value),
                      ),
                  ],
                ),
              ),
            ],
            if (more.isNotEmpty) ...[
              header(l.menuSectionMore),
              for (final e in more) row(e),
            ],
            const SizedBox(height: 10),
            Container(height: 1, color: AppTheme.hairline(context.dark)),
            for (final e in of(_MenuGroup.danger))
              row(e, color: context.danger),
          ],
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.entry, required this.onTap});
  final _MenuEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = entry.checked;
    return Material(
      color: on
          ? context.primary.withValues(alpha: 0.14)
          : context.ink4.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(AppTheme.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Column(
            children: [
              Icon(entry.icon,
                  size: 22, color: on ? context.primary : context.ink2),
              const SizedBox(height: 6),
              Text(
                entry.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTheme.body(size: 12, color: context.ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One task (or ledger entry) inside a category card.
class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.category,
    required this.task,
    required this.isLast,
    required this.onToggle,
    this.highlighted = false,
    this.showCategory = false,
    this.onOpen,
  });

  final Category category;
  final Task task;
  final bool isLast;
  final VoidCallback onToggle;
  final bool highlighted;

  /// Search / Today list rows show which category a task belongs to.
  final bool showCategory;

  /// Overrides tapping the row (desktop selects instead of opening a sheet).
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final t = task;
    final c = category;
    final swipeRight = context.watch<SettingsProvider>().swipeRight;
    final ledger = c.isLedger && t.isLedgerEntry;
    final completeOnSwipe =
        swipeRight == SwipeRightAction.complete && c.hasCheckboxes;

    return Dismissible(
      key: ValueKey('dismiss_${t.id}'),
      background: Container(
        color: (completeOnSwipe ? context.success : context.ink2)
            .withValues(alpha: 0.12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 22),
        child: Icon(
          completeOnSwipe
              ? (t.isCompleted ? Icons.undo : Icons.check)
              : Icons.edit_outlined,
          size: 18,
          color: completeOnSwipe ? context.success : context.ink3,
        ),
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
            onToggle();
          } else {
            TaskActions.edit(context, c, t);
          }
          return false;
        }
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) => TaskActions.delete(context, c, t),
      child: InkWell(
        onTap: onOpen ?? () => TaskActions.openDetails(context, c.id, t.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          color: highlighted
              ? context.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 4, 18, 4),
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                          color: AppTheme.hairline(context.dark), width: 1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (c.hasCheckboxes)
                  AppCheckbox(
                    checked: t.isCompleted,
                    label: ledger ? (t.person ?? t.name) : t.name,
                    onTap: onToggle,
                  )
                else
                  SizedBox(
                    width: 44,
                    height: 44,
                    child:
                        Icon(kindIcon(c.kind), size: 18, color: context.ink3),
                  ),
                const SizedBox(width: 6),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ledger ? _ledgerBody(context) : _taskBody(context),
                  ),
                ),
                if (ledger)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: MoneyText(
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
                  )
                else if (c.tracksMoney && t.amountMinor != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: MoneyText(
                      t.amountMinor!,
                      c.currency,
                      style: AppTheme.mono(
                        size: 13,
                        color: t.isCompleted
                            ? context.ink3
                            : (c.kind == CategoryKind.savings
                                ? context.success
                                : context.ink2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _taskBody(BuildContext context) {
    final t = task;
    final preview = flattenForPreview(t.description);
    final counts = checklistCounts(t.description);
    final chips = <Widget>[
      if (showCategory)
        Chip2(
            label: category.emoji == null
                ? category.name
                : '${category.emoji} ${category.name}'),
      if (counts.total > 0)
        Chip2(
          icon: Icons.checklist,
          label: context.l10n.taskChecklistProgress(counts.done, counts.total),
          color: counts.done == counts.total ? context.success : null,
        ),
      // Done tasks keep the chip (muted) so ticking doesn't change the row's height.
      if (t.dueAt != null)
        Chip2(
          icon: Icons.event_outlined,
          label: fmtDue(context, t),
          color: t.isCompleted
              ? context.ink4
              : (isOverdue(t) ? context.danger : null),
        ),
      if (t.isRecurring) const Chip2(icon: Icons.repeat, label: '↻'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StrikeText(
          text: t.name,
          done: t.isCompleted,
          maxLines: 2,
          style: AppTheme.body(
              size: 16, color: t.isCompleted ? context.ink3 : context.ink),
        ),
        if (preview.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.body(size: 13, color: context.ink3),
            ),
          ),
        if (chips.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Wrap(spacing: 6, runSpacing: 4, children: chips),
          ),
      ],
    );
  }

  Widget _ledgerBody(BuildContext context) {
    final t = task;
    final c = category;
    final ll = context.l10n;
    final days = DateTime.now().difference(t.createdAt).inDays;
    final note = flattenForPreview(t.description);
    final parts = <String>[
      if (note.isNotEmpty) note,
      ll.ledgerDaysAgo(days),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StrikeText(
          text: t.person ?? t.name,
          done: t.isCompleted,
          maxLines: 1,
          style: AppTheme.body(
              size: 16, color: t.isCompleted ? context.ink3 : context.ink),
        ),
        const SizedBox(height: 3),
        Text(
          parts.join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.body(size: 12.5, color: context.ink3),
        ),
        if (t.paidMinor > 0 && !t.isCompleted)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: context.watch<SettingsProvider>().privacyMode
                ? const SizedBox.shrink()
                : Text(
                    ll.ledgerPaidLeft(
                      formatMinor(t.paidMinor),
                      formatMinor(t.remainingMinor.abs()),
                    ),
                    style: AppTheme.mono(size: 10.5, color: context.ink3),
                  ),
          ),
        if (showCategory || (t.dueAt != null && !t.isCompleted))
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Wrap(spacing: 6, runSpacing: 4, children: [
              if (showCategory)
                Chip2(label: c.emoji == null ? c.name : '${c.emoji} ${c.name}'),
              if (t.dueAt != null && !t.isCompleted)
                Chip2(
                  icon: Icons.event_outlined,
                  label: fmtDue(context, t),
                  color: isOverdue(t) ? context.danger : null,
                ),
            ]),
          ),
      ],
    );
  }
}
