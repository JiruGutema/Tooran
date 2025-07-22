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
        title: const Text('Restore Category'),
        content: Text('Restore "${deletedCategory.name}" with ${deletedCategory.tasks.length} task(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreCategory(deletedCategory);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
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
        title: const Text('Permanent Delete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permanently delete "${deletedCategory.name}"?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone. All tasks in this category will be lost forever.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _permanentlyDeleteCategory(deletedCategory);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDetails(DeletedCategory deletedCategory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(deletedCategory.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deleted: ${_formatDate(deletedCategory.deletedAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tasks (${deletedCategory.tasks.length}):',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (deletedCategory.tasks.isEmpty)
              const Text(
                'No tasks in this category',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...deletedCategory.tasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 16,
                          color: task.isCompleted ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.name,
                            style: TextStyle(
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted ? Colors.grey : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Deleted Categories',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deleted categories will appear here and can be restored',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _deletedCategories.length,
      itemBuilder: (context, index) {
        final deletedCategory = _deletedCategories[index];
        final completedTasks = deletedCategory.tasks.where((task) => task.isCompleted).length;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
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