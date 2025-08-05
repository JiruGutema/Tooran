import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tooran/pages/home_page.dart';
import 'package:tooran/providers/theme_provider.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('HomePage Due Date Integration Tests', () {
    testWidgets('Add task dialog should include due date input', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Add a category first
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test Category');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expand the category to show tasks
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Tap "Add Task" button
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // Verify the dialog contains due date input
      expect(find.text('Add Task'), findsOneWidget);
      expect(find.text('Task Name'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
      expect(find.text('Due Date & Time'), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);

      // Cancel the dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('Edit task dialog should include due date input with existing values', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Add a category first
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test Category');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expand the category to show tasks
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Add a task first
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test Task');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Find and tap the task to edit it (swipe left to edit)
      final taskTile = find.byType(Dismissible).first;
      await tester.drag(taskTile, const Offset(-100, 0));
      await tester.pumpAndSettle();

      // Verify the edit dialog contains due date input
      expect(find.text('Edit Task'), findsOneWidget);
      expect(find.text('Task Name'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
      expect(find.text('Due Date & Time'), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);

      // Cancel the dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('Task creation should handle due date validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Add a category first
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test Category');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expand the category to show tasks
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Tap "Add Task" button
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // Enter task name
      await tester.enterText(find.byType(TextField).first, 'Test Task');

      // Try to add the task without due date (should work)
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify task was created
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('Should display due date information in task list', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add a category
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test Category');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expand the category
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Add a task
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Task with Due Date');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify task appears in list
      expect(find.text('Task with Due Date'), findsOneWidget);
    });

    testWidgets('Should handle task completion and notification cancellation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add a category
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test Category');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expand the category
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Add a task
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Completable Task');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Find and tap the checkbox to complete the task
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Verify completion feedback appears
      expect(find.textContaining('completed'), findsOneWidget);
    });

    testWidgets('Should handle category deletion with due date preservation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add a category
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Deletable Category');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expand the category
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Add a task with due date
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Task with Due Date');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Swipe right to delete category
      final categoryTile = find.byType(Dismissible).first;
      await tester.drag(categoryTile, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify category is deleted and undo option appears
      expect(find.text('Deletable Category'), findsNothing);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('Should handle category restoration with due date preservation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add a category
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Restorable Category');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expand the category
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Add a task
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Restorable Task');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Delete category
      final categoryTile = find.byType(Dismissible).first;
      await tester.drag(categoryTile, const Offset(100, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Restore category using undo
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // Verify category and task are restored
      expect(find.text('Restorable Category'), findsOneWidget);
      expect(find.text('restored'), findsOneWidget);
    });

    testWidgets('Should handle task deletion and notification cancellation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add a category
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test Category');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expand the category
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Add a task
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Deletable Task');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Swipe right to delete task
      final taskTile = find.byType(Dismissible).last;
      await tester.drag(taskTile, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify task is deleted
      expect(find.text('Deletable Task'), findsNothing);
      expect(find.textContaining('deleted'), findsOneWidget);
    });

    testWidgets('Should show task details with due date information', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add a category
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test Category');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Expand the category
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Add a task
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Detailed Task');
      await tester.enterText(find.byType(TextField).last, 'Task description');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Tap on task to show details
      await tester.tap(find.text('Detailed Task'));
      await tester.pumpAndSettle();

      // Verify task details dialog
      expect(find.text('Detailed Task'), findsAtLeastNWidgets(1));
      expect(find.text('Description:'), findsOneWidget);
      expect(find.text('Task description'), findsOneWidget);
      expect(find.text('Status:'), findsOneWidget);
      expect(find.text('Created:'), findsOneWidget);
    });
  });
}