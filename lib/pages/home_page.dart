import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tooran/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../models/category.dart';
import '../models/deleted_category.dart';
import '../models/task.dart';
import '../services/data_service.dart';
import '../widgets/formatted_text.dart';
import '../widgets/glass_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataService _dataService = DataService();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();

  List<Category> _categories = [];
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _saveData() async {
    try {
      await _dataService.saveCategories(_categories);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  // ─── Bottom Sheet Helper ────────────────────────────────────────────

  Widget _buildBottomSheet({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppTheme.radius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.surface.withOpacity(0.9),
                colorScheme.surface.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colorScheme.onSurface.withOpacity(0.08),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }

  // ─── Description Formatting Helpers ─────────────────────────────────

  Widget _buildFormattingToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolbarButton(
            icon: Icons.format_list_bulleted_rounded,
            tooltip: 'Add bullet point',
            onTap: _insertBullet,
          ),
          Container(
            width: 1,
            height: 20,
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 2),
          ),
          _buildToolbarButton(
            icon: Icons.format_list_numbered_rounded,
            tooltip: 'Add numbered item',
            onTap: _insertNumbered,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }

  void _insertBullet() {
    final controller = _taskDescriptionController;
    final text = controller.text;
    final sel = controller.selection;
    final offset = sel.isValid ? sel.baseOffset : text.length;
    final prefix = (text.isEmpty || (offset > 0 && text[offset - 1] == '\n') || offset == 0)
        ? '\u2022 '
        : '\n\u2022 ';
    final newText = text.substring(0, offset) + prefix + text.substring(offset);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset + prefix.length),
    );
  }

  void _insertNumbered() {
    final controller = _taskDescriptionController;
    final text = controller.text;
    final lines = text.split('\n');
    int lastNumber = 0;
    for (final line in lines) {
      final match = RegExp(r'^(\d+)\.\s').firstMatch(line.trim());
      if (match != null) {
        lastNumber = int.parse(match.group(1)!);
      }
    }
    final sel = controller.selection;
    final offset = sel.isValid ? sel.baseOffset : text.length;
    final numStr = '${lastNumber + 1}. ';
    final prefix = (text.isEmpty || (offset > 0 && text[offset - 1] == '\n') || offset == 0)
        ? numStr
        : '\n$numStr';
    final newText = text.substring(0, offset) + prefix + text.substring(offset);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset + prefix.length),
    );
  }

  // ─── Category Management ────────────────────────────────────────────

  void _showAddCategoryDialog() {
    _categoryController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        title: 'New Category',
        icon: Icons.create_new_folder_outlined,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Work Projects, Shopping List',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _addCategory(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _categoryController.clear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addCategory(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory() {
    final name = _categoryController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    if (_categories
        .any((cat) => cat.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name already exists')),
      );
      return;
    }

    final newCategory = Category(
      name: name,
      sortOrder: _categories.length,
    );

    setState(() {
      _categories.add(newCategory);
    });

    _saveData();
    _categoryController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category "$name" added')),
    );
  }

  void _showEditCategoryDialog(Category category) {
    _categoryController.text = category.name;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        title: 'Edit Category',
        icon: Icons.edit_outlined,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _editCategory(category),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _categoryController.clear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editCategory(category),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).then((_) {
      _categoryController.clear();
    });
  }

  void _editCategory(Category category) {
    final name = _categoryController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    if (_categories.any((cat) =>
        cat.id != category.id &&
        cat.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name already exists')),
      );
      return;
    }

    setState(() {
      final index = _categories.indexWhere((cat) => cat.id == category.id);
      if (index != -1) {
        _categories[index] = category.copyWith(name: name);
      }
    });

    _saveData();
    _categoryController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category renamed to "$name"')),
    );
  }

  void _showDeleteCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${category.name}"?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (category.totalCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${category.totalCount} task(s) will be moved to history.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteCategory(category),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      final deletedCategory = DeletedCategory.fromCategory(category);

      final deletedCategories =
          await _dataService.loadDeletedCategoriesWithRecovery();
      deletedCategories.add(deletedCategory);
      await _dataService.saveDeletedCategories(deletedCategories);

      setState(() {
        _categories.removeWhere((cat) => cat.id == category.id);
        for (int i = 0; i < _categories.length; i++) {
          _categories[i] = _categories[i].copyWith(sortOrder: i);
        }
      });

      await _saveData();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${category.name}" deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _undoDeleteCategory(deletedCategory),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting category: $e')),
        );
      }
    }
  }

  Future<void> _undoDeleteCategory(DeletedCategory deletedCategory) async {
    try {
      final deletedCategories =
          await _dataService.loadDeletedCategoriesWithRecovery();
      deletedCategories.removeWhere((dc) => dc.id == deletedCategory.id);
      await _dataService.saveDeletedCategories(deletedCategories);

      final restoredCategory = deletedCategory.toCategory();
      setState(() {
        _categories.add(restoredCategory);
        _categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      });

      await _saveData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Category "${restoredCategory.name}" restored')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error restoring category: $e')),
        );
      }
    }
  }

  void _reorderCategories(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final category = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, category);

      for (int i = 0; i < _categories.length; i++) {
        _categories[i] = _categories[i].copyWith(sortOrder: i);
      }
    });

    _saveData();
  }

  // ─── Task Management ────────────────────────────────────────────────

  void _showAddTaskDialog(Category category) {
    _taskNameController.clear();
    _taskDescriptionController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        title: 'New Task',
        icon: Icons.add_task_rounded,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'What needs to be done?',
                prefixIcon: Icon(Icons.task_outlined),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) {
                // Move focus to description
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                _buildFormattingToolbar(),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _taskDescriptionController,
              decoration: const InputDecoration(
                hintText: 'Add details, steps, or notes...\nUse toolbar for formatting',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              minLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _taskNameController.clear();
                      _taskDescriptionController.clear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addTask(category),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTask(Category category) {
    final name = _taskNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task name')),
      );
      return;
    }

    final newTask = Task(
      name: name,
      description: _taskDescriptionController.text.trim(),
    );

    setState(() {
      final categoryIndex =
          _categories.indexWhere((cat) => cat.id == category.id);
      if (categoryIndex != -1) {
        _categories[categoryIndex].addTask(newTask);
      }
    });

    _saveData();
    _taskNameController.clear();
    _taskDescriptionController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "$name" added to ${category.name}')),
    );
  }

  void _showEditTaskDialog(Category category, Task task) {
    _taskNameController.text = task.name;
    _taskDescriptionController.text = task.description;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        title: 'Edit Task',
        icon: Icons.edit_outlined,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'Enter task name',
                prefixIcon: Icon(Icons.task_outlined),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                _buildFormattingToolbar(),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _taskDescriptionController,
              decoration: const InputDecoration(
                hintText: 'Add details, steps, or notes...',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              minLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _taskNameController.clear();
                      _taskDescriptionController.clear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editTask(category, task),
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).then((_) {
      _taskNameController.clear();
      _taskDescriptionController.clear();
    });
  }

  void _editTask(Category category, Task task) {
    final name = _taskNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task name')),
      );
      return;
    }

    final updatedTask = task.copyWith(
      name: name,
      description: _taskDescriptionController.text.trim(),
    );

    setState(() {
      final categoryIndex =
          _categories.indexWhere((cat) => cat.id == category.id);
      if (categoryIndex != -1) {
        _categories[categoryIndex].updateTask(updatedTask);
      }
    });

    _saveData();
    _taskNameController.clear();
    _taskDescriptionController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "$name" updated')),
    );
  }

  void _showDeleteTaskDialog(Category category, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task?'),
        content: Text(
          'Are you sure you want to delete "${task.name}"?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteTask(category, task),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(Category category, Task task) {
    setState(() {
      final categoryIndex =
          _categories.indexWhere((cat) => cat.id == category.id);
      if (categoryIndex != -1) {
        _categories[categoryIndex].removeTask(task);
      }
    });

    _saveData();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "${task.name}" deleted')),
    );
  }

  void _toggleTaskCompletion(Category category, Task task) {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );

    setState(() {
      final categoryIndex =
          _categories.indexWhere((cat) => cat.id == category.id);
      if (categoryIndex != -1) {
        _categories[categoryIndex].updateTask(updatedTask);
      }
    });

    _saveData();

    if (updatedTask.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${task.name}" completed'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showTaskDetails(Task task) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (context, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface.withOpacity(0.95),
                    colorScheme.surface.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.08),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title + status row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    task.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked,
                    color: task.isCompleted
                        ? AppTheme.success
                        : colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description section
              if (task.description.isNotEmpty) ...[
                Text(
                  'Description',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FormattedText(
                    text: task.description,
                    style: textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Details section
              Text(
                'Details',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      'Status',
                      task.isCompleted ? 'Completed' : 'Pending',
                    ),
              
                    _buildDetailRow(
                      context,
                      'Created',
                      _formatDate(task.createdAt),
                    ),
                    if (task.completedAt != null) ...[
      
                      _buildDetailRow(
                        context,
                        'Completed',
                        _formatDate(task.completedAt!),
                      ),
                    ],
                  ],
                ),
              ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _reorderTasks(Category category, int oldIndex, int newIndex) {
    setState(() {
      final categoryIndex =
          _categories.indexWhere((cat) => cat.id == category.id);
      if (categoryIndex != -1) {
        _categories[categoryIndex].reorderTasks(oldIndex, newIndex);
      }
    });

    _saveData();
  }

  // ─── UI Build Methods ───────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 20),
            Text(
              'No categories yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a category to start organizing your tasks',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _categories.length,
      onReorder: _reorderCategories,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(16),
            child: child,
          ),
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category, index);
      },
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    final progressColor =
        Provider.of<ThemeProvider>(context).getProgressColor(category.progressPercentage);

    return Dismissible(
      key: ValueKey(category.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(width: 8),
            Icon(Icons.delete_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showEditCategoryDialog(category);
          return false;
        } else {
          _showDeleteCategoryDialog(category);
          return false;
        }
      },
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: GlassContainer(
          margin: const EdgeInsets.symmetric(vertical: 6),
          borderRadius: BorderRadius.circular(16),
          child: ExpansionTile(
            shape: const Border(),
            key: ValueKey('expansion_${category.id}'),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: category.totalCount > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${category.completedCount} of ${category.totalCount} completed',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(category.progressPercentage * 100).toInt()}%',
                            style: TextStyle(
                              color: progressColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: category.progressPercentage,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'No tasks yet',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
            children: [
              // const Divider(height: 1),
              if (category.tasks.isNotEmpty)
                ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: category.tasks.length,
                  onReorder: (oldIndex, newIndex) =>
                      _reorderTasks(category, oldIndex, newIndex),
                  itemBuilder: (context, taskIndex) {
                    final task = category.tasks[taskIndex];
                    return _buildTaskItem(category, task, taskIndex);
                  },
                ),

              // Add task button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: TextButton.icon(
                  onPressed: () => _showAddTaskDialog(category),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Add Task'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary                    // backgroundColor: AppTheme.primary.withOpacity(1),
                  ),
                ),
              ),

              if (category.tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'No tasks yet. Tap "Add Task" to get started!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Category category, Task task, int taskIndex) {
    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        color: Colors.blue.withOpacity(0.1),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.edit_rounded, color: Colors.blue, size: 22),
      ),
      secondaryBackground: Container(
        color: Colors.red.withOpacity(0.1),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_rounded, color: Colors.red, size: 22),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showEditTaskDialog(category, task);
          return false;
        } else {
          _showDeleteTaskDialog(category, task);
          return false;
        }
      },
      child: ReorderableDelayedDragStartListener(
        index: taskIndex,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: (value) => _toggleTaskCompletion(category, task),
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        title: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Text(
              task.name,
              style: themeProvider.getTaskTextStyle(task.isCompleted),
            );
          },
        ),
        subtitle: task.description.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  task.description.replaceAll('\n', ' ').replaceAll('\u2022 ', '').trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : null,
        onTap: () => _showTaskDetails(task),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF050816),
                  Color(0xFF111827),
                  Color(0xFF020617),
                ]
              : const [
                  Color(0xFFE0F4FF),
                  Color(0xFFF5E9FF),
                  Color(0xFFE8F3FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Tooran',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
          ),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      key: ValueKey(themeProvider.isDarkMode),
                    ),
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                  tooltip: 'Toggle theme',
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              tooltip: 'More options',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              position: PopupMenuPosition.under,
              onSelected: (value) {
                switch (value) {
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
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'history',
                  child: ListTile(
                    leading: Icon(Icons.history_rounded),
                    title: Text('History'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'help',
                  child: ListTile(
                    leading: Icon(Icons.help_outline_rounded),
                    title: Text('Help'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'contact',
                  child: ListTile(
                    leading: Icon(Icons.contact_mail_outlined),
                    title: Text('Contact'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'about',
                  child: ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('About'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'update',
                  child: ListTile(
                    leading: Icon(Icons.system_update_rounded),
                    title: Text('Check for Updates'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? Center(
                  key: const ValueKey('loading'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading your tasks...',
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : _categories.isEmpty
                  ? _buildEmptyState()
                  : _buildCategoryList(),
        ),
        floatingActionButton: AnimatedScale(
          scale: _isLoading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton.extended(
            backgroundColor: AppTheme.primary,
            onPressed: _isLoading ? null : _showAddCategoryDialog,
            tooltip: 'Add Category',
            icon: const Icon(Icons.add_rounded),
            label: const Text('Category'),
          ),
        ),
      ),
    );
  }
}
