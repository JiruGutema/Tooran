import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
        
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How to Use the App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  icon: Icons.category,
                  title: '1. Adding a Category:',
                  content:
                      '   - Enter the category name in the input field at the top.\n'
                      '   - Tap the add (+) button to create a new category.',
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  icon: Icons.task,
                  title: '2. Adding a Task:',
                  content:
                      '   - Tap on an existing category to expand it.\n'
                      '   - Tap the add (+) button inside the category to input a new task.\n'
                      '   - Enter the task name and press the check (✔) button to save it.',
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  icon: Icons.check_circle,
                  title: '3. Marking a Task as Completed:',
                  content:
                      '   - Tap on the checkbox next to a task to mark it as completed.\n'
                      '   - Completed tasks will be displayed with a strikethrough.',
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  icon: Icons.delete,
                  title: '4. Deleting a Task or Category:',
                  content:
                      '   - Long-press on a category name to see delete options.\n'
                      '   - Long-press on a task to delete it from a category.',
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  icon: Icons.navigation,
                  title: '5. Navigating the App:',
                  content:
                      '   - Use the top navigation bar to switch between Home, Help, and Contact pages.',
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                      ),
                      elevation: 5.0,
                      shadowColor: Colors.black26,
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
      ),
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Colors.teal),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}