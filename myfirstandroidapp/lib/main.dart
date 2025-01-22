import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tooran',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFB2FF14)),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      home: const MyHomePage(title: 'Tooran'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<String, List<Map<String, dynamic>>> _categories = {};
  final Map<String, TextEditingController> _taskControllers = {};
  final Map<String, bool> _showTaskInput = {};

  void _addCategory(String categoryName) {
    if (categoryName.isNotEmpty) {
      setState(() {
        _categories[categoryName] = [];
        _taskControllers[categoryName] = TextEditingController();
        _showTaskInput[categoryName] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$categoryName" added successfully!'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
        ),
      );
    }
  }

  void _editCategory(String oldName) {
    TextEditingController editController = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              String newName = editController.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                setState(() {
                  _categories[newName] = _categories.remove(oldName)!;
                  _taskControllers[newName] = _taskControllers.remove(oldName)!;
                  _showTaskInput[newName] = _showTaskInput.remove(oldName)!;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Category "$oldName" renamed to "$newName".'),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
                  ),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String category) {
    setState(() {
      _categories.remove(category);
      _taskControllers.remove(category);
      _showTaskInput.remove(category);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "$category" deleted successfully!'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
      ),
    );
  }

  void _showCategoryOptions(String category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Category'),
            onTap: () {
              Navigator.of(context).pop();
              _editCategory(category);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Category'),
            onTap: () {
              Navigator.of(context).pop();
              _deleteCategory(category);
            },
          ),
        ],
      ),
    );
  }

  void _addTask(String category) {
    String taskText = _taskControllers[category]?.text ?? '';
    if (taskText.isNotEmpty) {
      setState(() {
        _categories[category]?.add({'title': taskText, 'completed': false});
        _taskControllers[category]?.clear();
        _showTaskInput[category] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task added to "$category" successfully!'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController categoryController =
                      TextEditingController();
                  return AlertDialog(
                    title: const Text('Add Category'),
                    content: TextField(
                      controller: categoryController,
                      decoration:
                          const InputDecoration(labelText: 'Category Name'),
                      onSubmitted: (value) {
                        _addCategory(value);
                        Navigator.of(context).pop();
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _addCategory(categoryController.text);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _categories.keys.length,
        itemBuilder: (context, categoryIndex) {
          String category = _categories.keys.elementAt(categoryIndex);
          List<Map<String, dynamic>> tasks = _categories[category] ?? [];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1),
              ),
              child: ExpansionTile(
                title: GestureDetector(
                  onLongPress: () => _showCategoryOptions(category),
                  child: Text(
                    category,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                children: [
                  if (_showTaskInput[category] == true)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _taskControllers[category],
                              decoration: const InputDecoration(
                                  labelText: 'Add a task'),
                              onSubmitted: (_) => _addTask(category),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.blue),
                            onPressed: () => _addTask(category),
                          ),
                        ],
                      ),
                    ),
                  ListTile(
                    title: const Text('Add Task'),
                    leading: const Icon(Icons.add),
                    onTap: () {
                      setState(() {
                        _showTaskInput[category] =
                            !(_showTaskInput[category] ?? false);
                      });
                    },
                  ),
                  ...tasks.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> task = entry.value;
                    return ListTile(
                      leading: Checkbox(
                        value: task['completed'],
                        onChanged: (bool? value) {
                          setState(() {
                            task['completed'] = value!;
                          });
                        },
                      ),
                      title: Text(
                        task['title'],
                        style: TextStyle(
                          color: task['completed'] ? Colors.grey : Colors.black,
                          decoration: task['completed']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
