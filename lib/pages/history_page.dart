import 'package:flutter/material.dart';
import '../models/deleted_category.dart';
import '../services/data_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DataService _dataService = DataService();
  List<DeletedCategory> _deletedCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedCategories();
  }

  Future<void> _loadDeletedCategories() async {
    try {
      setState(() => _isLoading = true);
      final deletedCategories = await _dataService.loadDeletedCategoriesWithRecovery();
      setState(() {
        _deletedCategories = deletedCategories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading deleted categories: $e')),
        );
      }
    }
  }

  Future<void> _restoreCategory(DeletedCategory deletedCategory) async {
    try {
      // Load current active categories
      final activeCategories = await _dataService.loadCategoriesWithRecovery();
      
      // Convert deleted category back to active category
      final restoredCategory = deletedCategory.toCategory();
      activeCategories.add(restoredCategory);
      
      // Save updated active categories
      await _dataService.saveCategories(activeCategories);
      
      // Remove from deleted categories
      _deletedCategories.removeWhere((dc) => dc.id == deletedCategory.id);
      await _dataService.saveDeletedCategories(_deletedCategories);
      
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${deletedCategory.name}" restored'),
            backgroundColor: Colors.green,
          ),
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

  Future<void> _permanentlyDeleteCategory(DeletedCategory deletedCategory) async {
    try {
      _deletedCategories.removeWhere((dc) => dc.id == deletedCategory.id);
      await _dataService.saveDeletedCategories(_deletedCategories);
      
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${deletedCategory.name}" permanently deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting category: $e')),
        );
      }
    }
  }

  void _showRestoreDialog(DeletedCategory deletedCategory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restore Category?'),
        content: Text(
          'Restore "${deletedCategory.name}" with ${deletedCategory.tasks.length} task(s)?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreCategory(deletedCategory);
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showPermanentDeleteDialog(DeletedCategory deletedCategory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Forever?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permanently delete "${deletedCategory.name}"?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _permanentlyDeleteCategory(deletedCategory);
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDetails(DeletedCategory deletedCategory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                deletedCategory.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Deleted: ${_formatDate(deletedCategory.deletedAt)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tasks (${deletedCategory.tasks.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              if (deletedCategory.tasks.isEmpty)
                Text(
                  'No tasks in this category',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                ...deletedCategory.tasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              task.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 20,
                              color: task.isCompleted ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                task.name,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isCompleted
                                      ? Theme.of(context).colorScheme.onSurfaceVariant
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No deleted categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Deleted categories will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _deletedCategories.length,
      itemBuilder: (context, index) {
        final deletedCategory = _deletedCategories[index];
        final completedTasks = deletedCategory.tasks.where((task) => task.isCompleted).length;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: const Icon(Icons.folder_delete_outlined, size: 22),
            title: Text(
              deletedCategory.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${deletedCategory.tasks.length} task(s) • $completedTasks completed',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Deleted: ${_formatDate(deletedCategory.deletedAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'restore':
                    _showRestoreDialog(deletedCategory);
                    break;
                  case 'delete':
                    _showPermanentDeleteDialog(deletedCategory);
                    break;
                  case 'details':
                    _showCategoryDetails(deletedCategory);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'restore',
                  child: ListTile(
                    leading: Icon(Icons.restore, color: Colors.green),
                    title: Text('Restore'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'details',
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('View Details'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text('Delete Forever'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
              onTap: () => _showCategoryDetails(deletedCategory),
            ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (_deletedCategories.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDeletedCategories,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deletedCategories.isEmpty
              ? _buildEmptyState()
              : _buildDeletedCategoryList(),
    );
  }
}