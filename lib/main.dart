import 'package:flutter/material.dart';

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
        // '/fliptime':(context) => FlipClock(),
      },
    );
  }
}
