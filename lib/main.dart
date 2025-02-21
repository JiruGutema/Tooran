import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'help_page.dart';   // Import Help page
import 'contact_page.dart';
import 'home_page.dart';

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => ToDoHomePage(),
        '/help': (context) => HelpPage(),
        '/contact': (context) => ContactPage(),
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
  bool _showCategoryInput = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load categories and tasks from SharedPreferences
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

  // Save categories and tasks to SharedPreferences
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
        _showCategoryInput = false; // Hide input after adding category
      });
      _categoryController.clear();
      _saveData();
    }
  }

  // Edit an existing category
  void _editCategory(String oldCategory) {
    _categoryController.text = oldCategory;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          title: Text('Edit Category', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              hintText: 'Category Name',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  final tasks = categories[oldCategory];
                  categories.remove(oldCategory);
                  categories[_categoryController.text] = tasks!;
                  _taskControllers[_categoryController.text] =
                      _taskControllers.remove(oldCategory)!;
                  _taskFocusNodes[_categoryController.text] =
                      _taskFocusNodes.remove(oldCategory)!;
                  _showTaskInputs[_categoryController.text] =
                      _showTaskInputs.remove(oldCategory)!;
                });
                _categoryController.clear();
                Navigator.pop(context);
                _saveData();
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
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
    _saveData();
  }

  // Add a task to a category
  void _addTask(String category) {
    _taskControllers.putIfAbsent(category, () => TextEditingController());
    _taskFocusNodes.putIfAbsent(category, () => FocusNode());
    _showTaskInputs.putIfAbsent(category, () => false);

    if (_taskControllers[category]!.text.isNotEmpty) {
      setState(() {
        categories[category]?.add(Task(name: _taskControllers[category]!.text));
        _taskControllers[category]!.clear();
        _showTaskInputs[category] = false;
      });
      _saveData();
    }
  }

  // Edit a task
  void _editTask(String category, Task task) {
    _taskControllers[category]!.text = task.name;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          title: Text('Edit Task', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _taskControllers[category],
            decoration: InputDecoration(
              hintText: 'Task Name',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  task.name = _taskControllers[category]!.text;
                });
                _taskControllers[category]!.clear();
                Navigator.pop(context);
                _saveData();
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
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
    _saveData();
  }

  void _showCategoryOptions(String category) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.teal, // Set background color to teal
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                title: Text('Edit Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                onTap: () {
                  Navigator.pop(context);
                  _editCategory(category);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Category', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 20)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteCategory(category);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTaskOptions(String category, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.teal, // Set background color to teal
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                title: Text('Edit Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                onTap: () {
                  Navigator.pop(context);
                  _editTask(category, task);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Task', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 20)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTask(category, task);
                },
              ),
            ],
          ),
        );
      },
    );
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

  @override
  
@override
Widget build(BuildContext context) {
  // Check if keyboard is active using MediaQuery
  bool isKeyboardActive = MediaQuery.of(context).viewInsets.bottom > 0;

  return GestureDetector(
    behavior: HitTestBehavior.opaque, // Detect taps on empty spaces
    onTap: () {
      FocusScope.of(context).unfocus(); // Hide keyboard and remove focus
      setState(() {
        _showTaskInputs.updateAll((key, value) => false); // Hide all input fields
      });
    },
    child: Scaffold(
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
        Row(
          children: [
            IconButton(
          icon: Icon(Icons.help_outline, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/help');
          },
            ),
            IconButton(
          icon: Icon(Icons.contact_page_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/contact');
          },
            ),
          ],
        ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        shape: Border(
          bottom: BorderSide(
        color: Color.fromARGB(255, 5, 208, 231),
        width: 2,
          ),
        ),
       
         
        
      ),
      body: Center(
        child: Container(
          
          constraints: BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_showCategoryInput)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            hintText: 'Enter Category Name',
                            border: OutlineInputBorder(),
                            fillColor: Colors.lightBlue[50],
                            filled: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: _addCategory,
                      ),
                    ],
                  ),
                Expanded(
                  
                  
                  child: ListView.builder(
                    
                    itemCount: categories.keys.length,
                    
                    itemBuilder: (context, index) {
                      String category = categories.keys.elementAt(index);
                      
                      return Card(
                        
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        elevation: 2,
                        color: Colors.white,      // Match the background color
                      
                        
                        child: ExpansionTile(
                          collapsedBackgroundColor: Colors.white, // Match background color
                          title: InkWell(
                            onLongPress: () => _showCategoryOptions(category),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(0, 150, 136, 1),
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
                                          activeColor: Colors.teal,
                                          onChanged: (value) {
                                            setState(() {
                                              task.isCompleted = value!;
                                            });
                                            _saveData();
                                          },
                                        ),
                                        Expanded(
                                          
                                          child: Text(
                                            
                                            task.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: task.isCompleted ? Colors.grey[500] : Colors.black,
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
                                  padding: const EdgeInsets.all(4.0),
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
                                        icon: Icon(
                                          _showTaskInputs[category] ?? false
                                              ? Icons.check
                                              : Icons.add,
                                        ),
                                        onPressed: () {
                                          if (_showTaskInputs[category] ?? false) {
                                            _addTask(category);
                                          } else {
                                            setState(() {
                                              _showTaskInputs[category] = true;
                                            });
                                            _taskFocusNodes[category]?.requestFocus(); // Auto-focus
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
        ),
      ),
      floatingActionButton: isKeyboardActive
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showCategoryInput = !_showCategoryInput;
                });
              },
              tooltip: _showCategoryInput ? 'Close' : 'Add Category',
              child: Icon(_showCategoryInput ? Icons.close : Icons.add),
              backgroundColor: Colors.teal,
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
