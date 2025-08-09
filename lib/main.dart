import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/history_page.dart';
import 'pages/help_page.dart';
import 'pages/contact_page.dart';
import 'pages/about_page.dart';
import 'services/notification_service.dart';
import 'services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service with release-specific handling
  final notificationService = NotificationService();
  
  try {
    // Force initialization with better error handling for release builds
    final initialized = await notificationService.initialize(forceReinit: true);
    
    if (initialized) {
      debugPrint('Notification service initialized successfully');
      
      // Load all tasks and reschedule notifications
      try {
        final dataService = DataService();
        final categories = await dataService.loadCategoriesWithRecovery();
        final allTasks = categories.expand((category) => category.tasks).toList();
        await notificationService.rescheduleAllNotifications(allTasks);
        debugPrint('Notifications rescheduled for ${allTasks.length} tasks');
      } catch (e) {
        debugPrint('Failed to reschedule notifications on startup: $e');
      }
    } else {
      debugPrint('Notification service initialization failed');
    }
  } catch (e) {
    debugPrint('Critical error initializing notifications: $e');
    // Continue app startup even if notifications fail
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
              '/': (context) => HomePage(),
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
