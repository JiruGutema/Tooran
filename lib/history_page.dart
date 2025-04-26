import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tooran/model.dart';

class HistoryPage extends StatefulWidget {
  final List<DeletedCategory> deletedCategories;
  final Function(String) onRestore;
  final Function(String) onPermanentDelete;

  const HistoryPage({
    Key? key,
    required this.deletedCategories,
    required this.onRestore,
    required this.onPermanentDelete,
  }) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(23, 33, 43, 1),
      appBar: AppBar(
        title: Text(
          'Deleted Categories',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(33, 44, 57, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: widget.deletedCategories.isEmpty
          ? Center(
              child: Text(
                'No deleted categories',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: widget.deletedCategories.length,
              itemBuilder: (context, index) {
                final deletedCategory = widget.deletedCategories[index];
                return Dismissible(
                  key: Key(deletedCategory.name),
                  background: Container(
                    color: Color.fromARGB(255, 29, 78, 117),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.restore, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Color.fromARGB(255, 122, 36, 30),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete_forever, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      widget.onRestore(deletedCategory.name);
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      widget.onPermanentDelete(deletedCategory.name);
                      return true;
                    }
                    return false;
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Color.fromRGBO(33, 44, 57, 1),
                    child: ListTile(
                      title: Text(
                        deletedCategory.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Deleted on ${DateFormat('MMM dd, yyyy - hh:mm a').format(deletedCategory.deletedAt)}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        '${deletedCategory.tasks.length} tasks',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
