import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/task.dart';
import '../../providers/categories_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/app_intents.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cat_ring.dart';
import '../../widgets/category_card.dart';
import '../../widgets/category_sheet.dart';
import '../../widgets/common.dart';
import '../../widgets/kind_info.dart';
import '../../widgets/ledger_groups.dart';
import '../../widgets/person_sheet.dart';
import '../../widgets/spending_view.dart';
import '../../widgets/shared_text_sheet.dart';
import '../../widgets/task_actions.dart';
import '../../widgets/task_details_sheet.dart';

/// Desktop layout for Tooran — sidebar (categories) + main pane (active
/// category's tasks) + optional right-hand task-detail pane that appears once
/// the window is wide enough. Mirrors the React design canvas's `DesktopApp`.
class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  String? _activeCategoryId;
  String? _selectedTaskId;
  AppIntents? _intents;

  // Three-pane kicks in past this width. Below it tasks open as dialogs.
  static const double _threePaneBreakpoint = 1100;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final intents = context.read<AppIntents>();
    if (_intents != intents) {
      _intents?.removeListener(_handleIntents);
      _intents = intents..addListener(_handleIntents);
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleIntents());
    }
  }

  @override
  void dispose() {
    _intents?.removeListener(_handleIntents);
    super.dispose();
  }

  void _handleIntents() {
    if (!mounted) return;
    final provider = context.read<CategoriesProvider>();
    if (provider.isLoading) {
      Future.delayed(const Duration(milliseconds: 300), _handleIntents);
      return;
    }
    final intent = _intents?.take();
    if (intent == null) return;
    switch (intent) {
      case OpenTaskIntent(:final categoryId, :final taskId):
        if (provider.taskById(categoryId, taskId) != null) {
          _select(categoryId, taskId);
        }
      case AddTaskIntent(:final categoryId):
        final c = provider.byId(categoryId ?? _activeCategoryId ?? '') ??
            _active(provider);
        if (c != null) TaskActions.addTask(context, c);
      case SharedTextIntent(:final text):
        openSheet(context, SharedTextSheet(text: text));
      case OpenPeopleIntent():
        Navigator.pushNamed(context, '/people');
    }
    Future.microtask(_handleIntents);
  }

  void _select(String categoryId, String? taskId) {
    setState(() {
      _activeCategoryId = categoryId;
      _selectedTaskId = taskId;
    });
    if (taskId != null &&
        MediaQuery.sizeOf(context).width < _threePaneBreakpoint) {
      TaskActions.openDetails(context, categoryId, taskId);
    }
  }

  Category? _active(CategoriesProvider p) {
    final cats = p.categories;
    return p.byId(_activeCategoryId ?? '') ??
        (cats.isEmpty ? null : cats.first);
  }

  void _newCategory() => openSheet(
        context,
        CategorySheet(
            onCreated: (c) => setState(() => _activeCategoryId = c.id)),
      );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();
    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final active = _active(provider);
    final selected = active == null || _selectedTaskId == null
        ? null
        : provider.taskById(active.id, _selectedTaskId!);
    final width = MediaQuery.sizeOf(context).width;
    final showDetailPane = width >= _threePaneBreakpoint && selected != null;

    return Scaffold(
      backgroundColor: context.dark ? AppTheme.dBg : AppTheme.lBg,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Sidebar(
              categories: provider.categories,
              activeId: active?.id,
              hasLedgers: provider.hasLedgers,
              onSelectCategory: (c) => _select(c.id, null),
              onNewCategory: _newCategory,
            ),
            Expanded(
              child: active == null
                  ? _EmptyHero(onCreate: _newCategory)
                  : _MainPane(
                      category: active,
                      selectedTaskId: _selectedTaskId,
                      onSelectTask: (t) => _select(active.id, t.id),
                    ),
            ),
            if (showDetailPane)
              Container(
                width: 420,
                decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          color: AppTheme.hairline(context.dark), width: 1)),
                ),
                child: TaskDetailsSheet(
                  key: ValueKey(selected.id),
                  categoryId: active!.id,
                  taskId: selected.id,
                  embedded: true,
                  onClose: () => setState(() => _selectedTaskId = null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Sidebar
// ════════════════════════════════════════════════════════════════════

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.categories,
    required this.activeId,
    required this.hasLedgers,
    required this.onSelectCategory,
    required this.onNewCategory,
  });

  final List<Category> categories;
  final String? activeId;
  final bool hasLedgers;
  final void Function(Category) onSelectCategory;
  final VoidCallback onNewCategory;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = context.read<CategoriesProvider>();
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
            right:
                BorderSide(color: AppTheme.hairline(context.dark), width: 1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 8, 14),
            child: Row(
              children: [
                Text.rich(
                  TextSpan(
                    style: AppTheme.display(size: 26, color: context.ink),
                    children: [
                      const TextSpan(text: 'tooran'),
                      TextSpan(
                          text: '.',
                          style: AppTheme.display(
                              size: 26, color: context.primary)),
                    ],
                  ),
                ),
                const Spacer(),
                IconBtn(
                  icon: Icons.search,
                  tooltip: l.menuSearch,
                  onTap: () => Navigator.pushNamed(context, '/search'),
                ),
                Consumer<ThemeProvider>(
                  builder: (_, tp, __) => IconBtn(
                    icon: tp.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    tooltip: l.tooltipTheme,
                    onTap: tp.toggleTheme,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
              child: Text(l.desktopCategories,
                  style: AppTheme.eyebrow(context.ink3)),
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                    child: Text(l.desktopNoCategories,
                        style: AppTheme.body(size: 13, color: context.ink3)),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    buildDefaultDragHandles: false,
                    itemCount: categories.length,
                    onReorder: provider.reorderCategories,
                    proxyDecorator: (child, _, __) =>
                        Material(color: Colors.transparent, child: child),
                    itemBuilder: (_, i) {
                      final c = categories[i];
                      return ReorderableDelayedDragStartListener(
                        key: ValueKey(c.id),
                        index: i,
                        child: _CategoryRow(
                          category: c,
                          active: c.id == activeId,
                          onTap: () => onSelectCategory(c),
                        ),
                      );
                    },
                  ),
          ),
          Divider(height: 1, color: AppTheme.hairline(context.dark)),
          _SidebarNavItem(
              icon: Icons.today_outlined, label: l.menuToday, route: '/today'),
          if (hasLedgers)
            _SidebarNavItem(
                icon: Icons.people_outline,
                label: l.menuPeople,
                route: '/people'),
          _SidebarNavItem(
              icon: Icons.history, label: l.menuHistory, route: '/history'),
          _SidebarNavItem(
              icon: Icons.settings_outlined,
              label: l.menuSettings,
              route: '/settings'),
          _SidebarNavItem(
              icon: Icons.help_outline, label: l.menuHelp, route: '/help'),
          Divider(height: 1, color: AppTheme.hairline(context.dark)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: onNewCategory,
                icon: const Icon(Icons.add, size: 16),
                label: Text(l.desktopNewCategory),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow(
      {required this.category, required this.active, required this.onTap});

  final Category category;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = category;
    final total = c.totalCount;
    final done = c.completedCount;
    final pct = c.progress;
    final accent =
        c.colorValue == null ? context.primary : Color(c.colorValue!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: active
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              if (active)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 8,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                        color: accent, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!c.isLedger && c.kind != CategoryKind.notes)
                            CatRing(
                                progress: pct,
                                size: 28,
                                stroke: 2.2,
                                color: accent),
                          if (c.emoji != null)
                            Text(c.emoji!, style: const TextStyle(fontSize: 14))
                          else
                            Icon(kindIcon(c.kind), size: 14, color: accent),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (c.pinned) ...[
                      Icon(Icons.push_pin, size: 12, color: context.ink3),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        c.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(
                            size: 14.5,
                            color: context.ink,
                            weight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (c.isLedger)
                      MoneyText(c.outstandingMinor, c.currency,
                          style: AppTheme.mono(size: 11, color: context.ink3))
                    else if (c.kind == CategoryKind.savings)
                      MoneyText(c.savedMinor, c.currency,
                          style: AppTheme.mono(size: 11, color: context.ink3))
                    else if (c.tracksMoney && c.openAmountMinor > 0)
                      MoneyText(c.openAmountMinor, c.currency,
                          style: AppTheme.mono(size: 11, color: context.ink3))
                    else if (c.hasCheckboxes)
                      Text('$done/$total',
                          style: AppTheme.mono(size: 11, color: context.ink3))
                    else
                      Text('$total',
                          style: AppTheme.mono(size: 11, color: context.ink3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem(
      {required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 11, 22, 11),
        child: Row(
          children: [
            Icon(icon, size: 16, color: context.ink2),
            const SizedBox(width: 12),
            Text(label, style: AppTheme.body(size: 13.5, color: context.ink2)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Main pane
// ════════════════════════════════════════════════════════════════════

class _MainPane extends StatelessWidget {
  const _MainPane(
      {required this.category,
      required this.selectedTaskId,
      required this.onSelectTask});

  final Category category;
  final String? selectedTaskId;
  final void Function(Task task) onSelectTask;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = category;
    final total = c.totalCount;
    final done = c.completedCount;
    final rows = visibleTasks(c);
    final hidden = !c.hideCompleted
        ? 0
        : c.isLedger
            ? ledgerGroups(c.copyWith(hideCompleted: false))
                .where((g) => g.allSettled)
                .length
            : c.tasks.where((t) => t.isCompleted).length;
    final people = c.isLedger ? ledgerGroups(c) : const <PersonGroup>[];
    final canDrag = !c.tracksMoney || c.ledgerSort == LedgerSort.manual;
    final btnStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      minimumSize: const Size(0, 38),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(56, 38, 40, 22),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: AppTheme.hairline(context.dark), width: 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (c.isLedger)
                    Text(
                      '${l.ledgerOutstanding} · ${categoryTypeLabel(l, c)}'
                          .toUpperCase(),
                      style: AppTheme.eyebrow(context.ink3),
                    )
                  else if (c.kind == CategoryKind.tasks)
                    Text(
                        total == 0
                            ? l.desktopNoTasksYet
                            : l.desktopComplete(done, total),
                        style: AppTheme.eyebrow(context.ink3))
                  else
                    Text(
                        '${categoryTypeLabel(l, c)} · ${categorySummary(l, c)}',
                        style: AppTheme.eyebrow(context.ink3)),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      c.emoji == null ? c.name : '${c.emoji} ${c.name}',
                      style: AppTheme.display(size: 48, color: context.ink),
                    ),
                  ),
                  if (c.isLedger)
                    MoneyText(
                      c.outstandingMinor,
                      c.currency,
                      showPlus: c.kind == CategoryKind.money,
                      style: AppTheme.display(
                        size: 32,
                        color: ledgerAmountColor(
                            context,
                            c,
                            c.outstandingMinor),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => TaskActions.addTask(context, c),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(newEntryTitle(l, c)),
                    style: btnStyle,
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => TaskActions.editCategory(context, c),
                    style: btnStyle,
                    child: Text(l.desktopRename),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => TaskActions.deleteCategory(context, c),
                    style: btnStyle.copyWith(
                        foregroundColor: WidgetStatePropertyAll(context.ink3)),
                    child: Text(l.desktopArchive),
                  ),
                  const SizedBox(width: 4),
                  CategoryMenu(
                      category: c,
                      onSelected: (a) => handleCategoryMenu(context, c, a)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: total == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(56),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.desktopNothingHere,
                            style: AppTheme.display(
                                size: 28, color: context.ink3)),
                        const SizedBox(height: 6),
                        Text(l.desktopNothingHereBody,
                            style:
                                AppTheme.body(size: 14, color: context.ink3)),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () => TaskActions.addTask(context, c),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(newEntryTitle(l, c)),
                        ),
                      ],
                    ),
                  ),
                )
              : c.isSpending
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 60),
                      children: [SpendingView(category: c, onOpen: onSelectTask, padding: 18)],
                    )
                  : c.isLedger
                  ? ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(40, 8, 40, 60),
                      buildDefaultDragHandles: false,
                      itemCount: people.length,
                      onReorder: (a, b) => context
                          .read<CategoriesProvider>()
                          .reorderPeople(
                              c.id, people.map((g) => g.key).toList(), a, b),
                      proxyDecorator: (child, _, __) =>
                          Material(color: Colors.transparent, child: child),
                      itemBuilder: (_, i) {
                        final row = PersonRow(
                            category: c,
                            group: people[i],
                            isLast: i == people.length - 1);
                        return canDrag
                            ? ReorderableDelayedDragStartListener(
                                key: ValueKey(people[i].key),
                                index: i,
                                child: row)
                            : KeyedSubtree(
                                key: ValueKey(people[i].key), child: row);
                      },
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(40, 8, 40, 60),
                      buildDefaultDragHandles: false,
                      itemCount: rows.length,
                      onReorder: (a, b) => context
                          .read<CategoriesProvider>()
                          .reorderVisibleTasks(
                              c.id, rows.map((t) => t.id).toList(), a, b),
                      proxyDecorator: (child, _, __) =>
                          Material(color: Colors.transparent, child: child),
                      footer: hidden == 0
                          ? null
                          : TextButton(
                              onPressed: () =>
                                  handleCategoryMenu(context, c, 'hide'),
                              child: Text(
                                '${c.isLedger ? l.categoryHiddenSettled(hidden) : l.categoryHiddenCompleted(hidden)} · ${l.commonShow}',
                              ),
                            ),
                      itemBuilder: (_, i) {
                        final t = rows[i];
                        final row = TaskRow(
                          category: c,
                          task: t,
                          isLast: i == rows.length - 1,
                          highlighted: t.id == selectedTaskId,
                          onToggle: () => TaskActions.toggle(context, c, t),
                          onOpen: () => onSelectTask(t),
                        );
                        return canDrag
                            ? ReorderableDelayedDragStartListener(
                                key: ValueKey(t.id), index: i, child: row)
                            : KeyedSubtree(key: ValueKey(t.id), child: row);
                      },
                    ),
        ),
      ],
    );
  }
}

class _EmptyHero extends StatelessWidget {
  const _EmptyHero({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(56),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.rLg),
                border: Border.all(
                    color: AppTheme.hairlineStrong(context.dark), width: 1.5),
              ),
              child: Icon(Icons.folder_open_outlined,
                  size: 32, color: context.ink3),
            ),
            const SizedBox(height: 22),
            Text.rich(
              TextSpan(
                style: AppTheme.display(size: 38, color: context.ink),
                children: [
                  TextSpan(text: l.desktopBlankA),
                  TextSpan(
                    text: l.desktopBlankWord,
                    style: AppTheme.display(size: 38, color: context.primary)
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                  TextSpan(text: l.desktopBlankRest),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 380,
              child: Text(
                l.desktopBlankBody,
                textAlign: TextAlign.center,
                style: AppTheme.body(size: 15, color: context.ink3),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add, size: 16),
              label: Text(l.desktopCreateFirst),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => context
                  .read<CategoriesProvider>()
                  .addMoneyPreset(name: l.ledgerPresetMoney, currency: 'ETB'),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
              label: Text(l.emptyLedgerPreset),
            ),
          ],
        ),
      ),
    );
  }
}
