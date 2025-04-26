import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooran/history_page.dart';
import 'package:tooran/model.dart';

class ToDoHomePage extends StatefulWidget {
  const ToDoHomePage({super.key});

  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  Map<String, List<Task>> categories = {};
  final TextEditingController _categoryController = TextEditingController();

  final Map<String, TextEditingController> _taskControllers = {};
  final Map<String, FocusNode> _taskFocusNodes = {};
  final Map<String, bool> _showTaskInputs = {};
  bool _showCategoryInput = false;
  final Map<String, TextEditingController> _descControllers = {};

  List<DeletedCategory> deletedCategories = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _saveDeletedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedData =
        json.encode(deletedCategories.map((dc) => dc.toJson()).toList());
    await prefs.setString('deletedCategories', deletedData);
  }

  Future<void> _loadDeletedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedData = prefs.getString('deletedCategories');
    if (deletedData != null) {
      setState(() {
        deletedCategories = (json.decode(deletedData) as List)
            .map((item) => DeletedCategory.fromJson(item))
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadDeletedCategories();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesData = prefs.getString('categories');

    if (categoriesData != null) {
      try {
        final decodedData = json.decode(categoriesData);
        final Map<String, List<Task>> loadedCategories = {};

        decodedData.forEach((categoryName, tasks) {
          if (tasks is List) {
            loadedCategories[categoryName] = tasks.map<Task>((taskData) {
              if (taskData is Map<String, dynamic>) {
                return Task.fromJson(taskData);
              }
              return Task(name: taskData.toString());
            }).toList();
          }
        });

        setState(() {
          categories = loadedCategories;
        });
      } catch (e) {
        print('Error loading categories: $e');
        setState(() {
          categories = {};
        });
      }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesData = json.encode(categories.map((key, value) {
      return MapEntry(key, value.map((task) => task.toJson()).toList());
    }));
    await prefs.setString('categories', categoriesData);
  }

  void _addCategory() {
    if (_categoryController.text.isNotEmpty) {
      setState(() {
        categories[_categoryController.text] = [];
        _taskControllers[_categoryController.text] = TextEditingController();
        _descControllers[_categoryController.text] = TextEditingController();
        _taskFocusNodes[_categoryController.text] = FocusNode();
        _showTaskInputs[_categoryController.text] = false;
        _showCategoryInput = false;
      });
      _categoryController.clear();
      _saveData();
    }
  }

  void _editCategory(String oldCategoryName) {
    TextEditingController editController =
        TextEditingController(text: oldCategoryName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(33, 44, 57, 1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(
                  color: const Color.fromARGB(255, 53, 204, 209), width: 0.5)),
          title: Text(
            "Edit Category",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          content: TextField(
            cursorColor: Colors.white,
            controller: editController,
            autofocus: true,
            style: TextStyle(fontSize: 18, color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(23, 33, 43, 1),
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
                    BorderSide(color: Color.fromRGBO(33, 44, 57, 1), width: 2),
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
                  color: Colors.white,
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

  void _addTask(String category) {
    if (!_taskControllers.containsKey(category)) {
      _taskControllers[category] = TextEditingController();
      _descControllers[category] = TextEditingController();
      _taskFocusNodes[category] = FocusNode();
      _showTaskInputs[category] = false;
    }

    final name = _taskControllers[category]!.text.trim();
    if (name.isEmpty) return;

    setState(() {
      categories[category]?.add(Task(
        name: name,
        description: _descControllers[category]?.text ?? 'No Description',
      ));
      _taskControllers[category]!.clear();
      if (_descControllers[category] != null) {
        _descControllers[category]!.clear();
      }
      _taskFocusNodes[category]!.unfocus();

      _showTaskInputs[category] = false;
    });

    _saveData();
    FocusScope.of(context).unfocus();
  }

  void _editTask(String category, Task task) {
    TextEditingController nameController =
        TextEditingController(text: task.name);
    TextEditingController descController =
        TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromRGBO(33, 44, 57, 1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
                color: const Color.fromARGB(255, 53, 204, 209), width: 0.5)),
        title: Text("Edit Task",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                cursorColor: Colors.white,
                controller: nameController,
                autofocus: true,
                style: TextStyle(fontSize: 18, color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromRGBO(23, 33, 43, 1),
                  labelText: "Task Name",
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                cursorColor: Colors.white,
                controller: descController,
                maxLines: 3,
                style: TextStyle(fontSize: 18, color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromRGBO(23, 33, 43, 1),
                  labelText: "Description",
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
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
                task.name = nameController.text;
                task.description = descController.text;
              });
              _saveData();
              Navigator.pop(context);
            },
            child: Text("Save",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
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
    _taskControllers.forEach((key, controller) => controller.dispose());
    _descControllers
        .forEach((key, controller) => controller.dispose()); 
    _taskFocusNodes.forEach((key, focusNode) => focusNode.dispose());
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
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.history, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryPage(
                            deletedCategories: deletedCategories,
                            onRestore: (categoryName) {
                              setState(() {
                                final toRestore = deletedCategories.firstWhere(
                                    (dc) => dc.name == categoryName);
                                categories[toRestore.name] = toRestore.tasks;
                                deletedCategories.removeWhere(
                                    (dc) => dc.name == categoryName);
                              });
                              _saveData();
                              _saveDeletedCategories();
                              Navigator.pop(context);
                            },
                            onPermanentDelete: (categoryName) {
                              setState(() {
                                deletedCategories.removeWhere(
                                    (dc) => dc.name == categoryName);
                              });
                              _saveDeletedCategories();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    color: Color.fromRGBO(33, 44, 57, 1),
                    elevation: 8.0,
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
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Help',
                        child: ListTile(
                          leading: Icon(Icons.help_outline,
                              color: Color.fromARGB(255, 218, 218, 218)),
                          title: Text('Help',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Contact',
                        child: ListTile(
                          leading: Icon(Icons.contact_page_rounded,
                              color: Colors.white),
                          title: Text('Developer',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'About',
                        child: ListTile(
                          leading: Icon(Icons.info, color: Colors.white),
                          title: Text('About             ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ),
                    ],
                    icon: Icon(Icons.menu, color: Colors.white),
                    shadowColor: const Color.fromRGBO(23, 33, 43, 1),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: const Color.fromARGB(255, 8, 159, 197),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    offset: Offset(0, 50),
                  ),
                ],
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(33, 44, 57, 1),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          color: Color.fromRGBO(23, 33, 43, 1),
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
                                cursorColor: Colors.white,
                                controller: _categoryController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter Category Name',
                                  hintStyle: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 190, 186, 186)),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        width: 1),
                                  ),
                                  fillColor: Color.fromRGBO(33, 44, 57, 1),
                                  filled: true,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check,
                                color:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            onPressed: _addCategory,
                          ),
                        ],
                      ),
                    Expanded(
                      child: ReorderableListView(
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex--;
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
                            Dismissible(
                              key: ValueKey(category),
                              background: Container(
                                color: const Color.fromARGB(255, 18, 59, 92),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: const Color.fromARGB(255, 119, 36, 30),
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  _editCategory(category);
                                  return false;
                                } else if (direction ==
                                    DismissDirection.endToStart) {
                                  String deletedCategory = category;
                                  List<Task> deletedTasks =
                                      categories[category]!;

                                  setState(() {
                                    categories.remove(category);
                                    deletedCategories.add(DeletedCategory(
                                      name: deletedCategory,
                                      tasks: deletedTasks,
                                      deletedAt: DateTime.now(),
                                    ));
                                  });
                                  _saveData();
                                  _saveDeletedCategories();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          Color.fromRGBO(33, 44, 57, 1),
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
                                            deletedCategories.removeWhere(
                                                (dc) =>
                                                    dc.name == deletedCategory);
                                          });
                                          _saveData();
                                          _saveDeletedCategories();
                                        },
                                      ),
                                    ),
                                  );
                                  return true;
                                }
                                return false;
                              },
                              child: Card(
                                key: ValueKey(category),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                elevation: 2,
                                color: Color.fromRGBO(33, 44, 57, 1),
                                child: ExpansionTile(
                                  iconColor: Colors.white,
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color:
                                          const Color.fromARGB(255, 6, 98, 114),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  collapsedBackgroundColor:
                                      Color.fromRGBO(33, 44, 57, 1),
                                  collapsedIconColor: Colors.white,
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
                                                  color: Colors.white,
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
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 186, 185, 185),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                categories[category]!.isEmpty
                                                    ? Colors.grey
                                                    : Color.lerp(
                                                        const Color(0xFFA5D6A7),
                                                        const Color(0xFF2E7D32),
                                                        categories[category]!
                                                                .where((task) =>
                                                                    task
                                                                        .isCompleted)
                                                                .length /
                                                            categories[
                                                                    category]!
                                                                .length,
                                                      )!,
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
                                              color: Color.fromARGB(
                                                  255, 29, 78, 117),
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              child: Icon(Icons.edit,
                                                  color: Colors.white),
                                            ),
                                            secondaryBackground: Container(
                                              color: Color.fromARGB(
                                                  255, 122, 36, 30),
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
                                                            Color.fromARGB(255,
                                                                41, 143, 10),
                                                        side: BorderSide(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              255, 255, 255),
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
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (task.description
                                                            .isNotEmpty) {
                                                          showGeneralDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                true,
                                                            barrierLabel:
                                                                "Dismiss",
                                                            barrierColor: Colors
                                                                .black
                                                                .withOpacity(
                                                                    0.5),
                                                            transitionDuration:
                                                                Duration(
                                                                    milliseconds:
                                                                        300),
                                                            pageBuilder:
                                                                (_, __, ___) {
                                                              return Center(
                                                                child:
                                                                    AlertDialog(
                                                                  backgroundColor:
                                                                      Color.fromRGBO(
                                                                          23,
                                                                          33,
                                                                          43,
                                                                          1),
                                                                  title: Text(
                                                                    task.name,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .cyanAccent),
                                                                  ),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                  ),
                                                                  content:
                                                                      SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.15,
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          Text(
                                                                        task.description,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                      child:
                                                                          Text(
                                                                        "Close",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20,
                                                                            color:
                                                                                Colors.red),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                            transitionBuilder:
                                                                (_, anim, __,
                                                                    child) {
                                                              return FadeTransition(
                                                                opacity: anim,
                                                                child:
                                                                    ScaleTransition(
                                                                  scale: CurvedAnimation(
                                                                      parent:
                                                                          anim,
                                                                      curve: Curves
                                                                          .easeOutBack),
                                                                  child: child,
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        }
                                                      },
                                                      child: Text(
                                                        task.name,
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .visible,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: task
                                                                  .isCompleted
                                                              ? FontWeight.w300
                                                              : FontWeight.w500,
                                                          color: task
                                                                  .isCompleted
                                                              ? Colors.grey[500]
                                                              : Colors.white,
                                                        ),
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
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          if (_showTaskInputs[category] ??
                                              false)
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      23, 33, 43, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                margin: EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    TextField(
                                                      cursorColor: Colors.white,
                                                      controller:
                                                          _taskControllers[
                                                              category]!,
                                                      focusNode:
                                                          _taskFocusNodes[
                                                              category]!,
                                                      autofocus: true,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'Task Name',
                                                        hintStyle: TextStyle(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                219, 219, 219)),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  width: 1),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1)),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1)),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        14),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    TextField(
                                                      cursorColor: Colors.white,
                                                      controller:
                                                          _descControllers[
                                                              category],
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Description (optional)',
                                                        hintStyle: TextStyle(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                219, 219, 219)),
                                                        border: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1)),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1)),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 1)),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        14),
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          IconButton(
                                            icon: Icon(
                                              _showTaskInputs[category] ?? false
                                                  ? Icons.check
                                                  : Icons.add,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              if (_showTaskInputs[category] ??
                                                  false) {
                                                _taskControllers[category]!
                                                        .text =
                                                    _taskControllers[category]!
                                                        .text;
                                                _addTask(category);
                                              } else {
                                                setState(() {
                                                  _taskControllers[category] ??=
                                                      TextEditingController();
                                                  _taskFocusNodes[category] ??=
                                                      FocusNode();
                                                  _showTaskInputs[category] =
                                                      true;
                                                });
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  _taskFocusNodes[category]!
                                                      .requestFocus();
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    )
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
                backgroundColor: Color.fromRGBO(33, 44, 57, 1),
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
