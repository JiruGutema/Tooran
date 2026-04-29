import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/category.dart';
import '../models/deleted_category.dart';
import '../models/task.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cat_ring.dart';
import '../widgets/formatted_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataService _dataService = DataService();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();

  List<Category> _categories = [];
  Set<String> _expanded = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _taskNameController.dispose();
    _taskDescriptionController.dispose();
    super.dispose();
  }

  // ─── Data ───────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final categories = await _dataService.loadCategoriesWithRecovery();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _toast('Could not load your tasks');
    }
  }

  Future<void> _saveData() async {
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

  // ─── Category ops ───────────────────────────────────────────────────

  void _showAddCategorySheet() {
    _categoryController.clear();
    _openSheet(_CategorySheet(
      mode: 'New category',
      controller: _categoryController,
      submitLabel: 'Create',
      onSubmit: _addCategory,
    ));
  }

  void _showEditCategorySheet(Category c) {
    _categoryController.text = c.name;
    _openSheet(_CategorySheet(
      mode: 'Edit category',
      controller: _categoryController,
      submitLabel: 'Save',
      onSubmit: () => _editCategory(c),
    ));
  }

  void _addCategory() {
    final name = _categoryController.text.trim();
    if (name.isEmpty) {
      _toast('Please enter a category name');
      return;
    }
    if (_categories.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      _toast('That name already exists');
      return;
    }
    final cat = Category(name: name, sortOrder: _categories.length);
    setState(() {
      _categories.add(cat);
    });
    _saveData();
    _categoryController.clear();
    Navigator.pop(context);
  }

  void _editCategory(Category c) {
    final name = _categoryController.text.trim();
    if (name.isEmpty) {
      _toast('Please enter a category name');
      return;
    }
    if (_categories.any((x) => x.id != c.id && x.name.toLowerCase() == name.toLowerCase())) {
      _toast('That name already exists');
      return;
    }
    setState(() {
      final i = _categories.indexWhere((x) => x.id == c.id);
      if (i != -1) _categories[i] = c.copyWith(name: name);
    });
    _saveData();
    Navigator.pop(context);
  }

  void _confirmDeleteCategory(Category c) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete category?',
        body: c.totalCount > 0
            ? '"${c.name}" and its ${c.totalCount} task${c.totalCount == 1 ? '' : 's'} will move to history. You can restore it from there.'
            : '"${c.name}" will move to history. You can restore it from there.',
        confirmLabel: 'Delete',
        onConfirm: () {
          Navigator.pop(context);
          _deleteCategory(c);
        },
      ),
    );
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
      });
      await _saveData();
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
      await _saveData();
    } catch (_) {
      _toast('Could not restore category');
    }
  }

  void _reorderCategories(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final c = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, c);
      for (var i = 0; i < _categories.length; i++) {
        _categories[i] = _categories[i].copyWith(sortOrder: i);
      }
    });
    _saveData();
  }

  // ─── Task ops ───────────────────────────────────────────────────────

  void _showAddTaskSheet(Category c) {
    _taskNameController.clear();
    _taskDescriptionController.clear();
    _openSheet(_TaskSheet(
      mode: 'New task',
      submitLabel: 'Add task',
      nameCtrl: _taskNameController,
      descCtrl: _taskDescriptionController,
      onSubmit: () => _addTask(c),
    ));
  }

  void _showEditTaskSheet(Category c, Task t) {
    _taskNameController.text = t.name;
    _taskDescriptionController.text = t.description;
    _openSheet(_TaskSheet(
      mode: 'Edit task',
      submitLabel: 'Save',
      nameCtrl: _taskNameController,
      descCtrl: _taskDescriptionController,
      onSubmit: () => _editTask(c, t),
    ));
  }

  void _addTask(Category c) {
    final name = _taskNameController.text.trim();
    if (name.isEmpty) {
      _toast('Please enter a task name');
      return;
    }
    final t = Task(name: name, description: _taskDescriptionController.text.trim());
    setState(() {
      final i = _categories.indexWhere((x) => x.id == c.id);
      if (i != -1) _categories[i].addTask(t);
    });
    _saveData();
    Navigator.pop(context);
  }

  void _editTask(Category c, Task t) {
    final name = _taskNameController.text.trim();
    if (name.isEmpty) {
      _toast('Please enter a task name');
      return;
    }
    final updated = t.copyWith(name: name, description: _taskDescriptionController.text.trim());
    setState(() {
      final i = _categories.indexWhere((x) => x.id == c.id);
      if (i != -1) _categories[i].updateTask(updated);
    });
    _saveData();
    Navigator.pop(context);
  }

  void _confirmDeleteTask(Category c, Task t) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete task?',
        body: '"${t.name}" will be removed. This cannot be undone.',
        confirmLabel: 'Delete',
        onConfirm: () {
          Navigator.pop(context);
          _deleteTask(c, t);
        },
      ),
    );
  }

  void _deleteTask(Category c, Task t) {
    setState(() {
      final i = _categories.indexWhere((x) => x.id == c.id);
      if (i != -1) _categories[i].removeTask(t);
    });
    _saveData();
    _toast('Task deleted');
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
    _saveData();
  }

  void _reorderTasks(Category c, int oldIndex, int newIndex) {
    setState(() {
      final i = _categories.indexWhere((x) => x.id == c.id);
      if (i != -1) _categories[i].reorderTasks(oldIndex, newIndex);
    });
    _saveData();
  }

  // ─── Bottom sheet helpers ───────────────────────────────────────────

  void _openSheet(Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: child,
      ),
    );
  }

  void _showTaskDetails(Category c, Task t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, sc) => _TaskDetailsSheet(
          category: c,
          task: t,
          scrollController: sc,
          onToggle: () {
            _toggleTask(c, t);
            Navigator.pop(ctx);
          },
          onEdit: () {
            Navigator.pop(ctx);
            _showEditTaskSheet(c, t);
          },
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? _LoadingView()
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _appBar(context)),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  if (_categories.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _emptyState(context),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 120),
                      sliver: SliverReorderableList(
                        itemCount: _categories.length,
                        onReorder: _reorderCategories,
                        proxyDecorator: (child, _, anim) => Material(
                          color: Colors.transparent,
                          child: child,
                        ),
                        itemBuilder: (ctx, i) {
                          final c = _categories[i];
                          return Padding(
                            key: ValueKey(c.id),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ReorderableDelayedDragStartListener(
                              index: i,
                              child: _CategoryCard(
                                category: c,
                                expanded: _expanded.contains(c.id),
                                onToggleExpanded: () => setState(() {
                                  _expanded.contains(c.id)
                                      ? _expanded.remove(c.id)
                                      : _expanded.add(c.id);
                                }),
                                onEdit: () => _showEditCategorySheet(c),
                                onDelete: () => _confirmDeleteCategory(c),
                                onAddTask: () => _showAddTaskSheet(c),
                                onToggleTask: (t) => _toggleTask(c, t),
                                onOpenTask: (t) => _showTaskDetails(c, t),
                                onEditTask: (t) => _showEditTaskSheet(c, t),
                                onDeleteTask: (t) => _confirmDeleteTask(c, t),
                                onReorderTasks: (a, b) => _reorderTasks(c, a, b),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddCategorySheet,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Category'),
            ),
    );
  }

  Widget _appBar(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 14, 0),
      child: Row(
        children: [
          // Brand: tooran.
          Text.rich(
            TextSpan(
              style: AppTheme.display(size: 30, color: ink),
              children: [
                const TextSpan(text: 'tooran'),
                TextSpan(
                  text: '.',
                  style: AppTheme.display(
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Consumer<ThemeProvider>(
            builder: (_, tp, __) => _IconBtn(
              icon: tp.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: ink2,
              onTap: tp.toggleTheme,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: ink2),
            tooltip: 'More',
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            onSelected: (v) {
              switch (v) {
                case 'history':
                  Navigator.pushNamed(context, '/history');
                  break;
                case 'help':
                  Navigator.pushNamed(context, '/help');
                  break;
                case 'contact':
                  Navigator.pushNamed(context, '/contact');
                  break;
                case 'about':
                  Navigator.pushNamed(context, '/about');
                  break;
                case 'update':
                  launchUrl(Uri.parse('https://tooran.vercel.app'));
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'history', child: Text('History')),
              PopupMenuItem(value: 'help', child: Text('Help')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'contact', child: Text('Contact')),
              PopupMenuItem(value: 'about', child: Text('About')),
              PopupMenuItem(value: 'update', child: Text('Check for updates')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
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
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppTheme.hairlineStrong(dark),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(Icons.folder_open_outlined, size: 26, color: ink3),
            ),
            const SizedBox(height: 18),
            Text('No categories yet',
                style: AppTheme.display(size: 26, color: ink)),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to create your first category. A folder for the things you want to keep close.',
              textAlign: TextAlign.center,
              style: AppTheme.body(size: 14, color: ink3),
            ),
          ],
        ),
      ),
    );
  }

}

// ════════════════════════════════════════════════════════════════════
// Loading view
// ════════════════════════════════════════════════════════════════════

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text('Loading…', style: AppTheme.mono(size: 11, color: ink3)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Icon button (matches design: 36px round, ink2, hover surface)
// ════════════════════════════════════════════════════════════════════

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Category card
// ════════════════════════════════════════════════════════════════════

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onEdit,
    required this.onDelete,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onOpenTask,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onReorderTasks,
  });

  final Category category;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddTask;
  final void Function(Task) onToggleTask;
  final void Function(Task) onOpenTask;
  final void Function(Task) onEditTask;
  final void Function(Task) onDeleteTask;
  final void Function(int, int) onReorderTasks;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final ink4 = dark ? AppTheme.dInk4 : AppTheme.lInk4;
    final primary = Theme.of(context).colorScheme.primary;
    final total = category.totalCount;
    final done = category.completedCount;
    final pct = total == 0 ? 0.0 : done / total;

    return Dismissible(
      key: ValueKey('cat_${category.id}'),
      background: _swipeBg(
        align: Alignment.centerLeft,
        color: dark ? AppTheme.dInk2 : AppTheme.lInk2,
        label: 'EDIT',
        icon: Icons.edit_outlined,
      ),
      secondaryBackground: _swipeBg(
        align: Alignment.centerRight,
        color: dark ? AppTheme.dError : AppTheme.lError,
        label: 'DELETE',
        icon: Icons.delete_outline,
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onEdit();
        } else {
          onDelete();
        }
        return false;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.rMd),
          border: Border.all(
            color: expanded ? AppTheme.hairlineStrong(dark) : AppTheme.hairline(dark),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            InkWell(
              onTap: onToggleExpanded,
              borderRadius: BorderRadius.circular(AppTheme.rMd),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CatRing(progress: pct, size: 36, stroke: 2.5),
                          Text(
                            '${(pct * 100).round()}',
                            style: AppTheme.mono(size: 10, color: ink2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: AppTheme.display(size: 24, color: ink),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            total == 0
                                ? 'No tasks yet'
                                : '$done of $total · ${total - done} left',
                            style: AppTheme.mono(size: 11, color: ink3),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: Icon(Icons.chevron_right, size: 20, color: ink3),
                    ),
                  ],
                ),
              ),
            ),
            // Dots row when collapsed
            if (!expanded && total > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(66, 0, 18, 14),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final t in category.tasks)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: t.isCompleted ? primary : ink4,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            // Expanded body
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: AppTheme.hairline(dark)),
                  if (total == 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(56, 16, 22, 14),
                      child: Text(
                        'No tasks yet · tap below to add your first',
                        style: AppTheme.body(size: 13, color: ink3),
                      ),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: category.tasks.length,
                      onReorder: onReorderTasks,
                      proxyDecorator: (child, _, __) =>
                          Material(color: Colors.transparent, child: child),
                      itemBuilder: (ctx, i) {
                        final t = category.tasks[i];
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey('task_${t.id}'),
                          index: i,
                          child: _TaskRow(
                            task: t,
                            isLast: i == category.tasks.length - 1,
                            onToggle: () => onToggleTask(t),
                            onOpen: () => onOpenTask(t),
                            onEdit: () => onEditTask(t),
                            onDelete: () => onDeleteTask(t),
                          ),
                        );
                      },
                    ),
                  Container(height: 1, color: AppTheme.hairline(dark)),
                  InkWell(
                    onTap: onAddTask,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(56, 12, 22, 12),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 14, color: ink3),
                          const SizedBox(width: 8),
                          Text(
                            'ADD TASK',
                            style: AppTheme.mono(size: 11, color: ink3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }

  Widget _swipeBg({
    required Alignment align,
    required Color color,
    required String label,
    required IconData icon,
  }) {
    final isLeft = align == Alignment.centerLeft;
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
      ),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) Icon(icon, color: Colors.white, size: 18),
          if (isLeft) const SizedBox(width: 8),
          Text(label, style: AppTheme.mono(size: 11, color: Colors.white)),
          if (!isLeft) const SizedBox(width: 8),
          if (!isLeft) Icon(icon, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════════
// Task row
// ════════════════════════════════════════════════════════════════════

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.isLast,
    required this.onToggle,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });
  final Task task;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;

    return Dismissible(
      key: ValueKey('dismiss_${task.id}'),
      background: Container(
        color: (dark ? AppTheme.dInk2 : AppTheme.lInk2).withOpacity(0.08),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 56),
        child: Icon(Icons.edit_outlined, size: 18, color: ink3),
      ),
      secondaryBackground: Container(
        color: (dark ? AppTheme.dError : AppTheme.lError).withOpacity(0.10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        child: Icon(Icons.delete_outline, size: 18, color: dark ? AppTheme.dError : AppTheme.lError),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onEdit();
        } else {
          onDelete();
        }
        return false;
      },
      child: InkWell(
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 12, 18, 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(color: AppTheme.hairline(dark), width: 1),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Center(
                  child: _Checkbox(checked: task.isCompleted, onTap: onToggle),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StrikeText(
                      text: task.name,
                      done: task.isCompleted,
                      style: AppTheme.body(
                        size: 16,
                        color: task.isCompleted ? ink3 : ink,
                        weight: FontWeight.w400,
                      ),
                    ),
                    if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          task.description.replaceAll('\n', ' ').replaceAll('• ', '').trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.body(size: 13, color: ink3),
                        ),
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

/// Animated strike-through that grows left-to-right.
class _StrikeText extends StatelessWidget {
  const _StrikeText({required this.text, required this.done, required this.style});
  final String text;
  final bool done;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    return LayoutBuilder(
      builder: (_, c) => Stack(
        alignment: Alignment.centerLeft,
        children: [
          Text(text, style: style),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: done ? 0 : 0, end: done ? 1 : 0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => FractionallySizedBox(
                  widthFactor: v,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 1.5,
                    color: lineColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Sheets
// ════════════════════════════════════════════════════════════════════

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.eyebrow, required this.child, this.trailing});
  final String eyebrow;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final ink4 = dark ? AppTheme.dInk4 : AppTheme.lInk4;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.hairline(dark), width: 1)),
      ),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 14),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ink4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
            child: Row(
              children: [
                Text(eyebrow.toUpperCase(), style: AppTheme.eyebrow(ink3)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({
    required this.mode,
    required this.controller,
    required this.submitLabel,
    required this.onSubmit,
  });
  final String mode;
  final TextEditingController controller;
  final String submitLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    return _SheetShell(
      eyebrow: mode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: controller,
                autofocus: true,
                cursorColor: Theme.of(context).colorScheme.primary,
                textCapitalization: TextCapitalization.sentences,
                style: AppTheme.display(size: 24, color: ink),
                decoration: InputDecoration(
                  labelText: 'NAME',
                  hintText: 'A new beginning…',
                ),
                onSubmitted: (_) => onSubmit(),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    child: Text(submitLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskSheet extends StatefulWidget {
  const _TaskSheet({
    required this.mode,
    required this.submitLabel,
    required this.nameCtrl,
    required this.descCtrl,
    required this.onSubmit,
  });
  final String mode;
  final String submitLabel;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final VoidCallback onSubmit;

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  void _insert(String prefix) {
    final ctrl = widget.descCtrl;
    final text = ctrl.text;
    final sel = ctrl.selection;
    final offset = sel.isValid ? sel.baseOffset : text.length;
    final needsNl = offset > 0 && text[offset - 1] != '\n';
    final ins = (needsNl ? '\n' : '') + prefix;
    final nt = text.substring(0, offset) + ins + text.substring(offset);
    ctrl.value = TextEditingValue(
      text: nt,
      selection: TextSelection.collapsed(offset: offset + ins.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    return _SheetShell(
      eyebrow: widget.mode,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.nameCtrl,
              autofocus: true,
              cursorColor: Theme.of(context).colorScheme.primary,
              textCapitalization: TextCapitalization.sentences,
              style: AppTheme.display(size: 24, color: ink),
              decoration: const InputDecoration(
                labelText: 'NAME',
                hintText: 'What needs doing?',
              ),
            ),
            const SizedBox(height: 22),
            Text('DESCRIPTION', style: AppTheme.eyebrow(ink3)),
            const SizedBox(height: 8),
            TextField(
              controller: widget.descCtrl,
              cursorColor: Theme.of(context).colorScheme.primary,
              maxLines: 6,
              minLines: 3,
              style: AppTheme.body(size: 15, color: ink),
              decoration: InputDecoration(
                hintText: 'Add notes, steps, links…',
                hintStyle: AppTheme.body(size: 15, color: dark ? AppTheme.dInk4 : AppTheme.lInk4),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.hairline(dark), width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.hairline(dark), width: 1),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _FormatTool(
                  label: 'BULLET',
                  icon: Icons.format_list_bulleted,
                  onTap: () => _insert('• '),
                ),
                const SizedBox(width: 6),
                _FormatTool(
                  label: 'NUMBERED',
                  icon: Icons.format_list_numbered,
                  onTap: () => _insert('1. '),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onSubmit,
                    child: Text(widget.submitLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatTool extends StatelessWidget {
  const _FormatTool({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
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

// ════════════════════════════════════════════════════════════════════
// Task details sheet
// ════════════════════════════════════════════════════════════════════

class _TaskDetailsSheet extends StatelessWidget {
  const _TaskDetailsSheet({
    required this.category,
    required this.task,
    required this.scrollController,
    required this.onToggle,
    required this.onEdit,
  });
  final Category category;
  final Task task;
  final ScrollController scrollController;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final ink4 = dark ? AppTheme.dInk4 : AppTheme.lInk4;
    final success = dark ? AppTheme.dSuccess : AppTheme.lSuccess;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ink4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 14, 6),
            child: Row(
              children: [
                Text(
                  task.isCompleted ? 'COMPLETED' : 'OPEN',
                  style: AppTheme.eyebrow(task.isCompleted ? success : ink3),
                ),
                const Spacer(),
                _IconBtn(icon: Icons.edit_outlined, color: ink2, onTap: onEdit),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 12),
                      child: _Checkbox(checked: task.isCompleted, onTap: onToggle),
                    ),
                    Expanded(
                      child: Text(
                        task.name,
                        style: AppTheme.display(size: 30, color: ink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.rMd),
                    border: Border.all(color: AppTheme.hairline(dark), width: 1),
                  ),
                  child: task.description.trim().isEmpty
                      ? Text(
                          'No description.',
                          style: AppTheme.display(size: 17, color: ink3, style: FontStyle.italic),
                        )
                      : FormattedText(
                          text: task.description,
                          style: AppTheme.body(size: 14.5, color: ink, weight: FontWeight.w400)
                              .copyWith(height: 1.55),
                        ),
                ),
                const SizedBox(height: 22),
                _detailGrid(context, success, ink, ink3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailGrid(BuildContext context, Color success, Color ink, Color ink3) {
    final created = _Detail(
      label: 'CREATED',
      primary: _fmtDate(task.createdAt),
      secondary: _fmtTime(task.createdAt),
      ink: ink,
      ink3: ink3,
    );
    final status = _Detail(
      label: 'STATUS',
      primary: task.isCompleted ? 'Done' : 'In progress',
      primaryColor: task.isCompleted ? success : ink,
      ink: ink,
      ink3: ink3,
    );
    final completed = task.completedAt == null
        ? null
        : _Detail(
            label: 'COMPLETED',
            primary: _fmtDate(task.completedAt!),
            secondary: _fmtTime(task.completedAt!),
            ink: ink,
            ink3: ink3,
          );

    return Wrap(
      runSpacing: 18,
      spacing: 18,
      children: [
        SizedBox(width: 140, child: status),
        SizedBox(width: 140, child: created),
        if (completed != null) SizedBox(width: 140, child: completed),
      ],
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  String _fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';
  String _fmtTime(DateTime d) {
    final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.label,
    required this.primary,
    this.secondary,
    this.primaryColor,
    required this.ink,
    required this.ink3,
  });
  final String label;
  final String primary;
  final String? secondary;
  final Color? primaryColor;
  final Color ink;
  final Color ink3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.eyebrow(ink3)),
        const SizedBox(height: 4),
        Text(primary,
            style: AppTheme.display(size: 18, color: primaryColor ?? ink)),
        if (secondary != null) ...[
          const SizedBox(height: 2),
          Text(secondary!, style: AppTheme.mono(size: 11, color: ink3)),
        ],
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Confirmation dialog
// ════════════════════════════════════════════════════════════════════

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.onConfirm,
  });
  final String title;
  final String body;
  final String confirmLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.display(size: 24)),
            const SizedBox(height: 10),
            Text(body, style: AppTheme.body(size: 14, color: ink2).copyWith(height: 1.5)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
