import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/categories_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../services/app_intents.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/category_card.dart';
import '../widgets/category_sheet.dart';
import '../widgets/common.dart';
import '../widgets/shared_text_sheet.dart';
import '../widgets/task_actions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scroll = ScrollController();
  Set<String> _expanded = {};
  bool _expandedLoaded = false;
  String? _highlightTaskId;
  Timer? _highlightTimer;
  AppIntents? _intents;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsProvider>();
    if (!_expandedLoaded && settings.loaded) {
      _expanded = settings.expandedCategories;
      _expandedLoaded = true;
    }
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
    _highlightTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _setExpanded(Set<String> ids) {
    setState(() => _expanded = ids);
    context.read<SettingsProvider>().expandedCategories = ids;
  }

  void _toggleExpanded(Category c) {
    final next = Set.of(_expanded);
    next.contains(c.id) ? next.remove(c.id) : next.add(c.id);
    _setExpanded(next);
  }

  // ─── Intents from reminders, the widget and the share sheet ─────────

  void _handleIntents() {
    if (!mounted) return;
    final provider = context.read<CategoriesProvider>();
    if (provider.isLoading) {
      // Try again once data is in.
      Future.delayed(const Duration(milliseconds: 300), _handleIntents);
      return;
    }
    final intent = _intents?.take();
    if (intent == null) return;
    switch (intent) {
      case OpenTaskIntent(:final categoryId, :final taskId):
        if (provider.taskById(categoryId, taskId) == null) break;
        _setExpanded({..._expanded, categoryId});
        _highlight(taskId);
        TaskActions.openDetails(context, categoryId, taskId);
      case AddTaskIntent(:final categoryId):
        final settings = context.read<SettingsProvider>();
        final id = categoryId ?? settings.widgetSource;
        final cats = provider.categories;
        final c = provider.byId(id ?? '') ?? (cats.isEmpty ? null : cats.first);
        if (c != null) TaskActions.addTask(context, c);
      case SharedTextIntent(:final text):
        openSheet(context, SharedTextSheet(text: text));
      case OpenPeopleIntent():
        Navigator.pushNamed(context, '/people');
    }
    // More may be queued.
    if (_intents != null) Future.microtask(_handleIntents);
  }

  void _highlight(String taskId) {
    setState(() => _highlightTaskId = taskId);
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlightTaskId = null);
    });
  }

  // ─── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();
    final settings = context.watch<SettingsProvider>();
    final categories = provider.categories;
    final l = context.l10n;

    return Scaffold(
      key: _scaffoldKey,
      // Swiping left on the open menu closes it (built into Drawer).
      drawerEdgeDragWidth: 24,
      drawer: AppDrawer(
        onExpandAll: () => _setExpanded(categories.map((c) => c.id).toSet()),
        onCollapseAll: () => _setExpanded({}),
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const _LoadingView()
            : CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverToBoxAdapter(
                    child: _TopSwipe(
                      onOpen: () => _scaffoldKey.currentState?.openDrawer(),
                      child: _appBar(context, categories),
                    ),
                  ),
                  if (!settings.tipsDismissed && categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _TipsCard(
                          onDismiss: () => settings.tipsDismissed = true),
                    ),
                  if (categories.isEmpty)
                    SliverFillRemaining(
                        hasScrollBody: false, child: _EmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 120),
                      sliver: SliverReorderableList(
                        itemCount: categories.length,
                        onReorder: provider.reorderCategories,
                        proxyDecorator: (child, _, __) =>
                            Material(color: Colors.transparent, child: child),
                        itemBuilder: (ctx, i) {
                          final c = categories[i];
                          return Padding(
                            key: ValueKey(c.id),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ReorderableDelayedDragStartListener(
                              index: i,
                              child: CategoryCard(
                                category: c,
                                expanded: _expanded.contains(c.id),
                                onToggleExpanded: () => _toggleExpanded(c),
                                highlightTaskId: _highlightTaskId,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: provider.isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: () => openSheet(
                  context,
                  CategorySheet(
                    onCreated: (c) => _setExpanded({..._expanded, c.id}),
                  )),
              icon: const Icon(Icons.add, size: 20),
              label: Text(l.fabCategory),
            ),
    );
  }

  Widget _appBar(BuildContext context, List<Category> categories) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      child: Row(
        children: [
          IconBtn(
            icon: Icons.menu,
            tooltip: l.tooltipMenu,
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 4),
          // Tapping the wordmark scrolls back to the top.
          Expanded(
            child: GestureDetector(
              onTap: () => _scroll.animateTo(0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text.rich(
                    TextSpan(
                      style: AppTheme.display(size: 30, color: context.ink),
                      children: [
                        const TextSpan(text: 'tooran'),
                        TextSpan(
                            text: '.',
                            style: AppTheme.display(
                                size: 30, color: context.primary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
    );
  }
}

/// Swipe right on the top bar to open the side menu. Only the top bar
/// listens, so swipes on tasks keep their own actions and the screen edge
/// stays free for the system back gesture.
class _TopSwipe extends StatefulWidget {
  const _TopSwipe({required this.child, required this.onOpen});
  final Widget child;
  final VoidCallback onOpen;

  @override
  State<_TopSwipe> createState() => _TopSwipeState();
}

class _TopSwipeState extends State<_TopSwipe> {
  double _dx = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _dx = 0,
      onHorizontalDragUpdate: (d) => _dx += d.delta.dx,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (_dx > 48 || v > 350) {
          HapticFeedback.selectionClick();
          widget.onOpen();
        }
      },
      // Extra height below the bar makes the swipe easy to hit.
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: widget.child,
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.rMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: context.primary),
                const SizedBox(width: 8),
                Text(l.tipsTitle.toUpperCase(),
                    style: AppTheme.eyebrow(context.primary)),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(l.tipsBody,
                  style: AppTheme.body(size: 13.5, color: context.ink2)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onDismiss, child: Text(l.tipsGotIt)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.rLg),
                border: Border.all(
                    color: AppTheme.hairlineStrong(context.dark), width: 1.5),
              ),
              child: Icon(Icons.folder_open_outlined,
                  size: 26, color: context.ink3),
            ),
            const SizedBox(height: 18),
            Text(l.emptyTitle,
                style: AppTheme.display(size: 26, color: context.ink)),
            const SizedBox(height: 8),
            Text(
              l.emptyBody,
              textAlign: TextAlign.center,
              style: AppTheme.body(size: 14, color: context.ink3),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => context
                  .read<CategoriesProvider>()
                  .addMoneyPreset(
                      name: l.ledgerPresetMoney,
                      currency:
                          context.read<SettingsProvider>().defaultCurrency),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
              label: Text(l.emptyLedgerPreset),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: context.primary),
          ),
          const SizedBox(height: 18),
          Text(context.l10n.loading,
              style: AppTheme.mono(size: 11, color: context.ink3)),
        ],
      ),
    );
  }
}
