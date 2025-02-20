import 'package:flutter/material.dart';

class ToDoHomePage extends StatefulWidget {
  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tooran'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        centerTitle: true,
        backgroundColor: Colors.teal,
        shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
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
            // Your existing widgets here...
          ],
        ),
      ),
    );
  }
}
