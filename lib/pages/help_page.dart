import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to use Task Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Getting Started',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Tap the + button to create a new category\n'
              '2. Tap on a category to expand and add tasks\n'
              '3. Check off tasks as you complete them\n'
              '4. Swipe tasks to edit or delete them',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Organize tasks by categories\n'
              '• Track progress with visual indicators\n'
              '• Drag and drop to reorder items\n'
              '• Dark and light theme support\n'
              '• Automatic data saving',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}