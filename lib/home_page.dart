import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoHomePage extends StatefulWidget {
  const ToDoHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  Map<String, List<Task>> categories = {};
  final TextEditingController _categoryController = TextEditingController();
  final Map<String, TextEditingController> _taskControllers = {};
  final Map<String, FocusNode> _taskFocusNodes = {};
  final Map<String, bool> _showTaskInputs = {};
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
          backgroundColor: Color.fromARGB(255, 57, 86, 109),
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
    if (!_taskControllers.containsKey(category)) {
      _taskControllers[category] = TextEditingController();
    }
    if (!_taskFocusNodes.containsKey(category)) {
      _taskFocusNodes[category] = FocusNode();
    }
    if (!_showTaskInputs.containsKey(category)) {
      _showTaskInputs[category] = false;
    }

    if (_taskControllers[category]!.text.isNotEmpty) {
      setState(() {
        categories[category]?.add(Task(name: _taskControllers[category]!.text));
        _taskControllers[category]!.clear();
        _showTaskInputs[category] = false;
      });
      _saveData();
    }
  }

  void _editTask(String category, Task task) {
    TextEditingController controller = TextEditingController(text: task.name);
    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 57, 86, 109),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white)
        ),
        title: Text("Edit Task",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color.fromARGB(255, 57, 86, 109))),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(fontSize: 18, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: "Enter new task name",
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide:
                  BorderSide(color: Color.fromARGB(255, 57, 86, 109), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                task.name = controller.text;
              });
              _saveData();
              Navigator.pop(context);
            },
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 20,
              ),
              child: Text("Save",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _showCategoryOptions(String category) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color:
              Color.fromARGB(255, 57, 86, 109), // Set background color to teal
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                title: Text('Edit Category',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
                onTap: () {
                  Navigator.pop(context);
                  _editCategory(category);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Category',
                    style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
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
  Widget build(BuildContext context) {
    // Check if keyboard is active using MediaQuery
    bool isKeyboardActive = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Detect taps on empty spaces
      onTap: () {
        FocusScope.of(context).unfocus(); // Hide keyboard and remove focus
        setState(() {
          _showTaskInputs
              .updateAll((key, value) => false); // Hide all input fields
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
          backgroundColor: const Color.fromARGB(255, 57, 86, 109),
        ),
        body: Container(
          color: Color.fromARGB(255, 75, 108, 138),
          child: Center(
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
                            child: Container(
                              margin: EdgeInsets.all(8.0),
                              child: TextField(
                                
                                controller: _categoryController,
                                   style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter Category Name',
                                  hintStyle: TextStyle(color: const Color.fromARGB(255, 204, 204, 204)),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 255, 255, 255),
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 255, 255, 255),
                                        width: 1),
                                  ),
                                  fillColor:    Color.fromARGB(255, 57, 86, 109),
                                  filled: true,
                                
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check, color: const Color.fromARGB(255, 255, 255, 255)),
                            onPressed: _addCategory,

                          ),
                        ],
                      ),
                    Expanded(
                      child: ReorderableListView(
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex--; // Fix index shift issue
                            }
                            final categoryKeys = categories.keys.toList();
                            final movedCategory =
                                categoryKeys.removeAt(oldIndex);
                            categoryKeys.insert(newIndex, movedCategory);

                            final newCategories = <String, List<Task>>{};
                            for (var key in categoryKeys) {
                              newCategories[key] = categories[key]!;
                            }
                            categories = newCategories;
                          });
                          _saveData();
                        },
                        children: [
                          for (String category in categories.keys)
                            Card(
                              key: ValueKey(
                                  category), // Key is needed for reordering
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 2,

                              color:   Color.fromARGB(255, 57, 86, 109),
                              child: ExpansionTile(
                              iconColor: const Color.fromARGB(255, 255, 255, 255),
                              collapsedShape: RoundedRectangleBorder(
                               
                                borderRadius: BorderRadius.circular(4),
                              ),
                              shape: RoundedRectangleBorder(
                                
                                side: BorderSide(
                                  
                                color: Color.fromARGB(255, 255, 255, 255),
                                width: 1,
                                ),
                                
                                
                                borderRadius: BorderRadius.circular(4),
                              ),
                              collapsedBackgroundColor: Color.fromARGB(255, 57, 86, 109),
                              collapsedIconColor: Colors.white,

                                title: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onLongPress: () =>
                                            _showCategoryOptions(category),
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 255, 255, 255),
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  ReorderableListView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    onReorder: (oldIndex, newIndex) {
                                      setState(() {
                                        if (newIndex > oldIndex) newIndex--;
                                        final taskList = categories[category]!;
                                        final movedTask =
                                            taskList.removeAt(oldIndex);
                                        taskList.insert(newIndex, movedTask);
                                      });
                                      _saveData();
                                    },
                                    children: [
                                      for (Task task in categories[category]!)
                                        Dismissible(
                                          
                                          key: ValueKey(task),
                                          background: Container(
                                            color:  Color.fromARGB(255, 75, 108, 138),
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Icon(Icons.edit,
                                                color: Colors.white),
                                          ),
                                          secondaryBackground: Container(
                                            color:
                                                Color.fromARGB(255, 244, 18, 2),
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Icon(Icons.delete,
                                                color: Colors.white),
                                          ),
                                          confirmDismiss: (direction) async {
                                            if (direction ==
                                                DismissDirection.startToEnd) {
                                              _editTask(category, task);
                                              return false;
                                            } else if (direction ==
                                                DismissDirection.endToStart) {
                                              Task deletedTask = task;
                                              setState(() {
                                                categories[category]!
                                                    .remove(task);
                                              });
                                              _saveData();

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 57, 86, 109),
                                                  content: Text(
                                                    "Task deleted",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  action: SnackBarAction(
                                                    textColor: Colors.yellow,
                                                    label: "UNDO",
                                                    onPressed: () {
                                                      setState(() {
                                                        categories[category]!
                                                            .add(deletedTask);
                                                      });
                                                      _saveData();
                                                    },
                                                  ),
                                                ),
                                              );
                                              return true;
                                            }
                                            return false;
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 10),
                                             
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  
                                                  height: 30,
                                                    child: Transform.scale(
                                                    scale: 1,
                                                    child: Checkbox(
                                                      checkColor: Colors.white,
                                                      materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                          .shrinkWrap,
                                                      visualDensity:
                                                        VisualDensity.compact,
                                                      value: task.isCompleted,
                                                      activeColor:
                                                        Color.fromARGB(255, 41, 143, 10),
                                                      side: BorderSide(
                                                      color: const Color.fromARGB(255, 255, 255, 255),
                                                      width: 2,
                                                      ),
                                                      onChanged: (value) {
                                                      setState(() {
                                                        task.isCompleted =
                                                          value!;
                                                      });
                                                        _saveData();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  
                                                  child: Text(
                                                  
                                                    task.name,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.visible,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: task.isCompleted ? FontWeight.w300 : FontWeight.w500,
                                                      color: task.isCompleted
                                                          ? Colors.grey[500]
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Row(
                                      children: [
                                        if (_showTaskInputs[category] ?? false)
                                            Expanded(
                                            child: Container(
                                              margin: EdgeInsets.all(8.0),
                                              child: TextField(
                                              controller: _taskControllers[category],
                                              focusNode: _taskFocusNodes[category],
                                              style: TextStyle(color: Colors.white), // Set text color to white
                                              decoration: InputDecoration(
                                                hintText: 'Add Task',
                                                hintStyle: TextStyle(color: const Color.fromARGB(255, 219, 219, 219)),
                                                border: OutlineInputBorder(),
                                                focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1,
                                                ),
                                                ),
                                                fillColor: Color.fromARGB(255, 57, 86, 109),
                                                filled: true,
                                              ),
                                              ),
                                            ),
                                            ),
                                          
                                          
                                        IconButton(
                                          
                                          icon: Icon(
                                            _showTaskInputs[category] ?? false
                                                ? Icons.check
                                                : Icons.add,
                                                color: Colors.white
                                          ),
                                          onPressed: () {
                                            if (_showTaskInputs[category] ??
                                                false) {
                                              _addTask(category);
                                            } else {
                                              setState(() {
                                                _showTaskInputs[category] =
                                                    true;
                                              });
                                              _taskFocusNodes[category]
                                                  ?.requestFocus();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
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
          backgroundColor:  Color.fromARGB(255, 57, 86, 109),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          
          child: Icon(_showCategoryInput ? Icons.close : Icons.add, color: Colors.white),
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
