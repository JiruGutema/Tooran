import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'help_page.dart'; // Import Help page
import 'contact_page.dart'; // Import Contact page
import 'home_page.dart'; // Import Home page

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set the initial route to Home
      routes: {
        '/': (context) => ToDoHomePage(), // Home page route
        '/help': (context) => HelpPage(), // Help page route
        '/contact': (context) => ContactPage(), // Contact page route
      },
    );
  }
}





class ToDoHomePage extends StatefulWidget {
  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  Map<String, List<Task>> categories = {};
  final TextEditingController _categoryController = TextEditingController();
  Map<String, TextEditingController> _taskControllers = {};
  Map<String, FocusNode> _taskFocusNodes = {};
  Map<String, bool> _showTaskInputs = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load categories and tasks from shared preferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesData = prefs.getString('categories');
    if (categoriesData != null) {
      final Map<String, dynamic> categoriesMap = json.decode(categoriesData);
      setState(() {
        categories = categoriesMap.map((key, value) {
          return MapEntry(
            key,
            (value as List).map((task) => Task.fromJson(task)).toList(),
          );
        });
      });
    }
  }

  // Save categories and tasks to shared preferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesData = json.encode(categories.map((key, value) {
      return MapEntry(key, value.map((task) => task.toJson()).toList());
    }));
    await prefs.setString('categories', categoriesData);
  }

  // Add a new category
  void _addCategory() {
    if (_categoryController.text.isNotEmpty) {
      setState(() {
        categories[_categoryController.text] = [];
        _taskControllers[_categoryController.text] = TextEditingController();
        _taskFocusNodes[_categoryController.text] = FocusNode();
        _showTaskInputs[_categoryController.text] = false;
      });
      _categoryController.clear();
      _saveData(); // Save data after adding a category
    }
  }

  // Edit an existing category
  void _editCategory(String oldCategory) {
    _categoryController.text = oldCategory;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(hintText: 'Category Name', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  final tasks = categories[oldCategory];
                  categories.remove(oldCategory);
                  categories[_categoryController.text] = tasks!;
                  _taskControllers[_categoryController.text] = _taskControllers.remove(oldCategory)!;
                  _taskFocusNodes[_categoryController.text] = _taskFocusNodes.remove(oldCategory)!;
                  _showTaskInputs[_categoryController.text] = _showTaskInputs.remove(oldCategory)!;
                });
                _categoryController.clear();
                Navigator.pop(context);
                _saveData(); // Save data after editing category
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete a category
  void _deleteCategory(String category) {
    setState(() {
      categories.remove(category);
      _taskControllers.remove(category);
      _taskFocusNodes.remove(category);
      _showTaskInputs.remove(category);
    });
    _saveData(); // Save data after deleting category
  }

  // Add a task to a category
  void _addTask(String category) {
    if (_taskControllers[category]!.text.isNotEmpty) {
      setState(() {
        categories[category]?.add(Task(name: _taskControllers[category]!.text));
        _taskControllers[category]!.clear();
        _showTaskInputs[category] = false;
      });
      _saveData(); // Save data after adding a task
    }
  }

  // Edit a task
  void _editTask(String category, Task task) {
    _taskControllers[category]!.text = task.name;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: _taskControllers[category],
            decoration: InputDecoration(hintText: 'Task Name', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  task.name = _taskControllers[category]!.text;
                });
                _taskControllers[category]!.clear();
                Navigator.pop(context);
                _saveData(); // Save data after editing task
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete a task
  void _deleteTask(String category, Task task) {
    setState(() {
      categories[category]?.remove(task);
    });
    _saveData(); // Save data after deleting task
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _taskControllers.forEach((key, controller) {
      controller.dispose();
    });
    _taskFocusNodes.forEach((key, focusNode) {
      focusNode.dispose();
    });
    super.dispose();
  }

  void _showCategoryOptions(String category) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Category'),
              onTap: () {
                Navigator.pop(context);
                _editCategory(category);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete Category'),
              onTap: () {
                Navigator.pop(context);
                _deleteCategory(category);
              },
            ),
          ],
        );
      },
    );
  }

  void _showTaskOptions(String category, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Task'),
              onTap: () {
                Navigator.pop(context);
                _editTask(category, task);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete Task'),
              onTap: () {
                Navigator.pop(context);
                _deleteTask(category, task);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Text('Tooran'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        centerTitle: true,
        backgroundColor: Colors.teal,
        shape: Border(bottom: BorderSide(color: const Color.fromARGB(255, 231, 141, 5), width: 2)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'help') {
                Navigator.pushNamed(context, '/help');
              } else if (value == 'contact') {
                Navigator.pushNamed(context, '/contact');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'help',
                  child: Text('Help'),
                ),
                PopupMenuItem<String>(
                  value: 'contact',
                  child: Text('Contact Us'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      hintText: 'Add Category',
                      border: OutlineInputBorder(),
                      fillColor: Colors.lightBlue[50],
                      filled: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addCategory,
                  color: Colors.teal,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categories.keys.length,
                itemBuilder: (context, index) {
                  String category = categories.keys.elementAt(index);
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    color: Colors.grey[100],
                    child: ExpansionTile(
                      title: InkWell(
                        onLongPress: () => _showCategoryOptions(category),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(0, 150, 136, 1),
                            fontSize: 20,
                          ),
                        ),
                      ),
                      children: [
                        Column(
                          children: [
                            ...categories[category]!.map((task) {
                              return InkWell(
                                onLongPress: () => _showTaskOptions(category, task),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: task.isCompleted,
                                      onChanged: (value) {
                                        setState(() {
                                          task.isCompleted = value!;
                                        });
                                        _saveData(); // Save data after checking/unchecking task
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        task.name,
                                        style: TextStyle(
                                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _deleteTask(category, task);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  if (_showTaskInputs[category] ?? false)
                                    Expanded(
                                      child: TextField(
                                        controller: _taskControllers[category],
                                        focusNode: _taskFocusNodes[category],
                                        decoration: InputDecoration(
                                          hintText: 'Add Task',
                                          border: OutlineInputBorder(),
                                          fillColor: Colors.lightBlue[50],
                                          filled: true,
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    icon: Icon(_showTaskInputs[category] ?? false ? Icons.check : Icons.add),
                                    onPressed: () {
                                      if (_showTaskInputs[category] ?? false) {
                                        _addTask(category);
                                      } else {
                                        setState(() {
                                          _showTaskInputs[category] = true;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  String name;
  bool isCompleted;

  Task({required this.name, this.isCompleted = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'],
      isCompleted: json['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
    };
  }
}
