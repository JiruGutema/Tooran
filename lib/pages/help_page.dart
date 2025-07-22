import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Guide'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const SizedBox(height: 32),

            // Managing Categories
            _buildSection(context, 'Managing Categories'),
            const SizedBox(height: 16),
            ..._buildActionsList(context, [
              {
                'title': 'Create Category',
                'description': 'Tap the + button and enter a category name',
                'gesture': '',
              },
              {
                'title': 'Edit Category',
                'description':
                    'Swipe left on a category to access edit options',
                'gesture': '',
              },
              {
                'title': 'Delete Category',
                'description':
                    'Swipe right on a category to delete (can be recovered from history)',
                'gesture': '',
              },
              {
                'title': 'Reorder Categories',
                'description':
                    'Long press and drag categories to change their order',
                'gesture': '',
              },
            ]),

            const SizedBox(height: 32),

            // Working with Tasks
            _buildSection(context, 'Working with Tasks'),
            const SizedBox(height: 16),
            ..._buildActionsList(context, [
              {
                'title': 'Add Task',
                'description':
                    'Expand a category and use the input field to add tasks with optional descriptions',
                'gesture': '',
              },
              {
                'title': 'Complete Task',
                'description':
                    'Tap the checkbox next to a task to mark it as completed',
                'gesture': '',
              },
              {
                'title': 'Edit Task',
                'description':
                    'Swipe left on a task to edit its name and description',
                'gesture': '',
              },
              {
                'title': 'Delete Task',
                'description': 'Swipe right on a task to delete it permanently',
                'gesture': '',
              },
              {
                'title': 'Reorder Tasks',
                'description':
                    'Long press and drag tasks within a category to reorder them',
                'gesture': '',
              },
            ]),

            const SizedBox(height: 32),

            // Advanced Features
            _buildSection(context, 'Advanced Features'),
            const SizedBox(height: 16),
            ..._buildFeaturesList(context, [
              {
                'title': 'Theme Switching',
                'description':
                    'Switch between light and dark themes from the app menu. Your preference is automatically saved.',
              },
              {
                'title': 'Auto-Save',
                'description':
                    'All your data is automatically saved locally. No internet connection required.',
              },
              {
                'title': 'Category Recovery',
                'description':
                    'Deleted categories can be recovered from the History page in the app menu.',
              },
              {
                'title': 'Progress Analytics',
                'description':
                    'Visual progress bars show completion percentage for each category in real-time.',
              },
            ]),

            const SizedBox(height: 32),

            // Tips & Tricks
            _buildSection(context, 'Tips & Tricks'),
            const SizedBox(height: 16),
            ..._buildTipsList(context, [
              {
                'tip':
                    'Use descriptive category names like "Work Projects" instead of just "Work" for better organization.',
              },
              {
                'tip':
                    'Break large tasks into smaller, manageable sub-tasks for better progress tracking.',
              },
              {
                'tip':
                    'Use the drag and drop feature to prioritize tasks by moving important ones to the top.',
              },
              {
                'tip':
                    'Check the progress bars regularly to stay motivated and see your accomplishments.',
              },
              {
                'tip':
                    'Don\'t worry about accidentally deleting categories - they can be recovered from History.',
              },
              {
                'tip':
                    'Switch to dark theme for comfortable use in low-light environments.',
              },
            ]),

            const SizedBox(height: 32),

            // Troubleshooting
            _buildSection(context, 'Troubleshooting'),
            const SizedBox(height: 16),
            ..._buildTroubleshootingList(context, [
              {
                'problem': 'My tasks disappeared',
                'solution':
                    'Tasks are automatically saved. Try restarting the app. If the issue persists, check if you accidentally deleted the category - it can be recovered from History.',
              },
              {
                'problem': 'App is running slowly',
                'solution':
                    'Try closing and reopening the app. If you have many completed tasks, consider cleaning them up for better performance.',
              },
              {
                'problem': 'Can\'t drag and drop items',
                'solution':
                    'Make sure to long press the item first, then drag. Ensure you\'re not trying to drag while the category is collapsed.',
              },
              {
                'problem': 'Theme not switching',
                'solution':
                    'Go to the app menu and select your preferred theme. The change should be immediate. Try restarting the app if needed.',
              },
            ]),

            const SizedBox(height: 32),

            // Support Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Still Need Help?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'If you\'re still experiencing issues, please visit the Contact page to get in touch with our support team. We\'re here to help!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionsList(
      BuildContext context, List<Map<String, dynamic>> actions) {
    final theme = Theme.of(context);

    return actions
        .map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                action['title'] as String,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if ((action['gesture'] as String).isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    action['gesture'] as String,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            action['description'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _buildFeaturesList(
      BuildContext context, List<Map<String, dynamic>> features) {
    final theme = Theme.of(context);

    return features
        .map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feature['description'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _buildTipsList(
      BuildContext context, List<Map<String, dynamic>> tips) {
    final theme = Theme.of(context);

    return tips
        .map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        tip['tip'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _buildTroubleshootingList(
      BuildContext context, List<Map<String, dynamic>> issues) {
    final theme = Theme.of(context);

    return issues
        .map((issue) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue['problem'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      issue['solution'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }
}
