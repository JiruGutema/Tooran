import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'providers/theme_provider.dart';
import 'services/window_service.dart';
import 'theme/app_theme.dart';
import 'pages/responsive_home.dart';
import 'pages/history_page.dart';
import 'pages/help_page.dart';
import 'pages/contact_page.dart';
import 'pages/about_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore the last desktop window geometry before runApp so the user lands
  // in the same window they left, instead of the runner's hardcoded 400x600.
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await WindowService.instance.restoreOnStartup();
    WindowService.instance.attachListeners();
  }

  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..loadThemePreference(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Tooran',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const ResponsiveHome(),
              '/history': (context) => HistoryPage(),
              '/help': (context) => HelpPage(),
              '/contact': (context) => ContactPage(),
              '/about': (context) => AboutPage(),
            },
          );
        },
      ),
    );
  }
}
