import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://tooran-documentation.vercel.app');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tooran',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(33,44,57,1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Color.fromRGBO(23, 33, 43,1),
   
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle('Getting Started'),
 
            _buildSection(
              icon: Icons.info_outline,
              title: 'App Overview',
              content:
                  'Tooran allows you to manage tasks within categories. Create categories, add tasks, and manage them efficiently with features like task completion and deletion. \n\n'
                  'Tooran offers an easy-to-use interface and intuitive functionality to enhance your productivity. The biggest update yet to come',
            ),
              _buildSection(
                icon: Icons.star_border,
                title: 'Unique Features',
                content:
                    '• No Ads 😮‍💨\n'
                    '• Simple, intuitive design.\n'
                    '• Organize tasks into categories for better management.\n'
                    '• Automatic real-time updates.\n',
              ),
              _buildTitle('How to Use the App'),
              _buildSection(
                icon: Icons.category_outlined,
                title: 'Adding a Category',
                content:
                    '1. Tap the (+) button at the bottom of the app to create a new category.\n'
                    '2. Enter the category name and tap (✔) to save it.',
              ),
              _buildSection(
                icon: Icons.task_alt,
                title: 'Adding a Task',
                content:
                    '1. Expand a category by tapping it.\n'
                    '2. Tap the (+) button inside the category to add a new task.\n'
                    '3. Enter the task name and tap (✔) (it might not work for the first time) to save it.',
              ),
              _buildSection(
                icon: Icons.check_circle_outline,
                title: 'Marking a Task as Completed',
                content:
                  '• Tap the checkbox next to a task to mark it as completed.\n'
                  '• Completed tasks appear with a faded grey color.\n'
                  '• There is a progress bar showing your progress at the top of each category.',
              ),
              _buildSection(
                icon: Icons.delete_outline,
                title: 'Deleting a Task or Category',
                content:
                    '• To delete a task, swipe it to the left. A Snackbar will appear with an Undo button (available for 4 seconds) to restore the task if needed.\n'
                    '• To delete a catagory, swipe to the left. if you did it by mistake, you can undo it within 4 sec.'
                    '• To Edit  a task, swipe to the right. if you did it by mistake, you can undo it within 4 sec again.',
              ),
              _buildSection(
                icon: Icons.drag_handle,
                title: 'Reordering Items',
                content:
                    '• Use the longpress on tasks to reorder them as desired.\n'
                    '• Use the longpress on the expansion button categories to reorder catagories as desired.\n'
                    '• Simply press and hold the container, then drag the item to its new position.',
              ),
              _buildSection(
                icon: Icons.tips_and_updates,
                title: 'Tips',
                content:
                    '• When you try to add the tasks for the first time. It might not add it to the cataory. try disabling the Textfield and reopening it.\n'
                    '• Avoid opening multiple text fields at once to keep the interface clear.\n'
                    '• Close an open input field before starting another.',
              ),
              _buildSection(
                icon: Icons.system_update,
                title: 'Upcoming Updates',
                content:
                    '• Add detail on the touch for each tasks\n'
                    '• Widgets Integration\n'
                    '• Notification Support\n'
                    '• Time-Based Categorization\n',
              ),
              _buildSection(
                icon: Icons.help_outline,
                title: 'Need Assistance or Suggestion?',
                content:
                    'For help, inquiries, or suggestions, please reach out:\n\n'
                    'Email: \n\njethior1@gmail.com\njirudagutema@gmail.com',
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _launchURL,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Color.fromRGBO(34, 46, 59, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: const Text(
                    'Check for Updates',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color:Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }


 Widget _buildSection({required IconData icon, required String title, required String content}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    color: Color.fromRGBO(33,44,57,1),
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 26, color: Colors.white), // Fixed icon color
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    ),
  );
}}