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
  void _editCategory(String oldCategoryName) {
    TextEditingController editController =
        TextEditingController(text: oldCategoryName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.black)),
          title: Text(
            "Edit Category",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          content: TextField(
            controller: editController,
            style: TextStyle(
                fontSize: 18, color: const Color.fromARGB(255, 0, 0, 0)),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black,
              hintText: "Enter new category name",
              hintStyle:
                  TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (editController.text.isNotEmpty &&
                      editController.text != oldCategoryName) {
                    categories[editController.text] =
                        categories.remove(oldCategoryName)!;
                  }
                });
                _saveData();
                Navigator.pop(context);
              },
              child: Text(
                "Save",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
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
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.black)),
        title: Text("Edit Task",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.teal)),
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
                  BorderSide(color: Colors.teal, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
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
              child: Text(
                "Save",
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

  String who(String name) {
    return "This is Jiren Speaking";
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
    bool isKeyboardActive = MediaQuery.of(context).viewInsets.bottom > 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _showTaskInputs.updateAll((key, value) => false);
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
              PopupMenuButton<String>(
              color: Colors.teal,
              elevation: 4.0,
              onSelected: (String result) {
                switch (result) {
                case 'Help':
                  Navigator.pushNamed(context, '/help');
                  break;
                case 'Contact':
                  Navigator.pushNamed(context, '/contact');
                  break;
                case 'About':
                  Navigator.pushNamed(context, '/about');
                  break;
                
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                value: 'Help',
                child: ListTile(
                  leading: Icon(Icons.help_outline, color: Color.fromARGB(255, 218, 218, 218)),
                  title: Text('Help', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                ),
                const PopupMenuItem<String>(
                value: 'Contact',
                child: ListTile(
                  leading: Icon(Icons.contact_page_rounded, color: Colors.white),
                  title: Text('Developer', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                ),
                const PopupMenuItem<String>(
                value: 'About',
                child: ListTile(
                  leading: Icon(Icons.info, color: Colors.white),
                  title: Text('About             ', style: TextStyle(color: Colors.white,fontSize: 20)),
                ),
                ),
                
              ],
              icon: Icon(Icons.menu, color: Colors.white),
              ),
            ],
            ),
          
          centerTitle: true,
          backgroundColor: Colors.teal,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          color: Colors.white,
          // color: Color.fromARGB(255, 75, 108, 138),
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
                                  hintStyle: TextStyle(
                                      color: const Color.fromARGB(255, 168, 165, 165)),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Colors.teal,
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 5, 116, 150),
                                        width: 1),
                                  ),
                                  fillColor: Colors.teal,
                                  filled: true,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check,
                                color:
                                    Colors.teal),
                            onPressed: _addCategory,
                          ),
                        ],
                      ),
                    Expanded(
                      child: ReorderableListView(
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex)
                              newIndex--; // Fix index shift issue
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
                            Dismissible(
                              key: ValueKey(category),
                              background: Container(
                                color: const Color.fromARGB(255, 26, 105, 170),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: const Color.fromARGB(255, 204, 42, 30),
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  // Swipe Right (Edit)
                                  _editCategory(category);
                                  return false; // Prevent dismissal
                                } else if (direction ==
                                    DismissDirection.endToStart) {
                                  // Swipe Left (Delete)
                                  String deletedCategory = category;
                                  List<Task> deletedTasks =
                                      categories[category]!;

                                  setState(() {
                                    categories.remove(category);
                                  });
                                  _saveData();

                                  // Show Undo Snackbar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          Colors.teal,
                                      content: Text(
                                        "Category deleted",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      action: SnackBarAction(
                                        textColor: Colors.yellow,
                                        label: "UNDO",
                                        onPressed: () {
                                          setState(() {
                                            categories[deletedCategory] =
                                                deletedTasks;
                                          });
                                          _saveData();
                                        },
                                      ),
                                    ),
                                  );
                                  return true; // Confirm deletion
                                }
                                return false;
                              },
                              child: Card(
                                key: ValueKey(category),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                elevation: 2,
                                color: const Color.fromARGB(255, 243, 243, 242),
                                child: ExpansionTile(
                                  iconColor: Colors.teal,
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.teal,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  collapsedBackgroundColor:
                                      const Color.fromARGB(255, 243, 243, 240),
                                  collapsedIconColor: Colors.teal,
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              child: Text(
                                                category,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      if (categories[category]!.isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            LinearProgressIndicator(
                                              value: categories[category]!
                                                      .where((task) =>
                                                          task.isCompleted)
                                                      .length /
                                                  categories[category]!.length,
                                              // ignore: deprecated_member_use
                                              backgroundColor: const Color.fromARGB(255, 190, 190, 190),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                categories[category]!.isEmpty
                                                    ? Colors.deepOrangeAccent
                                                    : (categories[category]!
                                                                    .where((task) =>
                                                                        task
                                                                            .isCompleted)
                                                                    .length /
                                                                categories[
                                                                        category]!
                                                                    .length <
                                                            0.5)
                                                        ? Colors
                                                            .deepOrangeAccent
                                                        : (categories[category]!
                                                                        .where((task) =>
                                                                            task
                                                                                .isCompleted)
                                                                        .length /
                                                                    categories[
                                                                            category]!
                                                                        .length <
                                                                0.75)
                                                            ? const Color.fromARGB(255, 245, 222, 14)
                                                            : Colors.green,
                                              ),
                                              minHeight: 6,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4)),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '${categories[category]!.where((task) => task.isCompleted).length} / ${categories[category]!.length} tasks completed',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  children: [
                                    // Task List Section
                                    ReorderableListView(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      onReorder: (oldIndex, newIndex) {
                                        setState(() {
                                          if (newIndex > oldIndex) newIndex--;
                                          final taskList =
                                              categories[category]!;
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
                                              color: Color.fromARGB(255, 29, 78, 117),
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              child: Icon(Icons.edit,
                                                  color: Colors.white),
                                            ),
                                            secondaryBackground: Container(
                                              color: Color.fromARGB(255, 182, 34, 23),
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
                                                        color: Colors.black,
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
                                                        checkColor:
                                                            Colors.white,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        value: task.isCompleted,
                                                        activeColor:
                                                            Colors.teal,
                                                        side: BorderSide(
                                                          color: Colors.black,
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
                                                        fontWeight: task
                                                                .isCompleted
                                                            ? FontWeight.w300
                                                            : FontWeight.w500,
                                                        color: task.isCompleted
                                                            ? Colors.grey[500]
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    // Add Task Button placed at the end of the task list
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          if (_showTaskInputs[category] ??
                                              false)
                                            Expanded(
                                              child: Container(
                                                margin: EdgeInsets.all(8.0),
                                                child: TextField(
                                                  controller: _taskControllers[
                                                      category],
                                                  focusNode:
                                                      _taskFocusNodes[category],
                                                  autofocus: true,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: 'Add Task',
                                                    hintStyle: TextStyle(
                                                      color:
                                                          const Color.fromARGB(255, 177, 166, 166),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    fillColor: Colors.teal,
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
                                              color: Colors.teal,
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
                            )
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
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(_showCategoryInput ? Icons.close : Icons.add,
                    color: Colors.white),
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
