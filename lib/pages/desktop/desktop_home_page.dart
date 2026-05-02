import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/deleted_category.dart';
import '../../models/task.dart';
import '../../providers/theme_provider.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cat_ring.dart';
import '../../widgets/formatted_text.dart';

/// Desktop layout for Tooran — sidebar (categories) + main pane (active
/// category's tasks) + optional right-hand task-detail pane that appears once
/// the window is wide enough. Mirrors the React design canvas's `DesktopApp`.
class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  final DataService _dataService = DataService();

  List<Category> _categories = [];
  String? _activeCategoryId;
  String? _selectedTaskId;
  bool _loading = true;

  // Three-pane kicks in past this width. Below it the main pane hosts the
  // detail inline as a column.
  static const double _threePaneBreakpoint = 1100;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final cats = await _dataService.loadCategoriesWithRecovery();
    setState(() {
      _categories = cats;
      _activeCategoryId ??= cats.isNotEmpty ? cats.first.id : null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    try {
      await _dataService.saveCategories(_categories);
    } catch (_) {
      _toast('Could not save changes');
    }
  }

  void _toast(String msg, {VoidCallback? onUndo, String undoLabel = 'Undo'}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        action: onUndo == null
            ? null
            : SnackBarAction(label: undoLabel.toUpperCase(), onPressed: onUndo),
      ));
  }

  Category? get _activeCategory =>
      _categories.where((c) => c.id == _activeCategoryId).cast<Category?>().firstOrNull;

  Task? get _selectedTask {
    final c = _activeCategory;
    if (c == null || _selectedTaskId == null) return null;
    return c.tasks.where((t) => t.id == _selectedTaskId).cast<Task?>().firstOrNull;
  }

  // ─── Category ops ───────────────────────────────────────────────────

  Future<void> _showCategoryDialog({Category? edit}) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryDialog(initial: edit?.name),
    );
    if (result == null) return;
    final name = result.trim();
    if (name.isEmpty) return;
    if (_categories.any(
        (c) => c.id != edit?.id && c.name.toLowerCase() == name.toLowerCase())) {
      _toast('That name already exists');
      return;
    }
    setState(() {
      if (edit == null) {
        final c = Category(name: name, sortOrder: _categories.length);
        _categories.add(c);
        _activeCategoryId = c.id;
      } else {
        final i = _categories.indexWhere((x) => x.id == edit.id);
        if (i != -1) _categories[i] = edit.copyWith(name: name);
      }
    });
    await _save();
  }

  Future<void> _confirmDeleteCategory(Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete "${c.name}"?',
        body: c.totalCount > 0
            ? 'It has ${c.totalCount} task${c.totalCount == 1 ? '' : 's'}. The category will move to History — you can restore it for thirty days.'
            : '"${c.name}" will move to History. You can restore it from there.',
        confirmLabel: 'Delete',
      ),
    );
    if (ok == true) await _deleteCategory(c);
  }

  Future<void> _deleteCategory(Category c) async {
    try {
      final dc = DeletedCategory.fromCategory(c);
      final list = await _dataService.loadDeletedCategoriesWithRecovery();
      list.add(dc);
      await _dataService.saveDeletedCategories(list);
      setState(() {
        _categories.removeWhere((x) => x.id == c.id);
        for (var i = 0; i < _categories.length; i++) {
          _categories[i] = _categories[i].copyWith(sortOrder: i);
        }
        if (_activeCategoryId == c.id) {
          _activeCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
          _selectedTaskId = null;
        }
      });
      await _save();
      _toast('"${c.name}" deleted', onUndo: () => _undoDeleteCategory(dc));
    } catch (_) {
      _toast('Could not delete category');
    }
  }

  Future<void> _undoDeleteCategory(DeletedCategory dc) async {
    try {
      final list = await _dataService.loadDeletedCategoriesWithRecovery();
      list.removeWhere((x) => x.id == dc.id);
      await _dataService.saveDeletedCategories(list);
      final restored = dc.toCategory();
      setState(() {
        _categories.add(restored);
        _categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      });
      await _save();
    } catch (_) {
      _toast('Could not restore category');
    }
  }

  // ─── Task ops ───────────────────────────────────────────────────────

  Future<void> _showTaskDialog(Category c, {Task? edit}) async {
    final result = await showDialog<_TaskFormResult>(
      context: context,
      builder: (_) => _TaskDialog(
        categoryName: c.name,
        initial: edit,
      ),
    );
    if (result == null) return;
    final name = result.name.trim();
    if (name.isEmpty) return;
    setState(() {
      final i = _categories.indexWhere((x) => x.id == c.id);
      if (i == -1) return;
      if (edit == null) {
        final t = Task(name: name, description: result.description.trim());
        _categories[i].addTask(t);
        _selectedTaskId = t.id;
      } else {
        final updated = edit.copyWith(
          name: name,
          description: result.description.trim(),
        );
        _categories[i].updateTask(updated);
      }
    });
    await _save();
  }

  void _toggleTask(Category c, Task t) {
    final updated = t.copyWith(
      isCompleted: !t.isCompleted,
      completedAt: !t.isCompleted ? DateTime.now() : null,
    );
    setState(() {
      final i = _categories.indexWhere((x) => x.id == c.id);
      if (i != -1) _categories[i].updateTask(updated);
    });
    _save();
  }

  Future<void> _confirmDeleteTask(Category c, Task t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete task?',
        body: '"${t.name}" will be removed. This cannot be undone.',
        confirmLabel: 'Delete',
      ),
    );
    if (ok != true) return;
    setState(() {
      final i = _categories.indexWhere((x) => x.id == c.id);
      if (i != -1) _categories[i].removeTask(t);
      if (_selectedTaskId == t.id) _selectedTaskId = null;
    });
    await _save();
    _toast('Task deleted');
  }

  // ─── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final showDetailPane = width >= _threePaneBreakpoint && _selectedTask != null;

    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Sidebar(
              categories: _categories,
              activeId: _activeCategoryId,
              onSelectCategory: (c) => setState(() {
                _activeCategoryId = c.id;
                _selectedTaskId = null;
              }),
              onNewCategory: () => _showCategoryDialog(),
              onOpenHistory: () => Navigator.pushNamed(context, '/history'),
              onOpenHelp: () => Navigator.pushNamed(context, '/help'),
            ),
            Expanded(
              child: _MainPane(
                category: _activeCategory,
                selectedTaskId: _selectedTaskId,
                onSelectTask: (t) => setState(() => _selectedTaskId = t.id),
                onToggleTask: (t) => _toggleTask(_activeCategory!, t),
                onAddTask: () => _showTaskDialog(_activeCategory!),
                onEditTask: (t) => _showTaskDialog(_activeCategory!, edit: t),
                onDeleteTask: (t) => _confirmDeleteTask(_activeCategory!, t),
                onRenameCategory: () =>
                    _showCategoryDialog(edit: _activeCategory),
                onDeleteCategory: () =>
                    _confirmDeleteCategory(_activeCategory!),
                onNewCategory: () => _showCategoryDialog(),
              ),
            ),
            if (showDetailPane)
              _DetailPane(
                category: _activeCategory!,
                task: _selectedTask!,
                onClose: () => setState(() => _selectedTaskId = null),
                onToggle: () =>
                    _toggleTask(_activeCategory!, _selectedTask!),
                onEdit: () =>
                    _showTaskDialog(_activeCategory!, edit: _selectedTask!),
                onDelete: () =>
                    _confirmDeleteTask(_activeCategory!, _selectedTask!),
              ),
          ],
        ),
      ),
      backgroundColor: dark ? AppTheme.dBg : AppTheme.lBg,
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
    required this.onSelectCategory,
    required this.onNewCategory,
    required this.onOpenHistory,
    required this.onOpenHelp,
  });

  final List<Category> categories;
  final String? activeId;
  final void Function(Category) onSelectCategory;
  final VoidCallback onNewCategory;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenHelp;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final surface = Theme.of(context).colorScheme.surface;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          right: BorderSide(color: AppTheme.hairline(dark), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Brand row
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 14, 14),
            child: Row(
              children: [
                Text.rich(
                  TextSpan(
                    style: AppTheme.display(size: 26, color: ink),
                    children: [
                      const TextSpan(text: 'tooran'),
                      TextSpan(
                        text: '.',
                        style: AppTheme.display(size: 26, color: primary),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Consumer<ThemeProvider>(
                  builder: (_, tp, __) => IconButton(
                    icon: Icon(
                      tp.isDarkMode
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      size: 18,
                      color: ink2,
                    ),
                    tooltip: 'Theme',
                    onPressed: tp.toggleTheme,
                  ),
                ),
              ],
            ),
          ),
          // Section label
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
              child: Text(
                'CATEGORIES',
                style: AppTheme.eyebrow(ink3),
              ),
            ),
          ),
          // Category list
          Expanded(
            child: categories.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                    child: Text(
                      'No categories yet. Create one to begin.',
                      style: AppTheme.body(size: 13, color: ink3),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: categories.length,
                    itemBuilder: (_, i) {
                      final c = categories[i];
                      return _CategoryRow(
                        category: c,
                        active: c.id == activeId,
                        onTap: () => onSelectCategory(c),
                      );
                    },
                  ),
          ),
          Divider(height: 1, color: AppTheme.hairline(dark)),
          // Secondary nav
          _SidebarNavItem(
            icon: Icons.history,
            label: 'History',
            onTap: onOpenHistory,
          ),
          _SidebarNavItem(
            icon: Icons.help_outline,
            label: 'Help',
            onTap: onOpenHelp,
          ),
          Divider(height: 1, color: AppTheme.hairline(dark)),
          // New category button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: onNewCategory,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New category'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.active,
    required this.onTap,
  });

  final Category category;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final surface2 = Theme.of(context).colorScheme.surfaceContainerHighest;
    final primary = Theme.of(context).colorScheme.primary;

    final total = category.totalCount;
    final done = category.completedCount;
    final pct = total == 0 ? 0.0 : done / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: active ? surface2 : Colors.transparent,
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
                      color: primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
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
                          CatRing(progress: pct, size: 28, stroke: 2.2),
                          Text(
                            '${(pct * 100).round()}',
                            style: AppTheme.mono(size: 9, color: ink2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(
                          size: 14.5,
                          color: ink,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$done/$total',
                      style: AppTheme.mono(size: 11, color: ink3),
                    ),
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
  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: ink2),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTheme.body(size: 13.5, color: ink2),
            ),
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
  const _MainPane({
    required this.category,
    required this.selectedTaskId,
    required this.onSelectTask,
    required this.onToggleTask,
    required this.onAddTask,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onRenameCategory,
    required this.onDeleteCategory,
    required this.onNewCategory,
  });

  final Category? category;
  final String? selectedTaskId;
  final void Function(Task) onSelectTask;
  final void Function(Task) onToggleTask;
  final VoidCallback onAddTask;
  final void Function(Task) onEditTask;
  final void Function(Task) onDeleteTask;
  final VoidCallback onRenameCategory;
  final VoidCallback onDeleteCategory;
  final VoidCallback onNewCategory;

  @override
  Widget build(BuildContext context) {
    if (category == null) return _EmptyHero(onCreate: onNewCategory);

    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final ink4 = dark ? AppTheme.dInk4 : AppTheme.lInk4;
    final primary = Theme.of(context).colorScheme.primary;

    final total = category!.totalCount;
    final done = category!.completedCount;
    final pct = total == 0 ? 0.0 : done / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Editorial header
        Container(
          padding: const EdgeInsets.fromLTRB(56, 38, 56, 22),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.hairline(dark), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    total == 0
                        ? 'NO TASKS YET'
                        : '$done OF $total COMPLETE',
                    style: AppTheme.eyebrow(ink3),
                  ),
                  const Spacer(),
                  Text(
                    '${(pct * 100).round()}%',
                    style: AppTheme.mono(size: 11, color: ink3),
                  ),
                  const SizedBox(width: 10),
                  // Segmented progress dots
                  if (total > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final t in category!.tasks)
                          Container(
                            margin: const EdgeInsets.only(left: 3),
                            width: 18,
                            height: 6,
                            decoration: BoxDecoration(
                              color: t.isCompleted ? primary : ink4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                category!.name,
                style: AppTheme.display(size: 48, color: ink),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onAddTask,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add task'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      minimumSize: const Size(0, 38),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onRenameCategory,
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('Rename'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onDeleteCategory,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ink3,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('Archive'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Body — task list
        Expanded(
          child: total == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(56),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Nothing here yet.',
                          style: AppTheme.display(size: 28, color: ink3),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add a task to fill this category with intent.',
                          style: AppTheme.body(size: 14, color: ink3),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: onAddTask,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add task'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(56, 8, 56, 60),
                  itemCount: category!.tasks.length,
                  itemBuilder: (_, i) {
                    final t = category!.tasks[i];
                    return _DesktopTaskRow(
                      task: t,
                      selected: t.id == selectedTaskId,
                      onTap: () => onSelectTask(t),
                      onToggle: () => onToggleTask(t),
                      onEdit: () => onEditTask(t),
                      onDelete: () => onDeleteTask(t),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DesktopTaskRow extends StatefulWidget {
  const _DesktopTaskRow({
    required this.task,
    required this.selected,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_DesktopTaskRow> createState() => _DesktopTaskRowState();
}

class _DesktopTaskRowState extends State<_DesktopTaskRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final ink4 = dark ? AppTheme.dInk4 : AppTheme.lInk4;
    final primary = Theme.of(context).colorScheme.primary;
    final t = widget.task;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            if (widget.selected)
              Positioned(
                left: -56,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.hairline(dark), width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 16),
                    child: _Checkbox(
                      checked: t.isCompleted,
                      onTap: widget.onToggle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: AppTheme.body(
                            size: 17,
                            color: t.isCompleted ? ink3 : ink,
                          ).copyWith(
                            decoration: t.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: ink3,
                          ),
                        ),
                        if (t.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              t.description.split('\n').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.body(size: 13.5, color: ink3),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Hover actions
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: _hovering ? 1 : 0,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, size: 16, color: ink3),
                          tooltip: 'Edit',
                          onPressed: widget.onEdit,
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 16, color: ink3),
                          tooltip: 'Delete',
                          onPressed: widget.onDelete,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 6),
                    child: Text(
                      _fmtDate(
                        t.isCompleted && t.completedAt != null
                            ? t.completedAt!
                            : t.createdAt,
                      ),
                      style: AppTheme.mono(size: 11, color: ink4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  const _EmptyHero({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final primary = Theme.of(context).colorScheme.primary;

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
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppTheme.hairlineStrong(dark),
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.folder_open_outlined, size: 32, color: ink3),
            ),
            const SizedBox(height: 22),
            Text.rich(
              TextSpan(
                style: AppTheme.display(size: 38, color: ink),
                children: [
                  const TextSpan(text: 'A '),
                  TextSpan(
                    text: 'blank',
                    style: AppTheme.display(size: 38, color: primary)
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                  const TextSpan(text: ' page, yours.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 380,
              child: Text(
                'Categories hold tasks. Tasks hold what they hold. Nothing more — start with a folder for the things you want to keep close.',
                textAlign: TextAlign.center,
                style: AppTheme.body(size: 15, color: ink3),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Create your first category'),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Detail pane (right)
// ════════════════════════════════════════════════════════════════════

class _DetailPane extends StatelessWidget {
  const _DetailPane({
    required this.category,
    required this.task,
    required this.onClose,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final Task task;
  final VoidCallback onClose;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final success = dark ? AppTheme.dSuccess : AppTheme.lSuccess;
    final surface = Theme.of(context).colorScheme.surface;
    final surface2 = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          left: BorderSide(color: AppTheme.hairline(dark), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 14, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.isCompleted ? 'COMPLETED' : 'OPEN',
                        style: AppTheme.eyebrow(
                            task.isCompleted ? success : ink3),
                      ),
                      const SizedBox(height: 4),
                      Text(category.name,
                          style: AppTheme.mono(size: 11, color: ink3)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 16, color: ink2),
                  tooltip: 'Edit',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 16, color: ink2),
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 16, color: ink2),
                  tooltip: 'Close',
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.hairline(dark)),
          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 32),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 12),
                      child: _Checkbox(
                        checked: task.isCompleted,
                        onTap: onToggle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        task.name,
                        style: AppTheme.display(size: 30, color: ink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface2,
                    borderRadius: BorderRadius.circular(AppTheme.rMd),
                    border: Border.all(
                        color: AppTheme.hairline(dark), width: 1),
                  ),
                  child: task.description.trim().isEmpty
                      ? Text(
                          'No description.',
                          style: AppTheme.display(
                              size: 17, color: ink3, style: FontStyle.italic),
                        )
                      : FormattedText(
                          text: task.description,
                          style: AppTheme.body(
                            size: 14.5,
                            color: ink,
                            weight: FontWeight.w400,
                          ).copyWith(height: 1.6),
                        ),
                ),
                const SizedBox(height: 22),
                _MetaGrid(
                  task: task,
                  category: category,
                  ink: ink,
                  ink3: ink3,
                  success: success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({
    required this.task,
    required this.category,
    required this.ink,
    required this.ink3,
    required this.success,
  });

  final Task task;
  final Category category;
  final Color ink;
  final Color ink3;
  final Color success;

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, String primary,
        {String? secondary, Color? primaryColor}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.eyebrow(ink3)),
          const SizedBox(height: 4),
          Text(primary,
              style: AppTheme.display(size: 18, color: primaryColor ?? ink)),
          if (secondary != null) ...[
            const SizedBox(height: 2),
            Text(secondary, style: AppTheme.mono(size: 11, color: ink3)),
          ],
        ],
      );
    }

    return Wrap(
      runSpacing: 18,
      spacing: 18,
      children: [
        SizedBox(
          width: 160,
          child: cell(
            'STATUS',
            task.isCompleted ? 'Done' : 'In progress',
            primaryColor: task.isCompleted ? success : ink,
          ),
        ),
        SizedBox(
          width: 160,
          child: cell(
            'CREATED',
            _fmtDate(task.createdAt),
            secondary: _fmtTime(task.createdAt),
          ),
        ),
        SizedBox(
          width: 160,
          child: cell('CATEGORY', category.name),
        ),
        if (task.completedAt != null)
          SizedBox(
            width: 160,
            child: cell(
              'COMPLETED',
              _fmtDate(task.completedAt!),
              secondary: _fmtTime(task.completedAt!),
            ),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Shared bits
// ════════════════════════════════════════════════════════════════════

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked, required this.onTap});
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink4 = dark ? AppTheme.dInk4 : AppTheme.lInk4;
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: checked ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: checked ? primary : ink4, width: 1.5),
        ),
        child: AnimatedScale(
          scale: checked ? 1 : 0.5,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: checked ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String _fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

String _fmtTime(DateTime d) {
  final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $ap';
}

// ════════════════════════════════════════════════════════════════════
// Dialogs (centered modals — replace mobile bottom sheets on desktop)
// ════════════════════════════════════════════════════════════════════

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.initial});
  final String? initial;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _ctrl.text);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final isEdit = widget.initial != null;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEdit ? 'EDIT CATEGORY' : 'NEW CATEGORY',
                  style: AppTheme.eyebrow(ink3)),
              const SizedBox(height: 10),
              Text(
                isEdit ? 'Rename it.' : 'What are we keeping close?',
                style: AppTheme.display(size: 26, color: ink),
              ),
              const SizedBox(height: 18),
              Text('NAME', style: AppTheme.eyebrow(ink3)),
              const SizedBox(height: 6),
              TextField(
                controller: _ctrl,
                autofocus: true,
                cursorColor: Theme.of(context).colorScheme.primary,
                textCapitalization: TextCapitalization.sentences,
                style: AppTheme.display(size: 20, color: ink),
                decoration: const InputDecoration(
                  hintText: 'A new beginning…',
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEdit ? 'Save' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskFormResult {
  _TaskFormResult({required this.name, required this.description});
  final String name;
  final String description;
}

class _TaskDialog extends StatefulWidget {
  const _TaskDialog({required this.categoryName, this.initial});
  final String categoryName;
  final Task? initial;

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController _desc =
      TextEditingController(text: widget.initial?.description ?? '');

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _insert(String prefix) {
    final text = _desc.text;
    final sel = _desc.selection;
    final offset = sel.isValid ? sel.baseOffset : text.length;
    final needsNl = offset > 0 && text[offset - 1] != '\n';
    final ins = (needsNl ? '\n' : '') + prefix;
    final nt = text.substring(0, offset) + ins + text.substring(offset);
    _desc.value = TextEditingValue(
      text: nt,
      selection: TextSelection.collapsed(offset: offset + ins.length),
    );
  }

  void _submit() => Navigator.pop(
        context,
        _TaskFormResult(name: _name.text, description: _desc.text),
      );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final isEdit = widget.initial != null;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit
                    ? 'EDIT TASK'
                    : 'NEW TASK · IN "${widget.categoryName.toUpperCase()}"',
                style: AppTheme.eyebrow(ink3),
              ),
              const SizedBox(height: 10),
              Text(
                isEdit ? 'Adjust it.' : 'Something to do.',
                style: AppTheme.display(size: 26, color: ink),
              ),
              const SizedBox(height: 18),
              Text('NAME', style: AppTheme.eyebrow(ink3)),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                autofocus: true,
                cursorColor: Theme.of(context).colorScheme.primary,
                textCapitalization: TextCapitalization.sentences,
                style: AppTheme.display(size: 20, color: ink),
                decoration: const InputDecoration(
                  hintText: 'What needs doing?',
                ),
              ),
              const SizedBox(height: 18),
              Text('DESCRIPTION', style: AppTheme.eyebrow(ink3)),
              const SizedBox(height: 6),
              TextField(
                controller: _desc,
                cursorColor: Theme.of(context).colorScheme.primary,
                maxLines: 6,
                minLines: 4,
                style: AppTheme.body(size: 14.5, color: ink),
                decoration: InputDecoration(
                  hintText: 'Add notes, steps, links…',
                  hintStyle: AppTheme.body(
                      size: 14.5,
                      color: dark ? AppTheme.dInk4 : AppTheme.lInk4),
                  border: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppTheme.hairline(dark), width: 1),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppTheme.hairline(dark), width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _FormatTool(
                    icon: Icons.format_list_bulleted,
                    label: 'BULLET',
                    onTap: () => _insert('• '),
                  ),
                  const SizedBox(width: 6),
                  _FormatTool(
                    icon: Icons.format_list_numbered,
                    label: 'NUMBERED',
                    onTap: () => _insert('1. '),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('⌘+↵ to add',
                      style: AppTheme.mono(size: 11, color: ink2)),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEdit ? 'Save' : 'Add task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatTool extends StatelessWidget {
  const _FormatTool({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.hairlineStrong(dark), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: ink2),
            const SizedBox(width: 6),
            Text(label, style: AppTheme.mono(size: 11, color: ink2)),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
  });

  final String title;
  final String body;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.display(size: 24)),
              const SizedBox(height: 10),
              Text(body,
                  style: AppTheme.body(size: 14, color: ink2)
                      .copyWith(height: 1.5)),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
