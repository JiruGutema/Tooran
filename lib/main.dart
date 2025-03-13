import 'package:flutter/material.dart';

import 'help_page.dart'; // Import Help page
import 'contact_page.dart';
import 'home_page.dart';
import 'about.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  // Set initial window size
  windowManager.setSize(const Size(500, 600));

  // Prevent resizing (optional)
  windowManager.setResizable(false);

  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => ToDoHomePage(),
        '/help': (context) => HelpPage(),
        '/contact': (context) => ContactPage(),
        '/about': (context) => About(),
      },
    );
  }
}
