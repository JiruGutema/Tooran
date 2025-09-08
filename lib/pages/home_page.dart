import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tooran/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../models/category.dart';
import '../models/deleted_category.dart';
import '../models/task.dart';
import '../services/data_service.dart';

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

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: _categoryController,
          decoration: InputDecoration(
            labelText: 'Category Name',
            hintText: 'Enter category name',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: AppTheme.primary,
                width: 2,
              ),
            ),
          ),
          autofocus: true,
          onSubmitted: (_) => _addCategory(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _categoryController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addCategory(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) {
      _categoryController.clear();
    });
  }

  void _addCategory() {
    final name = _categoryController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    // Check for duplicate names
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'Enter category name',
          ),
          autofocus: true,
          onSubmitted: (_) => _editCategory(category),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _categoryController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _editCategory(category),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Save'),
          ),
        ],
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

    // Check for duplicate names (excluding current category)
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${category.name}"?'),
            if (category.totalCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'This category contains ${category.totalCount} task(s). They will be moved to history and can be restored later.',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteCategory(category),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      // Create deleted category for history
      final deletedCategory = DeletedCategory.fromCategory(category);

      // Load existing deleted categories and add this one
      final deletedCategories =
          await _dataService.loadDeletedCategoriesWithRecovery();
      deletedCategories.add(deletedCategory);
      await _dataService.saveDeletedCategories(deletedCategories);

      // Remove from active categories
      setState(() {
        _categories.removeWhere((cat) => cat.id == category.id);
        // Update sort orders
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
      // Remove from deleted categories
      final deletedCategories =
          await _dataService.loadDeletedCategoriesWithRecovery();
      deletedCategories.removeWhere((dc) => dc.id == deletedCategory.id);
      await _dataService.saveDeletedCategories(deletedCategories);

      // Restore to active categories
      final restoredCategory = deletedCategory.toCategory();
      setState(() {
        _categories.add(restoredCategory);
        // Sort by original sort order
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

      // Update sort orders
      for (int i = 0; i < _categories.length; i++) {
        _categories[i] = _categories[i].copyWith(sortOrder: i);
      }
    });

    _saveData();
  }

  // Task Management Methods
  void _showAddTaskDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Add Task',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  hintText: 'Enter task name',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: AppTheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                autofocus: true,
                onSubmitted: (_) => _addCategory(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _taskDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  hintText: 'Enter task description',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: AppTheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 8,
                onSubmitted: (_) => _addTask(category),
                minLines: 2,
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () {
              _taskNameController.clear();
              _taskDescriptionController.clear();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addTask(category),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) {
      _taskNameController.clear();
      _taskDescriptionController.clear();
    });
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                labelText: 'Task Name',
                hintText: 'Enter task name',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
              autofocus: true,
              onSubmitted: (_) => _addTask(category),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _taskDescriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                hintText: 'Enter task description',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                  // Set a minimum height for the description field
                ),
              ),
              maxLines: 8,
              onSubmitted: (_) => _addTask(category),
              // Set a minimum height for the description field
              minLines: 2,

              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _taskNameController.clear();
              _taskDescriptionController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _editTask(category, task),
            child: const Text('Save'),
          ),
        ],
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
        content: Text('Are you sure you want to delete "${task.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteTask(category, task),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
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

    // Show completion feedback
    if (updatedTask.isCompleted) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          content: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accentNeon],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Task "${task.name}" completed!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: 0.2,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: themeProvider.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 8,
        ),
      );
    }
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.check_circle : Icons.info_outline,
              color: task.isCompleted ? Colors.green : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.name,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints:
                    BoxConstraints(maxHeight: 200, maxWidth: double.infinity),
                child: Container(
                  width: double.infinity, // Make width full
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.04)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: const Radius.circular(8),
                    thickness: 4,
                    child: SingleChildScrollView(
                      child: Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Text(
                  'Status: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  task.isCompleted ? "Completed" : "Pending",
                  style: TextStyle(
                    color: task.isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(task.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (task.completedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Completed: ${_formatDate(task.completedAt!)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
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

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.task_alt,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Tooran!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Organize your tasks into categories\nand stay productive',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Or explore the app features in Help',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _categories.length,
      onReorder: _reorderCategories,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Dismissible(
          key: ValueKey(category.id),
          background: Container(
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 28,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 28,
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Edit action
              _showEditCategoryDialog(category);
              return false; // Don't dismiss
            } else {
              // Delete action
              _showDeleteCategoryDialog(category);
              return false; // Don't dismiss, let dialog handle it
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              key: ValueKey('expansion_${category.id}'),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_handle,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
              subtitle: category.totalCount > 0
                  ? Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${category.completedCount} of ${category.totalCount} completed',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: category.progressPercentage,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                themeProvider.getProgressColor(
                                    category.progressPercentage),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const Text('No tasks yet'),
              children: [
                // Task list with reordering
                if (category.tasks.isNotEmpty)
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: category.tasks.length,
                    onReorder: (oldIndex, newIndex) =>
                        _reorderTasks(category, oldIndex, newIndex),
                    itemBuilder: (context, taskIndex) {
                      final task = category.tasks[taskIndex];
                      return Dismissible(
                        key: ValueKey(task.id),
                        background: Container(
                          color: Colors.blue,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            // Edit action
                            _showEditTaskDialog(category, task);
                            return false; // Don't dismiss
                          } else {
                            // Delete action
                            _showDeleteTaskDialog(category, task);
                            return false; // Don't dismiss, let dialog handle it
                          }
                        },
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) =>
                                    _toggleTaskCompletion(category, task),
                                visualDensity: VisualDensity.compact,
                              ),
                              ReorderableDragStartListener(
                                index: taskIndex,
                                child: Icon(
                                  Icons.drag_handle,
                                  color: Colors.transparent,
                                  size: 0,
                                ),
                              ),
                            ],
                          ),
                          title: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return Text(
                                task.name,
                                style: themeProvider
                                    .getTaskTextStyle(task.isCompleted),
                              );
                            },
                          ),
                          /*    subtitle: task.description.isNotEmpty
                              ? Text(
                                  task.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null, */
                          onTap: () => _showTaskDetails(task),
                        ),
                      );
                    },
                  ),

                // Add task button
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: TextButton.icon(
                    onPressed: () => _showAddTaskDialog(category),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 126, 153, 175),
                    ),
                  ),
                ),

                // Empty state for tasks
                if (category.tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No tasks in this category yet.\nTap "Add Task" to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text('Tooran'),
          ],
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    key: ValueKey(themeProvider.isDarkMode),
                  ),
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: 'Toggle theme',
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            tooltip: 'More options',
            color: Theme.of(context).scaffoldBackgroundColor,
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
                case "update":
                  launchUrl(Uri.parse("https://tooran.vercel.app"));
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'history',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('History'),
                  minLeadingWidth: 10,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help_outline),
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
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'update',
                child: ListTile(
                  leading: Icon(Icons.update),
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
            ? const Center(
                key: ValueKey('loading'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading your tasks...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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
        child: FloatingActionButton(
          onPressed: _isLoading ? null : _showAddCategoryDialog,
          tooltip: 'Add Category',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
